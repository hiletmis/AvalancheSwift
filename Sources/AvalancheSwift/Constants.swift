//
//  Constants.swift
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
}

enum assetId: String {
    case avaxAssetId = "FvwEAhmxKfeiG8SnEvq42hc6whRyY3EFYAvebMqDNDGCgxN5Z"
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

public class AvalancheChain {
    public let identifier: String
    public var balance: Double
    public var stakedBalance: Double
    public var latestAddress: String?
    
    init(identifier: String) {
        self.identifier = identifier
        self.balance = 0
        self.stakedBalance = 0
        self.latestAddress = nil
    }
    
    func addBalance(balance: Double, availableBalance: Double) {
        self.balance += balance
    }

    func setStakedBalance(stakedBalance: Double) {
        self.stakedBalance = stakedBalance
    }
     
    func clearBalance() {
        self.balance = 0
    }
    
    func setAddress(address: String) {
        self.latestAddress = address
    }
}

public class Chain {
    
    public let identifier: String
    public let blockchainId : BlockchainId
    public let getUTXOs: ApiEndpoints
    public let issueTx: ApiEndpoints
    public let getTx: ApiEndpoints
    public let evm: String
    public let exportAvaxType: Int32
    public let importAvaxType: Int32
    
    init(identifier: String, blockchainId: BlockchainId, getUTXOs: ApiEndpoints, getTx: ApiEndpoints, issueTx: ApiEndpoints, evm: String, exportAvaxType: Int32, importAvaxType: Int32) {
        self.identifier = identifier
        self.blockchainId = blockchainId
        self.getUTXOs = getUTXOs
        self.getTx = getTx
        self.issueTx = issueTx
        self.evm = evm
        self.exportAvaxType = exportAvaxType
        self.importAvaxType = importAvaxType
    }
}

class Constants {
    
    public static let XChain = AvalancheChain.init(identifier: "X")
    public static let PChain = AvalancheChain.init(identifier: "P")
    public static let CChain = AvalancheChain.init(identifier: "C")
    
    public static let chainX = Chain.init(identifier: "X",
                                          blockchainId: .xBlockchain,
                                          getUTXOs: .avmGetUTXOs,
                                          getTx: .avmGetTx,
                                          issueTx: .avmIssueTx,
                                          evm: "https://api.avax.network/ext/bc/X",
                                          exportAvaxType: 4,
                                          importAvaxType: 3)
    
    public static let chainP = Chain.init(identifier: "P",
                                          blockchainId: .pBlockchain,
                                          getUTXOs: .platformGetUTXOs,
                                          getTx: .platformGetTx,
                                          issueTx: .platformIssueTx,
                                          evm: "https://api.avax.network/ext/bc/P",
                                          exportAvaxType: 18,
                                          importAvaxType: 17)
    
    public static let chainC = Chain.init(identifier: "C",
                                          blockchainId: .cBlockchain,
                                          getUTXOs: .avaxGetUTXOs,
                                          getTx: .avaxGetTx,
                                          issueTx: .avaxIssueTx,
                                          evm: "https://api.avax.network/ext/bc/C/avax",
                                          exportAvaxType: 1,
                                          importAvaxType: 0)
    
}
