//
//  API.swift
//  
//
//  Created by Hayrettin İletmiş on 16.03.2023.
//

import Foundation
import BigInteger

class API {
    
    public static var indexAddressesWallet:[String] = []
    public static var indexAddressesIntX:[String] = []
    
    public static var AddressesWallet:[String] = []
    public static var AddressesIntX:[String] = []
     
    class func delegateAvax(info: delegatorInfo, amount: BigUInt, isValidate: Bool = false, completion: @escaping (_ transaction: UnsignedDelegator?)->()) {
        let typeId:Int32 = isValidate ? 12 : 14
        
        let addresses = AddressesWallet.map({"P-" + $0})

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
                     
                    completion(delegateTx)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    class func importAvaxC(from: Chain, to: Chain, web3Address: String, completion: @escaping (_ transaction: BaseImportTxEvm?)->()) {
        
        let addresses = AddressesWallet.map({to.identifier + "-" + $0})
        let blockchainId = to.blockchainId.rawValue
        let source_chain = from.blockchainId.rawValue

        let typeId = to.importAvaxType
        
        let fee: BigUInt = 350937

        getAddressUTXOs(addresses: addresses, chain: to, sourceChain: from) { utxos in
        
            if let availableBalance =  Util.calculateChange(utxos: utxos, amount: 0) {
                
                let sorted = Util.sortLexi(utxos:utxos, amount: 0, sortOnly: true)
                
                if availableBalance < fee {
                    completion(nil)
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
                
                completion(importTx)
            } else {
                completion(nil)
            }
             
        }
    }
    
    class func importAvax(from: Chain, to: Chain, completion: @escaping (_ transaction: UnsignedImportTx?)->()) {

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
                    completion(nil)
                    return
                }
                
                let output = TransferOutput.init(type_id: 7,
                                                 amount:availableBalance - fee,
                                                 locktime: 0,
                                                 threshold: 1,
                                                 addresses: [to.identifier + "-" + importTo])
                
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
                
                if let tx = TypeEncoder.encoder(type: export) {
                    let unsignedTx = UnsignedImportTx.init(base_tx: tx,
                                                           source_chain: Util.decodeBase58Check(data: source_chain),
                                                           ins: transferInput)
                    
                    completion(unsignedTx)

                }
            } else {
                completion(nil)
                print("amountError")
            }
        }
    }
    
    class func exportToAvaxC(from: Chain, to: Chain, amount: BigUInt, web3Address: String, nonce: BigUInt, completion: @escaping (_ transaction: BaseExportTxEvm?)->()) {
        
        let fee: BigUInt = 350937
        
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
        
        completion(export)
    }
    
    class func exportAvax(from: Chain, to: Chain, amount: BigUInt, completion: @escaping (_ transaction: UnsignedExportTx?)->()) {
 
        let addresses = AddressesWallet.map({from.identifier + "-" + $0})
        guard let exportTo = addresses.first else {return}
        let fee: BigUInt = 1000000
        let destination_chain = to.blockchainId.rawValue

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
                
                if let tx = TypeEncoder.encoder(type: export) {
                    let unsignedTx = UnsignedExportTx.init(base_tx: tx,
                                                           destination_chain: Util.decodeBase58Check(data: destination_chain),
                                                           outs: [transferDest])
                    
                    completion(unsignedTx)

                }
            } else {
                completion(nil)
                print("amountError")
            }
        }
    }
    
    class func createTx(transaction: [UInt8], chain: Chain, signature : [[UInt8]], isSegwit: Bool, completion: @escaping (_ transaction: IssueTxResult?)->()) {
        var bsize = transaction.count
        
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
            completion(result)
        }
    }
    
    class func getAddressUTXOs(addresses: [String], chain: Chain, sourceChain: Chain, completion: @escaping (_ utxos: [TransferableInput])->()) {
        
        var allAddresses = addresses
        
        if chain.identifier == "X" {
            allAddresses.append(contentsOf: AddressesIntX.map({"X-" + $0}))
        }
        
        let function = chain.getUTXOs
        let url = chain.evm
        let list = chain.identifier == "X"
        ? indexAddressesWallet : chain.identifier == "P"
        ? indexAddressesWallet : [indexAddressesWallet[0]]
        
        let xUTXORequest = PVMRPCModel.init(jsonrpc: "2.0",
                                               id: 1,
                                               method: function,
                                               params: .init(address: nil,
                                                             addresses: allAddresses,
                                                             assetID: nil,
                                                             sourceChain: sourceChain.identifier,
                                                             limit: 200, encoding: "hex", subnetID: nil))
        
        RequestService.New(rURL: url, postData: xUTXORequest.data, sender: UTXOS.self) { result, statusCode, error in
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
                        let address = expression.substr(198 + (Int(item) * 40), 40)
                        if let index = list.firstIndex(of: address ?? "N/A") {
                            addressIndex.append(index)
                        } else {
                            let indexAll = indexAddressesIntX.firstIndex(of: address ?? "N/A")
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

    class func getUTXOs(addresses: [String], chain: Chain, completion: @escaping (_ balances: Any?, _ locked: Double)->()) {
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
            
            guard let xAddressChains = result else {
                completion(nil, 0)
                return
            }
            
            var totalBalance: BigUInt = 0
            var lockedBalance: BigUInt = 0

            
            _ = xAddressChains.result.utxos.map { expression -> UTXOOutput in
                let codecID = expression.substr(2, 4) ?? "N/A"
                let txID = expression.substr(6, 64) ?? "N/A"
                let uTXOIndex = expression.substr(70, 8) ?? "N/A"
                let assetId = expression.substr(78, 64) ?? "N/A"
                
                let typeID : String = expression.substr(142, 8) ?? "N/A"
                let amount : String = expression.substr(150, 16) ?? "N/A"
                let locktime : String = expression.substr(166, 16) ?? "N/A"
                let threshold : String = expression.substr(182, 8) ?? "N/A"

                let locktimeBigUInt = BigUInt(locktime, radix: 16)

                if locktimeBigUInt == 0 {
                    totalBalance += BigUInt(amount, radix: 16) ?? .zero
                } else {
                    lockedBalance += BigUInt(amount, radix: 16) ?? .zero
                }
                
                let balance = SECP256K1.init(typeID: typeID, amount: amount, locktime: locktime, threshold: threshold)
                return UTXOOutput.init(codecID: codecID, txID: txID, uTXOIndex: uTXOIndex, assetId: assetId, output: balance)
            }
            
            //if chain == "X" {
            //    xAvax.balance = Double.init(totalBalance) / pow(10, Double.init(9))
            //    xAvax.availableBalance = Double.init(totalBalance) / pow(10, Double.init(9))
            //    completion(xAvax, Double.init(lockedBalance) / pow(10, Double.init(9)))
            //}
            //
            //if chain == "P" {
            //    pAvax.balance = Double.init(totalBalance) / pow(10, Double.init(9))
            //    pAvax.availableBalance = Double.init(totalBalance) / pow(10, Double.init(9))
            //    completion(pAvax, Double.init(lockedBalance) / pow(10, Double.init(9)))
            //}
            
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
      
    
}
