//
//  File 2.swift
//  
//
//  Created by Hayrettin İletmiş on 16.03.2023.
//

import Foundation
import EnnoUtil
import BigInteger

class TypeEncoder {
    
    class func byter(input: Int32, len: Int) -> [UInt8] {
        return withUnsafeBytes(of: input.bigEndian, Array.init)
    }
    
    class func byter(input: String) -> [UInt8] {
        return input.bytes
    }
    
    class func byter(input: BigUInt, len: Int) -> [UInt8] {
        var bytes:[UInt8] = input.serialize().bytes

        for _ in 0...(7 - bytes.count) {
            bytes.insert(0x00, at: 0)
        }
        
        return bytes
    }
     
    class func createOutput(amount: String) -> TransferableOutput? {
        return nil
    }
    
    class func encodeType(type: Any) -> [UInt8]  {
    
    var encodedType:[UInt8] = []

    if let type = type as? [TransferableOutput] {
        let outputSize = byter(input: Int32(type.count), len: 4)
        encodedType.append(contentsOf: outputSize)
        
        if type.count == 0 {
            return encodedType
        }
        
        for item in type {
            let assetId = Util.decodeBase58Check(data: item.asset_id)
            let output = encodeType(type: item.output)
            encodedType.append(contentsOf: assetId)
            encodedType.append(contentsOf: output)

        }
        
    }
        
    if let type = type as? SECP256K1OutputOwners {
        
        let typeId = byter(input: type.type_id, len: 4)
        let locktime = byter(input: type.locktime, len: 8)
        let threshold = byter(input: type.threshold, len: 4)
        let addressSize = byter(input: Int32(type.addresses.count), len: 4)
        
        encodedType.append(contentsOf: typeId)
        encodedType.append(contentsOf: locktime)
        encodedType.append(contentsOf: threshold)
        encodedType.append(contentsOf: addressSize)
        
        for address in type.addresses {
            encodedType.append(contentsOf: Util.decodeSegwit(address: address))
        }
    }
    
    if let type = type as? [TransferableInput] {
        let inputSize = byter(input: Int32(type.count), len: 4)
        encodedType.append(contentsOf: inputSize)
        
        for item in type {
            let txId = Util.decodeBase58Check(data: item.tx_id)
            let assetId = Util.decodeBase58Check(data: item.asset_id)
            let utxoIndex = byter(input: item.utxo_index, len: 4)
            let input = encodeType(type:item.input)
            
            encodedType.append(contentsOf: txId)
            encodedType.append(contentsOf: utxoIndex)
            encodedType.append(contentsOf: assetId)
            encodedType.append(contentsOf: input)
        }
    }
    
    if let type = type as? String {
        let size = byter(input: Int32(type.count), len: 4)
        let value = byter(input: type)
        encodedType.append(contentsOf: size)
        encodedType.append(contentsOf: value)
        
    }
    
    if let type = type as? TransferInput {
        let typeId = byter(input: type.type_id, len: 4)
        let amount = byter(input: type.amount, len: 8)
        let addressIndSize = byter(input: Int32(type.address_indices.count), len: 4)
        
        encodedType.append(contentsOf: typeId)
        encodedType.append(contentsOf: amount)
        encodedType.append(contentsOf: addressIndSize)
            
        for item in type.address_indices {
            let ind = byter(input: item, len: 4)
            encodedType.append(contentsOf: ind)
        }
    }
    
    if let type = type as? TransferOutput {
        let typeId = byter(input: type.type_id, len: 4)
        let amount = byter(input: type.amount, len: 8)
        let locktime = byter(input: type.locktime, len: 8)
        let threshold = byter(input: type.threshold, len: 4)
        let addressSize = byter(input: Int32(type.addresses.count), len: 4)
        
        encodedType.append(contentsOf: typeId)
        encodedType.append(contentsOf: amount)
        encodedType.append(contentsOf: locktime)
        encodedType.append(contentsOf: threshold)
        encodedType.append(contentsOf: addressSize)
        
        for item in type.addresses {
            encodedType.append(contentsOf: Util.decodeSegwit(address: item))
        }
    }
    
