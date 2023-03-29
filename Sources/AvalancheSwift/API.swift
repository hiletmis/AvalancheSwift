//
//  API.swift
//  
//
//  Created by Hayrettin İletmiş on 16.03.2023.
//

import Foundation
import BigInteger
import EnnoUtil

public final class AvaxAPI {

    private static var AddressesWallet:[String] = []
    private static var AddressesIntX:[String] = []
    
    private static var privateKeySegwit: String?
    private static var privateKeyWeb3: String?
     
    class func checkState(delegate: AvalancheInitDelegate) {
        
        Constants.XChain.clearBalance()
        Constants.PChain.clearBalance()
        Constants.CChain.clearBalance()
        
        var xRequestBatch: [String] = []
        var pRequestBatch: [String] = []
        var xIntRequestBatch: [String] = []

       checkChainAddresses(addresses: AddressesWallet) { [self] result in
           guard let result = result else {return}
           
           for item in result.addressChains {
               if item.value.contains(BlockchainId.xBlockchain.rawValue) {
                   xRequestBatch.append("X-" + item.key)
               }
               
               if item.value.contains(BlockchainId.pBlockchain.rawValue) {
                   pRequestBatch.append("P-" + item.key)
               }
           }
           
           DispatchQueue.global(qos: .background).async  {
               getUTXOs(addresses: xRequestBatch, chain: Constants.chainX) { balance in
                   Constants.XChain.addBalance(balance: balance, availableBalance: balance)
                   delegate.balanceInitialized(chain: Constants.XChain)
               }
           }
           
           DispatchQueue.global(qos: .background).async  {
               getUTXOs(addresses: pRequestBatch, chain: Constants.chainP) { balance in
                   Constants.PChain.addBalance(balance: balance, availableBalance: balance)
                   delegate.balanceInitialized(chain: Constants.PChain)
                   
                   getPlatformStake(addresses: pRequestBatch) {
                       delegate.delegationInitialized(chain: Constants.PChain)
                   }
               }
           }

       }
       
       checkChainAddresses(addresses: AddressesIntX, inner: true) { [self] result in
           if let result = result {
               for item in result.addressChains {
                   if item.value.contains(BlockchainId.xBlockchain.rawValue) {
                       xIntRequestBatch.append("X-" + item.key)
                   }
               }
                 
               getUTXOs(addresses: xIntRequestBatch, chain: Constants.chainX) { balance in
                   Constants.XChain.addBalance(balance: balance, availableBalance: balance)
                   delegate.balanceInitialized(chain: Constants.XChain)
               }
           }
       }

    }

    class func getXBatch(_ seed: String, _ accountIndex: Int = 0) -> [String] {
        var addresses:[String] = []
                
        if let xPrv = CryptoUtil.shared.web3xPrv(seed: seed, path: "m/44\'/9000\'/0\'") {
            let xAccountDepth = Web3Crypto.shared.deriveExtKey(xPrv: xPrv, index: accountIndex)
            
            for i in 0..<50 {
                let xAddressDepth = Web3Crypto.shared.deriveExtKey(xPrv: Base58Encoder.encode(xAccountDepth!), index: i)
                let privKey:[UInt8] = Array(xAddressDepth![46...77])

                let ripesha = Web3Crypto.shared.secp256k1Address(privKey: privKey)
                let address = Web3Crypto.shared.bech32Address(ripesha: ripesha, hrp: "avax")

                addresses.append(address ?? "N/A")

            }
        }
        return addresses
    }
    
    class func initVars(_ seed: String) {
        privateKeyWeb3 = EnnoUtil.CryptoUtil.shared.web3xPrv(seed: seed, path: "m/44\'/60\'/0\'")
        privateKeySegwit = EnnoUtil.CryptoUtil.shared.web3xPrv(seed: seed, path: "m/44\'/9000\'/0\'")
        initializeAddresses(addresses: .init(walletAddresses: getXBatch(seed, 0), internalAddresses: getXBatch(seed, 1)))
    }
    
