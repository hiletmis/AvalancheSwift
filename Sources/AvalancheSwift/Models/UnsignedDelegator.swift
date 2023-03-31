//
//  UnsignedDelegator.swift
//  
//
//  Created by Hayrettin İletmiş on 31.03.2023.
//

import Foundation
import BigInteger

// MARK: - UnsignedDelegator
public struct UnsignedDelegator: Codable {
    public let baseTx: BaseTx
    public let nodeId: String
    public let startTime: BigUInt
    public let endTime: BigUInt
    public let weight: BigUInt
    public let lockedOuts: [TransferableOutput]
    public let rewardsOwner: SECP256K1OutputOwners
    public let shares: Int32?
    
    init(baseTx: BaseTx, nodeId: String, startTime: BigUInt, endTime: BigUInt, weight: BigUInt, lockedOuts: [TransferableOutput], rewardsOwner: SECP256K1OutputOwners, shares: Int32?) {
        self.baseTx = baseTx
        self.nodeId = nodeId
        self.startTime = startTime
        self.endTime = endTime
        self.weight = weight
        self.lockedOuts = lockedOuts
        self.rewardsOwner = rewardsOwner
        self.shares = shares
    }
    
    init?(info: DelegatorInfo, utxos: [TransferableInput], amount: BigUInt, typeId: Int32, exportTo: String) {
        
        if let availableBalance = Util.calculateChange(utxos: utxos, amount: amount) {
            var outputs: [TransferableOutput] = []
            
            if availableBalance > 0 {
                let change = TransferOutput.init(amount:availableBalance, addresses: [exportTo])
                let transferChange = TransferableOutput.init(asset_id: assetId.avaxAssetId.rawValue, output: change)
                outputs.append(transferChange)
            }
            
            let inputs: [TransferableInput] = utxos
            let baseTx = BaseTx.init(type_id: typeId,
                                     network_id: 1,
                                     blockchain_id: BlockchainId.pBlockchain.rawValue,
                                     outputs: outputs,
                                     inputs: inputs,
                                     memo: "")
            
            let output = TransferOutput.init(amount: amount, addresses: [exportTo])
            let lockedOutput = TransferableOutput.init(asset_id: assetId.avaxAssetId.rawValue, output: output)
            let secpOutputOwner = SECP256K1OutputOwners.init(addresses: [info.rewardAddress])
            
            if let nodeId = info.nodeId {
                self.init(baseTx: baseTx, nodeId: nodeId, startTime: BigUInt(info.startTime), endTime: BigUInt(info.endTime),
                          weight: amount, lockedOuts: [lockedOutput], rewardsOwner: secpOutputOwner, shares: info.shares)
            }
        }
        return nil
                
    }
}