    if let type = type as? UnsignedImportTx {
        var pChain: [UInt8] = []
        var codecId: [UInt8] = []
            
        for _ in 0...31 {
            pChain.insert(0x00, at: 0)
        }
        
        for _ in 0...1 {
            codecId.insert(0x00, at: 0)
        }
        
        let outs = encodeType(type: type.ins)
        
        encodedType.append(contentsOf: codecId)
        encodedType.append(contentsOf: type.base_tx)
        
        type.source_chain == nil
        ? encodedType.append(contentsOf: pChain)
        : encodedType.append(contentsOf: type.source_chain!)

        encodedType.append(contentsOf: outs)

    }
    
    if let type = type as? [EVMInput] {
        
        let inputSize = byter(input: Int32(type.count), len: 4)
        encodedType.append(contentsOf: inputSize)
        
        for item in type {
            let address = String(item.address.dropFirst(2)).hexToBytes()
            let amount = byter(input: item.amount, len: 8)
            let assetId = Util.decodeBase58Check(data: item.asset_id)
            let nonce = byter(input: item.nonce, len: 4)
                
            encodedType.append(contentsOf: address)
            encodedType.append(contentsOf: amount)
            encodedType.append(contentsOf: assetId)
            encodedType.append(contentsOf: nonce)
        }

    }
    
    if let type = type as? [EVMOutput] {
        
        let inputSize = byter(input: Int32(type.count), len: 4)
        encodedType.append(contentsOf: inputSize)
        
        for item in type {
            let address = String(item.address.dropFirst(2)).hexToBytes()
            let amount = byter(input: item.amount, len: 8)
            let assetId = Util.decodeBase58Check(data: item.asset_id)
                
            encodedType.append(contentsOf: address)
            encodedType.append(contentsOf: amount)
            encodedType.append(contentsOf: assetId)
        }

    }
    
    if let type = type as? UnsignedExportTx {
        var pChain: [UInt8] = []
        var codecId: [UInt8] = []
            
        for _ in 0...31 {
            pChain.insert(0x00, at: 0)
        }
        
        for _ in 0...1 {
            codecId.insert(0x00, at: 0)
        }
        
        let outs = encodeType(type: type.outs)
        
        encodedType.append(contentsOf: codecId)
        encodedType.append(contentsOf: type.base_tx)
        
        type.destination_chain == nil
        ? encodedType.append(contentsOf: pChain)
        : encodedType.append(contentsOf: type.destination_chain!)

        encodedType.append(contentsOf: outs)

    }
    
    return encodedType
}
    
    class func encoder(type: Any) -> [UInt8]? {
    
    var unsignedTx:[UInt8] = []
    
    if let type = type as? BaseTx {
        
        var pchain: [UInt8] = []

        for _ in 0...31 {
            pchain.insert(0x00, at: 0)
        }
        
        let typeId = byter(input: type.type_id, len: 4)
        let networkId = byter(input: type.network_id, len: 4)
        let blockchainId = Util.decodeBase58Check(data: type.blockchain_id)
        let outputs = encodeType(type: type.outputs)
        let inputs = encodeType(type: type.inputs)
        let memo = encodeType(type: type.memo)
        
        unsignedTx.append(contentsOf: typeId)
        unsignedTx.append(contentsOf: networkId)
        
        blockchainId == []
        ? unsignedTx.append(contentsOf: pchain)
        : unsignedTx.append(contentsOf: blockchainId)
        
        unsignedTx.append(contentsOf: outputs)
        unsignedTx.append(contentsOf: inputs)
        unsignedTx.append(contentsOf: memo)
    }

