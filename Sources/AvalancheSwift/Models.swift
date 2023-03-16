//
//  Models.swift
//  
//
//  Created by Hayrettin İletmiş on 16.03.2023.
//

import BigInteger
import Foundation

// MARK: - AtomicTx
struct AtomicTx: Codable {
    let jsonrpc: String
    let id: Int
    let method: String
    let params: ParamsAtomicTx
}

// MARK: - Params
struct ParamsAtomicTx: Codable {
    let txID, encoding: String
}

// MARK: - IssueTxResult
struct IssueTxResult: Codable {
    let jsonrpc: String
    let id: Int
    let result: ResultTx
}

// MARK: - Result
struct ResultTx: Codable {
    let txID: String?
    let tx: String?
}

// MARK: - IssueTx
struct IssueTx: Codable {
    let jsonrpc: String
    let id: Int
    let method: String
    let params: ParamsTx
}

// MARK: - Params
struct ParamsTx: Codable {
    let tx, encoding: String
}


// MARK: - NFT
struct NFTMarket: Codable {
    var name: String
    let address, token, symbol: String
    let id: Int
    var list: Bool
    let iconURL: String
    var tokenUri: String
}

// MARK: - RPCModel
struct RPCModel: Codable {
    let jsonrpc, method: String
    let params: [String]
    let id: Int
}

// MARK: - PVMRPCModel
struct PVMRPCModel: Codable {
    let jsonrpc: String
    let id: Int
    let method: String
    let params: Params?
}

// MARK: - Params
struct Params: Codable {
    let address: String?
    let addresses: [String]?
    let assetID: String?
    let sourceChain: String?
    let limit: Int?
    let encoding: String?
    let subnetID: String?
}

// MARK: - PChainBalance
struct PChainBalance: Codable {
    let jsonrpc: String
    let result: Result
    let id: Int
}

// MARK: - Result
struct Result: Codable {
    let balance: String
    let unlocked, lockedStakeable, lockedNotStakeable: String?
}

// MARK: - AddressChains
struct AddressChains: Codable {
    let addressChains: [String: [String]]
}

// MARK: - UTXOS
struct UTXOS: Codable {
    let jsonrpc: String
    let result: UTXOResult
    let id: Int
}

// MARK: - Result
struct UTXOResult: Codable {
    let numFetched: String
    let utxos: [String]
    let endIndex: EndIndex
    let encoding: String
}

// MARK: - EndIndex
struct EndIndex: Codable {
    let address, utxo: String
}

struct AddressBalances: Codable {
    let chain: String
    let balance: Double
}

struct SECP256K1: Codable {
    let typeID: String
    let amount: String
    let locktime: String
    let threshold: String
}

struct UTXOOutput: Codable {
    let codecID: String
    let txID: String
    let uTXOIndex: String
    let assetId: String
    let output: SECP256K1
}

// MARK: - GetStaked
struct GetStaked: Codable {
    let jsonrpc: String
    let result: ResultStake
    let id: Int
}

// MARK: - Result
struct ResultStake: Codable {
    let staked: String
    let stakedOutputs: [String]
    let encoding: String
}

// MARK: - TransferableOutput {
struct TransferableOutput: Codable {
    let asset_id: String
    let output: TransferOutput
}

// MARK: - TransferOutput
struct TransferOutput: Codable {
    let type_id: Int32
    let amount: BigUInt
    let locktime: BigUInt
    let threshold: Int32
    let addresses: [String]
}
// MARK: - SECP256K1OutputOwners
struct SECP256K1OutputOwners: Codable {
    let type_id: Int32
    let locktime: BigUInt
    let threshold: Int32
    let addresses: [String]
}

// MARK: - TransferableInput
struct TransferableInput: Codable {
    let tx_id: String
    let utxo_index: Int32
    let asset_id: String
    let input: TransferInput
}

// MARK: - TransferInput
struct TransferInput: Codable {
    let type_id: Int32
    let amount: BigUInt
    let addresses: [Int]
    let locked: BigUInt
    let address_indices: [Int32]
}


// MARK: - ExportAvax-C
struct BaseExportTxEvm: Codable {
    let typeID: Int32
    let networkID: Int32
    let blockchainID: String
    let destinationChain: String
    let inputs: [EVMInput]
    let exportedOutputs: [TransferableOutput]
}

// MARK: - ImportAvax-C
struct BaseImportTxEvm: Codable {
    let typeID: Int32
    let networkID: Int32
    let blockchainID: String
    let sourceChain: String
    let importedInputs: [EVMOutput]
    let outs: [TransferableInput]
}


// MARK: - Unsigned Export Tx
struct UnsignedExportTx: Codable {
    let base_tx: [UInt8]
    let destination_chain: [UInt8]?
    let outs: [TransferableOutput]
}

// MARK: - ExportAvax
struct BaseTx: Codable {
    let type_id: Int32
    let network_id: Int32
    let blockchain_id: String
    let outputs: [TransferableOutput]
    let inputs: [TransferableInput]
    let memo: String
}

 // MARK: - UnsignedDelegator
 struct UnsignedDelegator: Codable {
     let baseTx: BaseTx
     let nodeId: String
     let startTime: BigUInt
     let endTime: BigUInt
     let weight: BigUInt
     let lockedOuts: [TransferableOutput]
     let rewardsOwner: SECP256K1OutputOwners
     let shares: Int32?
 }

struct delegatorInfo {
    var nodeId: String?
    var startTime: Int64
    var endTime: Int64
    var weight: String
    var rewardAddress: String
    var shares: Int32?
}

// MARK: - Stake
struct StakeTx: Codable {
    let lockedOuts: [TransferableOutput]
}

// MARK: - Unsigned Import Tx
struct UnsignedImportTx: Codable {
    let base_tx: [UInt8]
    let source_chain: [UInt8]?
    let ins: [TransferableInput]
}

   
   // MARK: - EVM Input
   struct EVMInput: Codable {
       let address: String
       let amount: BigUInt
       let asset_id: String
       let nonce: BigUInt
   }

   
   // MARK: - EVM Output
   struct EVMOutput: Codable {
       let address: String
       let amount: BigUInt
       let asset_id: String
   }
    



// MARK: - UTXOS
struct ValidatorsModel: Codable {
    let jsonrpc: String
    let result: Validators
    let id: Int
}

// MARK: - Validators
struct Validators: Codable {
    let validators: [Validator]
}

// MARK: - Validator
struct Validator: Codable {
    let txID, startTime, endTime, stakeAmount: String
    let nodeID: String
    let rewardOwner: RewardOwner
    let potentialReward, delegationFee, uptime: String
    let connected: Bool
    let delegators: [Delegator]?
}

// MARK: - Delegator
struct Delegator: Codable {
    let txID, startTime, endTime, stakeAmount: String
    let nodeID: String
    let rewardOwner: RewardOwner
    let potentialReward: String
}

// MARK: - RewardOwner
struct RewardOwner: Codable {
    let locktime, threshold: String
    let addresses: [String]
}

