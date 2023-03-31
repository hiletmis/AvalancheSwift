//
//  UnsignedExportTx.swift
//  
//
//  Created by Hayrettin İletmiş on 31.03.2023.
//

import Foundation
import BigInteger

// MARK: - Unsigned Export Tx
public struct UnsignedExportTx: Codable {
    public let base_tx: [UInt8]
    public let destination_chain: [UInt8]
    public let outs: [TransferableOutput]
    
    init(base_tx: [UInt8], destination_chain: [UInt8], outs: [TransferableOutput]) {
        self.base_tx = base_tx
        self.destination_chain = destination_chain
        self.outs = outs
    }
    
    init?(utxos: [TransferableInput], amount: BigUInt, exportTo: String, fee: BigUInt, type: Int32, from: String, to: String) {
        
        if let availableBalance = Util.calculateChange(utxos: utxos, amount: amount) {
            
            var outputs: [TransferableOutput] = []
            
            if availableBalance > 0 {
                let change = TransferOutput.init(amount:availableBalance, addresses: [exportTo])
                let transferChange = TransferableOutput.init(asset_id: assetId.avaxAssetId.rawValue, output: change)
                outputs.append(transferChange)
            }
            
            let output = TransferOutput.init(amount: amount - fee, addresses: [exportTo])
            let transferDest = TransferableOutput.init(asset_id: assetId.avaxAssetId.rawValue, output: output)
            let inputs: [TransferableInput] = utxos
            let export = BaseTx.init(type_id: type,
                                     network_id: 1,
                                     blockchain_id: from,
                                     outputs: outputs, inputs: inputs, memo: "EnnoWallet Avalanche Export")
            
            self.init(base_tx: TypeEncoder.encodeType(type: export),
                      destination_chain: Util.decodeBase58Check(data: to),
                      outs: [transferDest])
        } else {
            return nil
        }
    }
}
