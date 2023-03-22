//
//  Models.swift
//  
//
//  Created by Hayrettin İletmiş on 16.03.2023.
//

import BigInteger
import Foundation

// MARK: - AtomicTx
public struct AtomicTx: Codable {
    let jsonrpc: String
    let id: Int
    let method: String
    let params: ParamsAtomicTx
}

// MARK: - Params
public struct ParamsAtomicTx: Codable {
    let txID, encoding: String
}

// MARK: - IssueTxResult
public struct IssueTxResult: Codable {
    let jsonrpc: String
    let id: Int
    let result: ResultTx
}

// MARK: - Result
public struct ResultTx: Codable {
    let txID: String?
    let tx: String?
}

// MARK: - IssueTx
public struct IssueTx: Codable {
    let jsonrpc: String
    let id: Int
    let method: String
    let params: ParamsTx
}

// MARK: - Params
public struct ParamsTx: Codable {
    let tx, encoding: String
}


// MARK: - NFT
public struct NFTMarket: Codable {
    var name: String
    let address, token, symbol: String
    let id: Int
    var list: Bool
    let iconURL: String
    var tokenUri: String
}

// MARK: - RPCModel
public struct RPCModel: Codable {
    let jsonrpc, method: String
    let params: [String]
    let id: Int
}

// MARK: - PVMRPCModel
public struct PVMRPCModel: Codable {
    let jsonrpc: String
    let id: Int
    let method: String
    let params: Params?
}

// MARK: - Params
public struct Params: Codable {
    let address: String?
    let addresses: [String]?
    let assetID: String?
    let sourceChain: String?
    let limit: Int?
    let encoding: String?
    let subnetID: String?
}

// MARK: - PChainBalance
public struct PChainBalance: Codable {
    let jsonrpc: String
    let result: Result
    let id: Int
}

// MARK: - Result
public struct Result: Codable {
    let balance: String
    let unlocked, lockedStakeable, lockedNotStakeable: String?
}

// MARK: - AddressChains
public struct AddressChains: Codable {
    let addressChains: [String: [String]]
}

// MARK: - UTXOS
public struct UTXOS: Codable {
    let jsonrpc: String
    let result: UTXOResult
    let id: Int
}

// MARK: - Result
public struct UTXOResult: Codable {
    let numFetched: String
    let utxos: [String]
    let endIndex: EndIndex
    let encoding: String
}

// MARK: - EndIndex
public struct EndIndex: Codable {
    let address, utxo: String
}

public struct AddressBalances: Codable {
    let chain: String
    let balance: Double
}

public struct SECP256K1: Codable {
    let typeID: String
    let amount: String
    let locktime: String
    let threshold: String
}

public struct UTXOOutput: Codable {
    let codecID: String
    let txID: String
    let uTXOIndex: String
    let assetId: String
    let output: SECP256K1
}

// MARK: - GetStaked
public struct GetStaked: Codable {
    let jsonrpc: String
    let result: ResultStake
    let id: Int
}

// MARK: - Result
public struct ResultStake: Codable {
    let staked: String
    let stakedOutputs: [String]
    let encoding: String
}

// MARK: - TransferableOutput {
public struct TransferableOutput: Codable {
    let asset_id: String
    let output: TransferOutput
}

// MARK: - TransferOutput
public struct TransferOutput: Codable {
    let type_id: Int32
    let amount: BigUInt
    let locktime: BigUInt
    let threshold: Int32
    let addresses: [String]
}
// MARK: - SECP256K1OutputOwners
public struct SECP256K1OutputOwners: Codable {
    let type_id: Int32
    let locktime: BigUInt
    let threshold: Int32
    let addresses: [String]
}

// MARK: - TransferableInput
public struct TransferableInput: Codable {
    let tx_id: String
    let utxo_index: Int32
    let asset_id: String
    let input: TransferInput
}

// MARK: - TransferInput
public struct TransferInput: Codable {
    let type_id: Int32
    let amount: BigUInt
    let addresses: [Int]
    let locked: BigUInt
    let address_indices: [Int32]
}


// MARK: - ExportAvax-C
public struct BaseExportTxEvm: Codable {
    let typeID: Int32
    let networkID: Int32
    let blockchainID: String
    let destinationChain: String
    let inputs: [EVMInput]
    let exportedOutputs: [TransferableOutput]
}

// MARK: - ImportAvax-C
public struct BaseImportTxEvm: Codable {
    let typeID: Int32
    let networkID: Int32
    let blockchainID: String
    let sourceChain: String
    let importedInputs: [EVMOutput]
    let outs: [TransferableInput]
}


// MARK: - Unsigned Export Tx
public struct UnsignedExportTx: Codable {
    let base_tx: [UInt8]
    let destination_chain: [UInt8]
    let outs: [TransferableOutput]
}

// MARK: - ExportAvax
public struct BaseTx: Codable {
    let type_id: Int32
    let network_id: Int32
    let blockchain_id: String
    let outputs: [TransferableOutput]
    let inputs: [TransferableInput]
    let memo: String
}

 // MARK: - UnsignedDelegator
 public struct UnsignedDelegator: Codable {
     let baseTx: BaseTx
     let nodeId: String
     let startTime: BigUInt
     let endTime: BigUInt
     let weight: BigUInt
     let lockedOuts: [TransferableOutput]
     let rewardsOwner: SECP256K1OutputOwners
     let shares: Int32?
 }

public struct delegatorInfo {
    var nodeId: String?
    var startTime: Int64
    var endTime: Int64
    var weight: String
    var rewardAddress: String
    var shares: Int32?
}

// MARK: - Stake
public struct StakeTx: Codable {
    let lockedOuts: [TransferableOutput]
}

// MARK: - Unsigned Import Tx
public struct UnsignedImportTx: Codable {
    let base_tx: [UInt8]
    let source_chain: [UInt8]
    let ins: [TransferableInput]
}

   
   // MARK: - EVM Input
   public struct EVMInput: Codable {
       let address: String
       let amount: BigUInt
       let asset_id: String
       let nonce: BigUInt
   }

   
   // MARK: - EVM Output
   public struct EVMOutput: Codable {
       let address: String
       let amount: BigUInt
       let asset_id: String
   }
    



// MARK: - UTXOS
public struct ValidatorsModel: Codable {
    let jsonrpc: String
    let result: Validators
    let id: Int
}

// MARK: - Validators
public struct Validators: Codable {
    let validators: [Validator]
}

// MARK: - Validator
public struct Validator: Codable {
    let txID, startTime, endTime, stakeAmount: String
    let nodeID: String
    let rewardOwner: RewardOwner
    let potentialReward, delegationFee, uptime: String
    let connected: Bool
    let delegators: [Delegator]?
}

// MARK: - Delegator
public struct Delegator: Codable {
    let txID, startTime, endTime, stakeAmount: String
    let nodeID: String
    let rewardOwner: RewardOwner
    let potentialReward: String
}

// MARK: - RewardOwner
public struct RewardOwner: Codable {
    let locktime, threshold: String
    let addresses: [String]
}