    private class func initializeAddresses(addresses: AddressBatch) {
        AddressesWallet = addresses.walletAddresses
        AddressesIntX = addresses.internalAddresses
        
        Constants.XChain.setAddress(address: "X-" + (addresses.walletAddresses.first ?? ""))
        Constants.PChain.setAddress(address: "P-" + (addresses.walletAddresses.first ?? ""))
        Constants.CChain.setAddress(address: "C-" + (addresses.walletAddresses.first ?? ""))
        
        Constants.XChain.clearBalance()
        Constants.PChain.clearBalance()
    }
    
    class func delegateAvax(info: DelegatorInfo, amount: String, isValidate: Bool = false,
                            completion: @escaping (_ txId: String?, _ tx: String?)->()) {
        
        let typeId:Int32 = isValidate ? 12 : 14
        
        let addresses = AddressesWallet.map({"P-" + $0})
        let amount = Util.double2BigUInt(info.weight, 9)

        guard let exportTo = addresses.first else {return}

        getAddressUTXOs(addresses: addresses, chain: Constants.chainP, sourceChain: Constants.chainP) { utxos in            
            let sorted = Util.sortLexi(utxos:utxos, amount: amount)

            if let availableBalance = Util.calculateChange(utxos: sorted, amount: amount) {
                var outputs: [TransferableOutput] = []

                if availableBalance > 0 {
                    let change = TransferOutput.init(type_id: 7,
                                                     amount:availableBalance,
                                                     locktime: 0,
                                                     threshold: 1,
                                                     addresses: [exportTo])
                    let transferChange = TransferableOutput.init(asset_id: assetId.avaxAssetId.rawValue, output: change)
                    outputs.append(transferChange)
                }
                
                let inputs: [TransferableInput] = sorted
                
                let baseTx = BaseTx.init(type_id: typeId,
                                         network_id: 1,
                                         blockchain_id: BlockchainId.pBlockchain.rawValue,
                                         outputs: outputs,
                                         inputs: inputs,
                                         memo: "")
                
               let output = TransferOutput.init(type_id: 7,
                                                amount: amount,
                                                locktime: 0,
                                                threshold: 1,
                                                addresses: [exportTo])
                
                let lockedOutput = TransferableOutput.init(asset_id: assetId.avaxAssetId.rawValue,
                                                           output: output)
                
                let secpOutputOwner = SECP256K1OutputOwners.init(type_id: 11,
                                                                 locktime: 0,
                                                                 threshold: 1,
                                                                 addresses: [info.rewardAddress])
                
                if let nodeId = info.nodeId {
                    let delegateTx = UnsignedDelegator.init(baseTx: baseTx,
                                                            nodeId: nodeId ,
                                                            startTime: BigUInt(info.startTime),
                                                            endTime: BigUInt(info.endTime),
                                                            weight: amount,
                                                            lockedOuts: [lockedOutput],
                                                            rewardsOwner: secpOutputOwner,
                                                            shares: info.shares)
                    
                    createTx(transaction: TypeEncoder.encodeType(type: delegateTx),
                             chain: Constants.chainP,
                             signatures: getPkeyInd(utxos: sorted),
                             isSegwit: true, completion: completion)
                }
            } else {
                completion(nil, nil)
            }
        }
    }
    
    class func importAvaxC(from: Chain, to: Chain, web3Address: String,
                           completion: @escaping (_ txId: String?, _ tx: String?)->()) {
        
        let addresses = AddressesWallet.map({to.identifier + "-" + $0})
        let blockchainId = to.blockchainId.rawValue
        let source_chain = from.blockchainId.rawValue

        let typeId = to.importAvaxType
        
        let fee: BigUInt = 350937

        getAddressUTXOs(addresses: addresses, chain: to, sourceChain: from) { utxos in
        
            if let availableBalance =  Util.calculateChange(utxos: utxos, amount: 0) {
                
                let sorted = Util.sortLexi(utxos:utxos, amount: 0, sortOnly: true)
                
                if availableBalance < fee {
                    completion(nil, nil)
                    return
                }
                
                let evmOutput = EVMOutput.init(address: web3Address,
                                              amount: availableBalance - fee,
                                              asset_id: assetId.avaxAssetId.rawValue)
                 
                let importTx = BaseImportTxEvm.init(typeID: typeId,
                                                    networkID: 1,
                                                    blockchainID: blockchainId,
                                                    sourceChain: source_chain,
                                                    importedInputs: [evmOutput],
                                                    outs: sorted)
                
                createTx(transaction: TypeEncoder.encodeType(type: importTx),
                         chain: to,
                         signatures: getPkeyInd(utxos: sorted),
                         isSegwit: true, completion: completion)
                
            } else {
                completion(nil, nil)
            }
        }
    }
    
