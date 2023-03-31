//
//  BaseExportTxEvm.swift
//  
//
//  Created by Hayrettin İletmiş on 31.03.2023.
//

import Foundation
import BigInteger

// MARK: - ExportAvax-C
public struct BaseExportTxEvm: Codable {
    public let typeID: Int32
    public let networkID: Int32
    public let blockchainID: String
    public let destinationChain: String
    public let inputs: [EVMInput]
    public let exportedOutputs: [TransferableOutput]
    
    init(typeID: Int32, networkID: Int32, blockchainID: String, destinationChain: String, inputs: [EVMInput], exportedOutputs: [TransferableOutput]) {
        self.typeID = typeID
        self.networkID = networkID
        self.blockchainID = blockchainID
        self.destinationChain = destinationChain
        self.inputs = inputs
        self.exportedOutputs = exportedOutputs
    }
    
    init(web3Address:String, amount: BigUInt, nonce: BigUInt, exportTo: String, fee: BigUInt, typeId: Int32, from: String, to: String) {
        let evmInput = EVMInput.init(address: web3Address, amount: amount, asset_id: assetId.avaxAssetId.rawValue, nonce: nonce)
        let output = TransferOutput.init(amount: amount - fee, addresses: [exportTo])
        let transferOutput = TransferableOutput.init(asset_id: assetId.avaxAssetId.rawValue, output: output)
        
        self.init(typeID: typeId, networkID: 1, blockchainID: from, destinationChain: to, inputs: [evmInput], exportedOutputs: [transferOutput])
    }
}
