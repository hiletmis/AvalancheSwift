//
//  UnsignedImportTx.swift
//  
//
//  Created by Hayrettin İletmiş on 31.03.2023.
//

import Foundation
import BigInteger

// MARK: - Unsigned Import Tx
public struct UnsignedImportTx: Codable {
    public let base_tx: [UInt8]
    public let source_chain: [UInt8]
    public let ins: [TransferableInput]
    
    init(base_tx: [UInt8], source_chain: [UInt8], ins: [TransferableInput]) {
        self.base_tx = base_tx
        self.source_chain = source_chain
        self.ins = ins
    }
    
    init?(utxos: [TransferableInput], fee: BigUInt, importTo: String, typeId: Int32, from: String, to: String) {
        
        if let availableBalance = Util.calculateChange(utxos: utxos, amount: 0) {
            if availableBalance < fee { return nil }
            
            let output = TransferOutput.init(amount:availableBalance - fee, addresses: [importTo])
            
            let transferDest = TransferableOutput.init(asset_id: assetId.avaxAssetId.rawValue, output: output)
            
            let outputs: [TransferableOutput] = [transferDest]
            let inputs: [TransferableInput] = []
            
            
            let export = BaseTx.init(type_id: typeId, network_id: 1, blockchain_id: to, outputs: outputs, inputs: inputs,
                                     memo: "EnnoWallet Avalanche Import")
            
            self.init(base_tx: TypeEncoder.encodeType(type: export), source_chain: Util.decodeBase58Check(data: from), ins: utxos)
            
        }
        return nil
    }
}