    class func importAvax(from: Chain, to: Chain, completion: @escaping (_ txId: String?, _ tx: String?)->()) {

        var addresses = AddressesWallet.map({to.identifier + "-" + $0})
        let blockchainId = to.blockchainId.rawValue
        let source_chain = from.blockchainId.rawValue

        guard let importTo = addresses.first else { return }

        let typeId = to.importAvaxType
        
        if to.identifier == "X" {
            addresses.append(contentsOf: AddressesIntX.map({"X-" + $0}))
        }
        
        getAddressUTXOs(addresses: addresses, chain: to, sourceChain: from) { utxos in
            let fee: BigUInt = 1000000

            if let availableBalance = Util.calculateChange(utxos: utxos, amount: 0) {
                let sorted = Util.sortLexi(utxos:utxos, amount: 0)
                                   
                if availableBalance < fee {
                    completion(nil, nil)
                    return
                }
                
                let output = TransferOutput.init(type_id: 7,
                                                 amount:availableBalance - fee,
                                                 locktime: 0,
                                                 threshold: 1,
                                                 addresses: [importTo])
                
                let transferDest = TransferableOutput.init(asset_id: assetId.avaxAssetId.rawValue, output: output)
                let transferInput = sorted
                
                let outputs: [TransferableOutput] = [transferDest]
                let inputs: [TransferableInput] = []
                
                
                let export = BaseTx.init(type_id: typeId,
                                             network_id: 1,
                                             blockchain_id: blockchainId,
                                             outputs: outputs,
                                             inputs: inputs,
                                             memo: "EnnoWallet Avalanche Import")
                
                let unsignedTx = UnsignedImportTx.init(base_tx: TypeEncoder.encodeType(type: export),
                                                       source_chain: Util.decodeBase58Check(data: source_chain),
                                                       ins: transferInput)
                                
                createTx(transaction: TypeEncoder.encodeType(type: unsignedTx),
                         chain: to, signatures: getPkeyInd(utxos: sorted), isSegwit: true, completion: completion)
            } else {
                completion(nil, nil)
            }
        }
    }
    
    class func exportToAvaxC(from: Chain, to: Chain, amount: String, web3Address: String, nonce: String,
                             completion: @escaping (_ txId: String?, _ tx: String?)->()) {
        guard let nonce = BigUInt(nonce, radix: 16) else { return }
        
        let fee: BigUInt = 350937
        let amount = Util.double2BigUInt(amount, 9)

        let addresses = AddressesWallet.map({from.identifier + "-" + $0})
        guard let exportTo = addresses.first else {return}
          
        let evmInput = EVMInput.init(address: web3Address,
                                     amount: amount,
                                     asset_id: assetId.avaxAssetId.rawValue,
                                     nonce: nonce)
         
        let output = TransferOutput.init(type_id: 7,
                                         amount: amount - fee,
                                         locktime: 0,
                                         threshold: 1,
                                         addresses: [exportTo])
        
        let transferOutput = TransferableOutput.init(asset_id: assetId.avaxAssetId.rawValue, output: output)
        
        let export = BaseExportTxEvm.init(typeID: from.exportAvaxType, networkID: 1,
                                          blockchainID: from.blockchainId.rawValue,
                                          destinationChain: to.blockchainId.rawValue,
                                          inputs: [evmInput], exportedOutputs: [transferOutput])
                
        createTx(transaction: TypeEncoder.encodeType(type: export),
                 chain: from, signatures: [0], isSegwit: false, completion: completion)
        
    }
    
