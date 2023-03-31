//
//  TransferableInput.swift
//  
//
//  Created by Hayrettin İletmiş on 31.03.2023.
//

import Foundation
import BigInteger
import EnnoUtil

// MARK: - TransferableInput
public struct TransferableInput: Codable {
    public let tx_id: String
    public let utxo_index: Int32
    public let asset_id: String
    public let input: TransferInput
    
    init(tx_id: String, utxo_index: Int32, asset_id: String, input: TransferInput) {
        self.tx_id = tx_id
        self.utxo_index = utxo_index
        self.asset_id = asset_id
        self.input = input
    }
    
    init(expression: String, addresses: [String], internalAddresses:[String]) {
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
                
                if let index = addresses.firstIndex(of: address ?? "N/A") {
                    addressIndex.append(index)
                } else {
                    let indexAll = internalAddresses.firstIndex(of: address ?? "N/A")
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
        
        self.init(tx_id: txID, utxo_index: Int32(utxoIndexBigUInt ?? 0), asset_id: assetId, input: transferInput)
    }
}
