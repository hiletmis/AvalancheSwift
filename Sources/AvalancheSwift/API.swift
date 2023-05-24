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
    private static let fee: BigUInt = 350937
    private static let segwitFee: BigUInt = 1000000
    
    private static let credID: [UInt8] = [0,0,0,1]
    private static let credType: [UInt8] = [0,0,0,9]

    class func checkState(delegate: AvalancheInitDelegate?) {
        
        Constants.XChain.clearBalance()
        Constants.PChain.clearBalance()
        Constants.CChain.clearBalance()
        
        var xRequestBatch: [String] = []
        var pRequestBatch: [String] = []
        var xIntRequestBatch: [String] = []
        
        for item in AddressesWallet {
            xRequestBatch.append("X-" + item)
            pRequestBatch.append("P-" + item)
        }
        
        DispatchQueue.global(qos: .background).async  {
            getUTXOs(addresses: xRequestBatch, chain: Constants.chainX) { balance in
                Constants.XChain.addBalance(balance: balance, availableBalance: balance)
                delegate?.balanceInitialized(chain: Constants.XChain)
            }
        }
        
        DispatchQueue.global(qos: .background).async  {
            getUTXOs(addresses: pRequestBatch, chain: Constants.chainP) { balance in
                Constants.PChain.addBalance(balance: balance, availableBalance: balance)
                delegate?.balanceInitialized(chain: Constants.PChain)
                
                getPlatformStake(addresses: pRequestBatch) {
                    delegate?.delegationInitialized(chain: Constants.PChain)
                }
            }
        }
       
        for item in AddressesIntX {
            xIntRequestBatch.append("X-" + item)
        }
        
        DispatchQueue.global(qos: .background).async  {
            getUTXOs(addresses: xIntRequestBatch, chain: Constants.chainX) { balance in
                Constants.XChain.addBalance(balance: balance, availableBalance: balance)
                delegate?.balanceInitialized(chain: Constants.XChain)
            }
        }
        
    }

    class func getXBatch(_ seed: String, _ accountIndex: Int = 0) -> [String] {
        var addresses:[String] = []
                
        if let xPrv = CryptoUtil.shared.web3xPrv(seed: seed, path: "m/44\'/9000\'/0\'") {
            let xAccountDepth = Web3Crypto.shared.deriveExtKey(xPrv: xPrv, index: accountIndex)
            
            for i in 0..<50 {
                let xAddressDepth = Web3Crypto.shared.deriveExtKey(xPrv: Base58Encoder.encode(xAccountDepth!), index: i)
                let address = Web3Crypto.shared.bech32Address(privKey: Array(xAddressDepth![46...77]), hrp: "avax")
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
        
        let addresses = AddressesWallet.map({"P-" + $0})
        let amount = Util.double2BigUInt(info.weight, 9)

        guard let exportTo = addresses.first else {return}

        getAddressUTXOs(addresses: addresses, chain: Constants.chainP, sourceChain: Constants.chainP) { utxos in            
            let sorted = Util.sortLexi(utxos:utxos, amount: amount)

            if let delegateTx = UnsignedDelegator.init(info: info, utxos: sorted, amount: amount, typeId: isValidate ? 12 : 14, exportTo: exportTo) {
                createTx(transaction: TypeEncoder.encodeType(type: delegateTx),
                         chain: Constants.chainP,
                         signatures: getPkeyInd(utxos: sorted),
                         isSegwit: true, completion: completion)
            } else {
                completion(nil, nil)
            }
        }
    }
    
    class func importAvaxC(from: Chain, to: Chain, web3Address: String,
                           completion: @escaping (_ txId: String?, _ tx: String?)->()) {
        
        getAddressUTXOs(addresses: AddressesWallet.map({to.identifier + "-" + $0}), chain: to, sourceChain: from) { utxos in
            let sorted = Util.sortLexi(utxos:utxos, amount: 0, sortOnly: true)
            
            if let importTx = BaseImportTxEvm.init(utxos: sorted, fee: fee, web3Address: web3Address, typeId: to.importAvaxType,
                                                   from: from.blockchainId.rawValue, to: to.blockchainId.rawValue) {
                
                createTx(transaction: TypeEncoder.encodeType(type: importTx), chain: to, signatures: getPkeyInd(utxos: sorted),
                         isSegwit: true, completion: completion)
            } else {
                completion(nil, nil)
            }
        }
    }
    
    class func importAvax(from: Chain, to: Chain, completion: @escaping (_ txId: String?, _ tx: String?)->()) {

        var addresses = AddressesWallet.map({to.identifier + "-" + $0})
        guard let importTo = addresses.first else { return }

        if to.identifier == "X" {
            addresses.append(contentsOf: AddressesIntX.map({"X-" + $0}))
        }
        
        getAddressUTXOs(addresses: addresses, chain: to, sourceChain: from) { utxos in
            let sorted = Util.sortLexi(utxos:utxos, amount: 0)

            if let unsignedTx = UnsignedImportTx.init(utxos: sorted, fee: segwitFee, importTo: importTo, typeId: to.importAvaxType, from: from.blockchainId.rawValue, to: to.blockchainId.rawValue) {
                
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
        let amount = Util.double2BigUInt(amount, 9)
        let addresses = AddressesWallet.map({from.identifier + "-" + $0})
        guard let exportTo = addresses.first else {return}
          
        let export = BaseExportTxEvm.init(web3Address: web3Address, amount: amount, nonce: nonce, exportTo: exportTo, fee: fee, typeId: from.exportAvaxType, from: from.blockchainId.rawValue, to: to.blockchainId.rawValue)
                
        createTx(transaction: TypeEncoder.encodeType(type: export),
                 chain: from, signatures: [0], isSegwit: false, completion: completion)
    }
    
    class func exportAvax(from: Chain, to: Chain, amount: String, completion: @escaping (_ txId: String?, _ tx: String?)->()) {
 
        let addresses = AddressesWallet.map({from.identifier + "-" + $0})
        guard let exportTo = addresses.first else {return}
        let amount = Util.double2BigUInt(amount, 9)

        getAddressUTXOs(addresses: addresses, chain: from, sourceChain: from) { utxos in
            let sorted = Util.sortLexi(utxos:utxos, amount: amount)
            if let unsignedTx = UnsignedExportTx(utxos: sorted,
                                                 amount: amount,
                                                 exportTo: exportTo,
                                                 fee: segwitFee,
                                                 type: from.exportAvaxType,
                                                 from: from.blockchainId.rawValue,
                                                 to: to.blockchainId.rawValue) {
                
                createTx(transaction: TypeEncoder.encodeType(type: unsignedTx),
                         chain: from, signatures: getPkeyInd(utxos: sorted), isSegwit: true, completion: completion)
            } else {
                completion(nil, nil)
            }
        }
    }
    
    class func getAtomicTx(chain: Chain, id: String, completion: @escaping (_ txId: String?, _ tx: String?)->()) {
        RequestService.New(rURL: chain.evm,
                           postData: AtomicTx.init(method: chain.getTx, params: .init(txID: id)).data,
                           sender: IssueTxResult.self) { result, _, _ in
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
            let credBuff = credID + i
            
            bsize += credID.count
            bsize += credBuff.count
            
            barr.append(credType)
            barr.append(credBuff)
        }
        
        var buff:[UInt8] = []
        
        for i in barr {
            buff.append(contentsOf: i)
        }
        
        RequestService.New(rURL: chain.evm,
                           postData: IssueTx.init(method: chain.issueTx, params: .init(tx: Util.hexEncoding(data: buff))).data,
                           sender: IssueTxResult.self) { result, _, _ in
            
            guard let result = result else { completion(nil, nil); return}
            completion(result.result.txID, result.result.tx)
        }
    }
    
    class func getAddressUTXOs(addresses: [String], chain: Chain, sourceChain: Chain, completion: @escaping (_ utxos: [TransferableInput])->()) {
        
        var allAddresses = addresses
        
        if chain.identifier == "X" {
            allAddresses.append(contentsOf: AddressesIntX.map({"X-" + $0}))
        }
        
        let xUTXORequest = PVMRPCModel.init(method: chain.getUTXOs,
                                            params: .init(addresses: allAddresses, limit: 200, sourceChain: sourceChain.identifier))
        
        RequestService.New(rURL: chain.evm, postData: xUTXORequest.data, sender: UTXOS.self) { result, statusCode, error in
            guard let xAddressChainsList = result else {
                completion([])
                return
            }
                        
            let utxos = xAddressChainsList.result.utxos.map { expression -> TransferableInput in
                TransferableInput.init(expression: expression, addresses: AddressesWallet, internalAddresses: AddressesIntX)
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
        
        RequestService.New(rURL: chain.evm,
                           postData: PVMRPCModel.init(method: chain.getUTXOs, params: .init(addresses: addresses, limit: 100)).data,
                           sender: UTXOS.self) { result, statusCode, error in
            
            guard let output = result else {
                completion(0)
                return
            }
            completion(output.result.toDouble())
        }
    }
    
    class func getValidators(completion: @escaping (_ list: ValidatorsModel?)->()) {
        RequestService.New(rURL: ApiUrls.getValidatorsURL.rawValue,
                           postData: PVMRPCModel.init(method: .platformGetCurrentValidators).data,
                           sender: ValidatorsModel.self) { result, _, _ in
            completion(result)
        }
    }
    
    class func checkChainAddresses(addresses: [String], inner: Bool = false, completion: @escaping (_ result: AddressChains?)->()) {
        RequestService.New(rURL: ApiUrls.chainAddressBatch.rawValue,
                           postData: AddressBatchRequest.init(address: addresses).data,
                           sender: AddressChains.self) { result, _, _ in
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
         RequestService.New(rURL: Constants.chainP.evm,
                            postData: PVMRPCModel.init(method: .platformGetStake, params: .init(addresses: addresses, limit: 100)).data,
                            sender: GetStaked.self) { result,_,_ in
             completion()
         }
     }
}