    class func exportAvax(from: Chain, to: Chain, amount: String, completion: @escaping (_ txId: String?, _ tx: String?)->()) {
 
        let addresses = AddressesWallet.map({from.identifier + "-" + $0})
        guard let exportTo = addresses.first else {return}
        let fee: BigUInt = 1000000
        let destination_chain = to.blockchainId.rawValue
        let amount = Util.double2BigUInt(amount, 9)

        getAddressUTXOs(addresses: addresses, chain: from, sourceChain: from) { utxos in
             
            let sorted = Util.sortLexi(utxos:utxos, amount: amount)
            
            if let availableBalance = Util.calculateChange(utxos: sorted, amount: amount) {
                         
                var outputs: [TransferableOutput] = []

                if availableBalance > 0 {
                    let change = TransferOutput.init(type_id: 7,
                                                     amount:availableBalance,
                                                     locktime: 0,
                                                     threshold: 1,
                                                     addresses: [exportTo])
                    let transferChange = TransferableOutput.init(asset_id: assetId.avaxAssetId.rawValue, output: change)
                    outputs.append(transferChange)
                }
                   
                let output = TransferOutput.init(type_id: 7,
                                                 amount: amount - fee,
                                                 locktime: 0,
                                                 threshold: 1,
                                                 addresses: [exportTo])
                
                let transferDest = TransferableOutput.init(asset_id: assetId.avaxAssetId.rawValue, output: output)
                
                let inputs: [TransferableInput] = sorted
                 
                let export = BaseTx.init(type_id: from.exportAvaxType, network_id: 1,
                                         blockchain_id: from.blockchainId.rawValue,
                                         outputs: outputs, inputs: inputs, memo: "EnnoWallet Avalanche Export")
                
                let unsignedTx = UnsignedExportTx.init(base_tx: TypeEncoder.encodeType(type: export),
                                                       destination_chain: Util.decodeBase58Check(data: destination_chain),
                                                       outs: [transferDest])
                                
                createTx(transaction: TypeEncoder.encodeType(type: unsignedTx),
                         chain: from, signatures: getPkeyInd(utxos: sorted), isSegwit: true, completion: completion)
                
            } else {
                completion(nil, nil)
            }
        }
    }
    
    class func getAtomicTx(chain: Chain, id: String, completion: @escaping (_ txId: String?, _ tx: String?)->()) {
    
        let params = ParamsAtomicTx.init(txID: id, encoding: "hex")
        let req = AtomicTx.init(jsonrpc: "2.0", id: 1, method: chain.getTx, params: params)
        
        RequestService.New(rURL: chain.evm, postData: req.data, sender: IssueTxResult.self) { result, _, _ in
            guard let result = result else { completion(nil, nil); return}
            completion(id, result.result.tx)
        }
    }
    
    class func createTx(transaction: [UInt8], chain: Chain, signatures : [Int], isSegwit: Bool,
                        completion: @escaping (_ txId: String?, _ tx: String?)->()) {
        var bsize = transaction.count
        
        let signature = sign(buffer: Data(transaction), sigs: signatures, isSegwit: isSegwit)
        
        let crdlen = TypeEncoder.byter(input: Int32(signature.count), len: 4)
        bsize += crdlen.count

        var barr = [transaction, crdlen]

        for (_, i) in signature.enumerated() {
            let credID = TypeEncoder.byter(input: Int32(1), len:4)
            let credType = TypeEncoder.byter(input: Int32(9), len: 4)
            barr.append(credType)
            bsize += credID.count
            
            var credBuff: [UInt8] = []
            credBuff.append(contentsOf: credID)
            credBuff.append(contentsOf: i)
            bsize += credBuff.count
            barr.append(credBuff)
        }
        
        var buff:[UInt8] = []
        
        for i in barr {
            buff.append(contentsOf: i)
        }
        
        let tx = Util.hexEncoding(data: buff)
        let url = chain.evm
        let function = chain.issueTx

        let paramsTx = ParamsTx.init(tx: tx, encoding: "hex")
        let issueTx = IssueTx.init(jsonrpc: "2.0", id: 1, method: function, params: paramsTx)
        
        RequestService.New(rURL: url, postData: issueTx.data, sender: IssueTxResult.self) { result, _, _ in
            guard let result = result else { completion(nil, nil); return}
            completion(result.result.txID, result.result.tx)
        }
    }
    
