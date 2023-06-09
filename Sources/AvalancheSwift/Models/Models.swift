//
//  Models.swift
//  
//
//  Created by Hayrettin İletmiş on 16.03.2023.
//

import BigInteger
import Foundation
import EnnoUtil

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
    
    init(method: ApiEndpoints, params: ParamsTx) {
        self.jsonrpc = "2.0"
        self.id = 1
        self.method = method.rawValue
        self.params = params
    }
}

// MARK: - Params
public struct ParamsTx: Codable {
    public let tx, encoding: String
    
    init(tx: String) {
        self.tx = tx
        self.encoding = "hex"
    }
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
    
    init(method: ApiEndpoints, params: Params?) {
        self.jsonrpc = "2.0"
        self.id = 1
        self.method = method.rawValue
        self.params = params
    }
    
    init(method: ApiEndpoints) {
        self.jsonrpc = "2.0"
        self.id = 1
        self.method = method.rawValue
        self.params = nil
    }
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
    
    init(address: String?, addresses: [String]?, assetID: String?, sourceChain: String?, limit: Int?, encoding: String?, subnetID: String?) {
        self.address = address
        self.addresses = addresses
        self.assetID = assetID
        self.sourceChain = sourceChain
        self.limit = limit
        self.encoding = encoding
        self.subnetID = subnetID
    }
    
    init(addresses: [String], limit: Int) {
        self.address = nil
        self.addresses = addresses
        self.assetID = nil
        self.sourceChain = nil
        self.limit = limit
        self.encoding = "hex"
        self.subnetID = nil
    }
    
    init(addresses: [String], limit: Int, sourceChain: String?) {
        self.address = nil
        self.addresses = addresses
        self.assetID = nil
        self.sourceChain = sourceChain
        self.limit = limit
        self.encoding = "hex"
        self.subnetID = nil
    }
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
    
    public func toDouble() -> Double {
        var totalBalance: BigUInt = 0

        for item in utxos {
            let amount : String = item.substr(150, 16) ?? "N/A"
            totalBalance += BigUInt(amount, radix: 16) ?? .zero
        }
        return Double.init(totalBalance) / pow(10, Double.init(9))
    }
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
    
    init(staked: String, stakedOutputs: [String], encoding: String) {
        self.staked = staked
        self.stakedOutputs = stakedOutputs
        self.encoding = encoding
        
        if let stake = Double.init(staked) {
            Constants.PChain.setStakedBalance(stakedBalance: stake / pow(10, Double.init(9)))
        }
    }
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
    
    init(amount: BigUInt, addresses: [String]) {
        self.type_id = 7
        self.amount = amount
        self.locktime = 0
        self.threshold = 1
        self.addresses = addresses
    }
}
// MARK: - SECP256K1OutputOwners
public struct SECP256K1OutputOwners: Codable {
    public let type_id: Int32
    public let locktime: BigUInt
    public let threshold: Int32
    public let addresses: [String]
    
    init(addresses: [String]) {
        self.type_id = 11
        self.locktime = 0
        self.threshold = 1
        self.addresses = addresses
    }
}

// MARK: - TransferInput
public struct TransferInput: Codable {
    public let type_id: Int32
    public let amount: BigUInt
    public let addresses: [Int]
    public let locked: BigUInt
    public let address_indices: [Int32]
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

// MARK: - Stake
public struct StakeTx: Codable {
    public let lockedOuts: [TransferableOutput]
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


// MARK: - AddressBatchRequest
struct AddressBatchRequest: Codable {
    let address: [String]
}

// MARK: - ParamsAtomicTx
public struct ParamsAtomicTx: Codable {
    public let txID, encoding: String
    
    init(txID: String) {
        self.txID = txID
        self.encoding = "hex"
    }
}
 
// MARK: - AtomicTx
public struct AtomicTx: Codable {
    public let jsonrpc: String
    public let id: Int
    public let method: String
    public let params: ParamsAtomicTx
    
    init(method: ApiEndpoints, params: ParamsAtomicTx) {
        self.jsonrpc = "2.0"
        self.id = 1
        self.method = method.rawValue
        self.params = params
    }
}