    if let type = type as? UnsignedDelegator {
        
        var codecId: [UInt8] = []
        
        for _ in 0...1 {
            codecId.insert(0x00, at: 0)
        }
        
        let nodeIdSanitation = type.nodeId.split(separator: "-")
        
        let baseTx = encoder(type: type.baseTx) ?? []
        let nodeId = Util.decodeBase58Check(data: String(nodeIdSanitation[1]))
        let startTime = byter(input: type.startTime, len: 8)
        let endTime = byter(input: type.endTime, len: 8)
        let weight = byter(input: type.weight, len: 8)
        let lockedOuts = encodeType(type: type.lockedOuts)
        let rewardsOwner = encodeType(type: type.rewardsOwner)
        
        unsignedTx.append(contentsOf: codecId)
        unsignedTx.append(contentsOf: baseTx)
        unsignedTx.append(contentsOf: nodeId)
            
        unsignedTx.append(contentsOf: startTime)
        unsignedTx.append(contentsOf: endTime)
        unsignedTx.append(contentsOf: weight)
        
        unsignedTx.append(contentsOf: lockedOuts)
        unsignedTx.append(contentsOf: rewardsOwner)
        
        if let shares = type.shares {
            let sharesFee = byter(input: shares, len: 4)
            unsignedTx.append(contentsOf: sharesFee)
        }
        
    }
    
    if let type = type as? BaseExportTxEvm {

        var pchain: [UInt8] = []
        var codecId: [UInt8] = []

        for _ in 0...31 {
            pchain.insert(0x00, at: 0)
        }
            
        for _ in 0...1 {
            codecId.insert(0x00, at: 0)
        }
            
        let typeId = byter(input: type.typeID, len: 4)
        let networkId = byter(input: type.networkID, len: 4)
        let blockchainId = Util.decodeBase58Check(data: type.blockchainID)
        let destinationChain = Util.decodeBase58Check(data: type.destinationChain)
        let inputs = encodeType(type: type.inputs)
        let outputs = encodeType(type: type.exportedOutputs)
        
        unsignedTx.append(contentsOf: codecId)
        unsignedTx.append(contentsOf: typeId)
        unsignedTx.append(contentsOf: networkId)
        
        blockchainId == []
        ? unsignedTx.append(contentsOf: pchain)
        : unsignedTx.append(contentsOf: blockchainId)
        
        destinationChain == []
        ? unsignedTx.append(contentsOf: pchain)
        : unsignedTx.append(contentsOf: destinationChain)
        
        unsignedTx.append(contentsOf: inputs)
        unsignedTx.append(contentsOf: outputs)
        
    }
        
    if let type = type as? BaseImportTxEvm {

        var pchain: [UInt8] = []
        var codecId: [UInt8] = []

        for _ in 0...31 {
            pchain.insert(0x00, at: 0)
        }
            
        for _ in 0...1 {
            codecId.insert(0x00, at: 0)
        }
            
        let typeId = byter(input: type.typeID, len: 4)
        let networkId = byter(input: type.networkID, len: 4)
        let blockchainId = Util.decodeBase58Check(data: type.blockchainID)
        let sourceChain = Util.decodeBase58Check(data: type.sourceChain)
        let importedInputs = encodeType(type: type.importedInputs)
        let outs = encodeType(type: type.outs)
        
        unsignedTx.append(contentsOf: codecId)
        unsignedTx.append(contentsOf: typeId)
        unsignedTx.append(contentsOf: networkId)
        
        blockchainId == []
        ? unsignedTx.append(contentsOf: pchain)
        : unsignedTx.append(contentsOf: blockchainId)
        
        sourceChain == []
        ? unsignedTx.append(contentsOf: pchain)
        : unsignedTx.append(contentsOf: sourceChain)
            
        unsignedTx.append(contentsOf: outs)
        unsignedTx.append(contentsOf: importedInputs)
        
    }
        
    return unsignedTx
}
    
    
    
    
}