    class func getAddressUTXOs(addresses: [String], chain: Chain, sourceChain: Chain, completion: @escaping (_ utxos: [TransferableInput])->()) {
        
        var allAddresses = addresses
        
        if chain.identifier == "X" {
            allAddresses.append(contentsOf: AddressesIntX.map({"X-" + $0}))
        }
        
        let function = chain.getUTXOs
        let url = chain.evm
        
        let xUTXORequest = PVMRPCModel.init(jsonrpc: "2.0",
                                               id: 1,
                                               method: function,
                                               params: .init(address: nil,
                                                             addresses: allAddresses,
                                                             assetID: nil,
                                                             sourceChain: sourceChain.identifier,
                                                             limit: 200, encoding: "hex", subnetID: nil))
        
        RequestService.New(rURL: url, postData: xUTXORequest.data, sender: UTXOS.self) { [self] result, statusCode, error in
            guard let xAddressChainsList = result else {
                completion([])
                return
            }
                        
            let utxos = xAddressChainsList.result.utxos.map { expression -> TransferableInput in
                let assetId = Util.encodeBase58Check(data: (expression.substr(78, 64) ?? "N/A"))
                let uTXOIndex = expression.substr(70, 8) ?? "N/A"
                
                let locktime = expression.substr(166, 16) ?? "N/A"
                let amount = expression.substr(150, 16) ?? "N/A"
                let txID = Util.encodeBase58Check(data: (expression.substr(6, 64) ?? "N/A"))
                
                let addressLength = Int32(expression.substr(190, 8) ?? "0000", radix: 16) ?? 0
                
                var indices:[Int32] = []
                var addressIndex:[Int] = []
                
                if addressLength > 0 {
                    for item in 0...addressLength - 1 {
                        let ripesha = expression.substr(198 + (Int(item) * 40), 40)
                        let address = Web3Crypto.shared.bech32Address(ripesha: ripesha!.hexToBytes(), hrp: "avax")
                        
                        if let index = AddressesWallet.firstIndex(of: address ?? "N/A") {
                            addressIndex.append(index)
                        } else {
                            let indexAll = AddressesIntX.firstIndex(of: address ?? "N/A")
                            addressIndex.append((indexAll ?? 0) * (-1))
                        }
                        indices.append(Int32(item))
                    }
                }
                
                let amountBigUInt = BigUInt(amount, radix: 16)
                let locktimeBigUInt = BigUInt(locktime, radix: 16)
                let utxoIndexBigUInt = BigUInt(uTXOIndex, radix: 16)
                
                let transferInput = TransferInput.init(type_id: 5,
                                                       amount: amountBigUInt ?? 0,
                                                       addresses: addressIndex,
                                                       locked: locktimeBigUInt ?? 0,
                                                       address_indices: indices)
                
                let transferableInput = TransferableInput.init(tx_id: txID,
                                                               utxo_index: Int32(utxoIndexBigUInt ?? 0),
                                                               asset_id: assetId,
                                                               input: transferInput)
                
                return transferableInput
            }
            completion(utxos)
        }
    }
    
    class func getPkeyInd(utxos: [TransferableInput]) -> [Int] {
        var sigs: [Int] = []
        for item in utxos {
            for address in item.input.addresses {
                sigs.append(address)
            }
        }
        return sigs
    }

    class func getUTXOs(addresses: [String], chain: Chain, completion: @escaping (_ balance: Double) -> ()) {
        guard addresses.count != 0 else {
            completion(0)
            return
        }
        
