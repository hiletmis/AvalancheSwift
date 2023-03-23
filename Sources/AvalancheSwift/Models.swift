//
//  Models.swift
//  
//
//  Created by Hayrettin İletmiş on 16.03.2023.
//

import BigInteger
import Foundation

// MARK: - AddressBatch
struct AddressBatch: Codable {
    let walletAddresses: [String]
    let internalAddresses: [String]
}

// MARK: - AtomicTx
public struct AtomicTx: Codable {
    public let jsonrpc: String
    public let id: Int
    public let method: String
    public let params: ParamsAtomicTx
}

// MARK: - Params
public struct ParamsAtomicTx: Codable {
    public let txID, encoding: String
}

// MARK: - IssueTxResult
public struct IssueTxResult: Codable {
    public let jsonrpc: String
    public let id: Int
    public let result: ResultTx
}

// MARK: - Result
public struct ResultTx: Codable {
    public let txID: String?
    public let tx: String?
}

// MARK: - IssueTx
public struct IssueTx: Codable {
    public let jsonrpc: String
    public let id: Int
    public let method: String
    public let params: ParamsTx
}

// MARK: - Params
public struct ParamsTx: Codable {
    public let tx, encoding: String
}


// MARK: - NFT
public struct NFTMarket: Codable {
    var name: String
    public let address, token, symbol: String
    public let id: Int
    var list: Bool
    public let iconURL: String
    var tokenUri: String
}

// MARK: - RPCModel
public struct RPCModel: Codable {
    public let jsonrpc, method: String
    public let params: [String]
    public let id: Int
}

// MARK: - PVMRPCModel
public struct PVMRPCModel: Codable {
    public let jsonrpc: String
    public let id: Int
    public let method: String
    public let params: Params?
}

// MARK: - Params
public struct Params: Codable {
    public let address: String?
    public let addresses: [String]?
    public let assetID: String?
    public let sourceChain: String?
    public let limit: Int?
    public let encoding: String?
    public let subnetID: String?
}

// MARK: - PChainBalance
public struct PChainBalance: Codable {
    public let jsonrpc: String
    public let result: Result
    public let id: Int
}

// MARK: - Result
public struct Result: Codable {
    public let balance: String
    public let unlocked, lockedStakeable, lockedNotStakeable: String?
}

// MARK: - AddressChains
public struct AddressChains: Codable {
    public let addressChains: [String: [String]]
}

// MARK: - UTXOS
public struct UTXOS: Codable {
    public let jsonrpc: String
    public let result: UTXOResult
    public let id: Int
}

// MARK: - Result
public struct UTXOResult: Codable {
    public let numFetched: String
    public let utxos: [String]
    public let endIndex: EndIndex
    public let encoding: String
}

// MARK: - EndIndex
public struct EndIndex: Codable {
    public let address, utxo: String
}

public struct AddressBalances: Codable {
    public let chain: String
    public let balance: Double
}

public struct SECP256K1: Codable {
    public let typeID: String
    public let amount: String
    public let locktime: String
    public let threshold: String
}

public struct UTXOOutput: Codable {
    public let codecID: String
    public let txID: String
    public let uTXOIndex: String
    public let assetId: String
    public let output: SECP256K1
}

// MARK: - GetStaked
public struct GetStaked: Codable {
    public let jsonrpc: String
    public let result: ResultStake
    public let id: Int
}

// MARK: - Result
public struct ResultStake: Codable {
    public let staked: String
    public let stakedOutputs: [String]
    public let encoding: String
}

// MARK: - TransferableOutput {
public struct TransferableOutput: Codable {
    public let asset_id: String
    public let output: TransferOutput
}

// MARK: - TransferOutput
public struct TransferOutput: Codable {
    public let type_id: Int32
    public let amount: BigUInt
    public let locktime: BigUInt
    public let threshold: Int32
    public let addresses: [String]
}
// MARK: - SECP256K1OutputOwners
public struct SECP256K1OutputOwners: Codable {
    public let type_id: Int32
    public let locktime: BigUInt
    public let threshold: Int32
    public let addresses: [String]
}

// MARK: - TransferableInput
public struct TransferableInput: Codable {
    public let tx_id: String
    public let utxo_index: Int32
    public let asset_id: String
    public let input: TransferInput
}

// MARK: - TransferInput
public struct TransferInput: Codable {
    public let type_id: Int32
    public let amount: BigUInt
    public let addresses: [Int]
    public let locked: BigUInt
    public let address_indices: [Int32]
}


// MARK: - ExportAvax-C
public struct BaseExportTxEvm: Codable {
    public let typeID: Int32
    public let networkID: Int32
    public let blockchainID: String
    public let destinationChain: String
    public let inputs: [EVMInput]
    public let exportedOutputs: [TransferableOutput]
}

// MARK: - ImportAvax-C
public struct BaseImportTxEvm: Codable {
    public let typeID: Int32
    public let networkID: Int32
    public let blockchainID: String
    public let sourceChain: String
    public let importedInputs: [EVMOutput]
    public let outs: [TransferableInput]
}


// MARK: - Unsigned Export Tx
public struct UnsignedExportTx: Codable {
    public let base_tx: [UInt8]
    public let destination_chain: [UInt8]
    public let outs: [TransferableOutput]
}

// MARK: - ExportAvax
public struct BaseTx: Codable {
    public let type_id: Int32
    public let network_id: Int32
    public let blockchain_id: String
    public let outputs: [TransferableOutput]
    public let inputs: [TransferableInput]
    public let memo: String
}

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
    public let lockedOuts: [TransferableOutput]
}

// MARK: - Unsigned Import Tx
public struct UnsignedImportTx: Codable {
    public let base_tx: [UInt8]
    public let source_chain: [UInt8]
    public let ins: [TransferableInput]
}

   // MARK: - EVM Input
   public struct EVMInput: Codable {
       public let address: String
       public let amount: BigUInt
       public let asset_id: String
       public let nonce: BigUInt
   }
   
   // MARK: - EVM Output
   public struct EVMOutput: Codable {
       public let address: String
       public let amount: BigUInt
       public let asset_id: String
   }
    
// MARK: - UTXOS
public struct ValidatorsModel: Codable {
    public let jsonrpc: String
    public let result: Validators
    public let id: Int
}

// MARK: - Validators
public struct Validators: Codable {
    public let validators: [Validator]
}

// MARK: - Validator
public struct Validator: Codable {
    public let txID, startTime, endTime, stakeAmount: String
    public let nodeID: String
    public let rewardOwner: RewardOwner
    public let potentialReward, delegationFee, uptime: String
    public let connected: Bool
    public let delegators: [Delegator]?
}

// MARK: - Delegator
public struct Delegator: Codable {
    public let txID, startTime, endTime, stakeAmount: String
    public let nodeID: String
    public let rewardOwner: RewardOwner
    public let potentialReward: String
}

// MARK: - RewardOwner
public struct RewardOwner: Codable {
    public let locktime, threshold: String
    public let addresses: [String]
}

