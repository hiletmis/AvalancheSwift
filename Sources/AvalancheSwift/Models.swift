//
//  Models.swift
//  
//
//  Created by Hayrettin İletmiş on 16.03.2023.
//

import BigInteger
import Foundation
import EnnoUtil

// MARK: - DelegatorInfo
public struct DelegatorInfo {
    public var nodeId: String?
    public let startTime: Int64
    public let endTime: Int64
    public let weight: String
    public let rewardAddress: String
    public var shares: Int32?
    
    public init(nodeId: String? = nil, startTime: Int64, endTime: Int64, weight: String, rewardAddress: String, shares: Int32? = nil) {
        self.nodeId = nodeId
        self.startTime = startTime
        self.endTime = endTime
        self.weight = weight
        self.rewardAddress = rewardAddress
        self.shares = shares
    }
}

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
    
    init(method: ApiEndpoints, params: ParamsAtomicTx) {
        self.jsonrpc = "2.0"
        self.id = 1
        self.method = method.rawValue
        self.params = params
    }
}

// MARK: - Params
public struct ParamsAtomicTx: Codable {
    public let txID, encoding: String
    
    init(txID: String) {
        self.txID = txID
        self.encoding = "hex"
    }
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


// MARK: - AddressBatchRequest
struct AddressBatchRequest: Codable {
    let address: [String]
}