        let function = chain.getUTXOs
        let url = chain.evm
        
        let xBalanceRequest = PVMRPCModel.init(jsonrpc: "2.0",
                                               id: 1,
                                               method: function,
                                               params: .init(address: nil,
                                                             addresses: addresses,
                                                             assetID: nil,
                                                             sourceChain: nil, limit: 100, encoding: "hex", subnetID: nil))
        
        RequestService.New(rURL: url, postData: xBalanceRequest.data, sender: UTXOS.self) { result, statusCode, error in
            
            guard let output = result else {
                completion(0)
                return }
            
            var totalBalance: BigUInt = 0
            
            for item in output.result.utxos {
                let amount : String = item.substr(150, 16) ?? "N/A"
                totalBalance += BigUInt(amount, radix: 16) ?? .zero
            }
          
            completion(Double.init(totalBalance) / pow(10, Double.init(9)))
        }
    }
    
    class func getValidators(completion: @escaping (_ list: ValidatorsModel?)->()) {
         
        let xBalanceRequest = PVMRPCModel.init(jsonrpc: "2.0",
                                               id: 1,
                                               method: "platform.getCurrentValidators",
                                               params: nil)
        
        let url = "https://api.avax.network/ext/bc/P"
        RequestService.New(rURL: url, postData: xBalanceRequest.data, sender: ValidatorsModel.self) { result, _, _ in
            completion(result)
        }
    }
    
    class func checkChainAddresses(addresses: [String], inner: Bool = false, completion: @escaping (_ result: AddressChains?)->()) {
        
        struct addressBatch: Codable {
            let address: [String]
        }
        
        let batch = addressBatch.init(address: addresses)
        let url = "https://explorerapi.avax.network/v2/addressChains"
        
        RequestService.New(rURL: url, postData: batch.data, sender: AddressChains.self) { result, _, _ in
            completion(result)
        }
    }
    
    private class func sign(buffer: Data, sigs: [Int], isSegwit: Bool = true) -> [[UInt8]] {
        
        var result:[[UInt8]] = []
        
        guard let xPrivKey = !isSegwit ? privateKeyWeb3 : privateKeySegwit else { return [[]]}
        
        for ind in sigs {
            var sign : [UInt8] = []
            
            let accountIndex = ind < 0 ? 1 : 0
            
            if let xPrvAccount = EnnoUtil.Web3Crypto.shared.deriveExtKey(xPrv: xPrivKey, index: accountIndex),
               let xPrvWallet = EnnoUtil.Web3Crypto.shared.deriveExtKey(xPrv: Base58Encoder.encode(xPrvAccount), index: abs(ind)) {
                
                let privKey:[UInt8] = Array(xPrvWallet[46...77])
                let hash = CryptoUtil.shared.sha256(input: buffer.bytes)
                
                if let signature = try? Web3Crypto.shared.Web3Sign(privateKey: privKey, message: hash, hashSHA3: false) {
                    sign.append(contentsOf: signature.r)
                    sign.append(contentsOf: signature.s)
                    sign.append(UInt8(signature.v))
                }
                result.append(sign)
            }
        }
        
        return result
    }
    
    class func getPlatformStake(addresses: [String], completion: @escaping ()->()) {
         
         let xBalanceRequest = PVMRPCModel.init(jsonrpc: "2.0",
                                                id: 1,
                                                method: "platform.getStake",
                                                params: .init(address: nil, addresses: addresses, assetID: nil, sourceChain: nil, limit: 100, encoding: "hex", subnetID: nil))
         
         RequestService.New(rURL: Constants.chainP.evm, postData: xBalanceRequest.data, sender: GetStaked.self) { result,_,_ in
             guard let StakeAmount = result else {
                 completion()
                 return }
             if let stake = Double.init(StakeAmount.result.staked) {
                 Constants.PChain.setStakedBalance(stakedBalance: stake / pow(10, Double.init(9)))
             }
             
             completion()
         }
     }
     
}
