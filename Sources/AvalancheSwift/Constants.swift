//
//  File.swift
//  
//
//  Created by Hayrettin İletmiş on 16.03.2023.
//

import Foundation
import EnnoUtil

public enum BlockchainId: String {
    case pBlockchain = "11111111111111111111111111111111LpoYY"
    case xBlockchain = "2oYMBNV4eNHyqk2fjjV5nVQLDbtmNJzq5s3qs3Lo6ftnC6FByM"
    case cBlockchain = "2q9e4r6Mu3U68nU1fYjgbR6JvwrRx36CohpAX5UQxse55x1Q5"
    
    func decoded() -> [UInt8]? {
        return Web3Crypto.validateChecksum(datas: Base58Encoder.decode(self.rawValue))
    }
}

enum assetId: String {
    case avaxAssetId = "FvwEAhmxKfeiG8SnEvq42hc6whRyY3EFYAvebMqDNDGCgxN5Z"
    
    func decoded() -> [UInt8] {
        Base58Encoder.decode(self.rawValue)
    }
}

enum chainIdentifier: String {
    case x = "X"
    case p = "P"
    case c = "C"
    
    func getChain() -> Chain {
        switch self {
        case .x:
            return Constants.chainX
        case .p:
            return Constants.chainP
        case .c:
            return Constants.chainC
        }
    }
}

public class Chain {
    
    public let identifier: String
    public let blockchainId : BlockchainId
    public let getUTXOs: String
    public let issueTx: String
    public let evm: String
    public var latestAddress: String
    public let exportAvaxType: Int32
    public let importAvaxType: Int32
    public var balance: Double
    public var availableBalance: Double
    public var stakedBalance: Double
    
    init(identifier: String, blockchainId: BlockchainId, getUTXOs: String, issueTx: String, evm: String, exportAvaxType: Int32, importAvaxType: Int32) {
        self.identifier = identifier
        self.blockchainId = blockchainId
        self.getUTXOs = getUTXOs
        self.issueTx = issueTx
        self.evm = evm
        self.exportAvaxType = exportAvaxType
        self.importAvaxType = importAvaxType
        self.balance = 0
        self.availableBalance = 0
        self.stakedBalance = 0
        self.latestAddress = ""
    }
    
    func clearBalance() {
        self.balance = 0
        self.availableBalance = 0
    }
    
    func setAddress(address: String) {
        self.latestAddress = address
    }
    
    func addBalance(balance: Double, availableBalance: Double) {
        self.balance += balance
        self.availableBalance += availableBalance
    }

    func setStakedBalance(stakedBalance: Double) {
        self.stakedBalance = stakedBalance
    }
}

class Constants {
    
    public static let chainX = Chain.init(identifier: "X",
                                          blockchainId: .xBlockchain,
                                          getUTXOs: "avm.getUTXOs",
                                          issueTx: "avm.issueTx",
                                          evm: "https://api.avax.network/ext/bc/X",
                                          exportAvaxType: 4,
                                          importAvaxType: 3)
    
    public static let chainP = Chain.init(identifier: "P",
                                          blockchainId: .pBlockchain,
                                          getUTXOs: "platform.getUTXOs",
                                          issueTx: "platform.issueTx",
                                          evm: "https://api.avax.network/ext/bc/P",
                                          exportAvaxType: 18,
                                          importAvaxType: 17)
    
    public static let chainC = Chain.init(identifier: "C",
                                          blockchainId: .cBlockchain,
                                          getUTXOs: "avax.getUTXOs",
                                          issueTx: "avax.issueTx",
                                          evm: "https://api.avax.network/ext/bc/C/avax",
                                          exportAvaxType: 1,
                                          importAvaxType: 0)
    
}
