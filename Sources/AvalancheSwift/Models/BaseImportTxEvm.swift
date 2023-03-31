//
//  BaseImportTxEvm.swift
//  
//
//  Created by Hayrettin İletmiş on 31.03.2023.
//

import Foundation
import BigInteger

// MARK: - ImportAvax-C
public struct BaseImportTxEvm: Codable {
    public let typeID: Int32
    public let networkID: Int32
    public let blockchainID: String
    public let sourceChain: String
    public let importedInputs: [EVMOutput]
    public let outs: [TransferableInput]
    
    init(typeID: Int32, networkID: Int32, blockchainID: String, sourceChain: String, importedInputs: [EVMOutput], outs: [TransferableInput]) {
        self.typeID = typeID
        self.networkID = networkID
        self.blockchainID = blockchainID
        self.sourceChain = sourceChain
        self.importedInputs = importedInputs
        self.outs = outs
    }
    
    init?(utxos: [TransferableInput], fee: BigUInt, web3Address:String, typeId: Int32, from: String, to: String) {
        if let availableBalance = Util.calculateChange(utxos: utxos, amount: 0) {
            if availableBalance < fee { return nil }
            
            let evmOutput = EVMOutput.init(address: web3Address, amount: availableBalance - fee,
                                           asset_id: assetId.avaxAssetId.rawValue)
            
            return self.init(typeID: typeId, networkID: 1, blockchainID: to, sourceChain: from, importedInputs: [evmOutput], outs: utxos)
        }
        return nil
    }
}
