//
//  File.swift
//  
//
//  Created by Hayrettin İletmiş on 16.03.2023.
//

import Foundation
import EnnoUtil

enum BlockchainId: String {
    case pBlockchain = "11111111111111111111111111111111LpoYY"
    case xBlockchain = "2oYMBNV4eNHyqk2fjjV5nVQLDbtmNJzq5s3qs3Lo6ftnC6FByM"
    case cBlockchain = "2q9e4r6Mu3U68nU1fYjgbR6JvwrRx36CohpAX5UQxse55x1Q5"
    
    func decoded() -> [UInt8]? {
        return Web3Crypto.validateChecksum(datas: Base58Encoder.decode(self.rawValue))
    }
}

enum Chains: String {
    case p = "P"
    case x = "X"
    case c = "C"
    
    func chain() -> Chain {
        switch self {
        case .p:
            return Constants.chainP
        case .x:
            return Constants.chainX
        case .c:
            return Constants.chainC
        }
    }
}

enum assetId: String {
    case avaxAssetId = "FvwEAhmxKfeiG8SnEvq42hc6whRyY3EFYAvebMqDNDGCgxN5Z"
    
    func decoded() -> [UInt8] {
        Base58Encoder.decode(self.rawValue)
    }
}

public class Chain {
    
    let identifier: String
    let blockchainId : BlockchainId
    let getUTXOs: String
    let issueTx: String
    let evm: String
    let exportAvaxType: Int32
    let importAvaxType: Int32
    var balance: Double
    var availableBalance: Double
    var stakedBalance: Double
    
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
    }
    
    func clearBalance() {
        self.balance = 0
        self.availableBalance = 0
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
                                          blockchainId: .xBlockchain,
                                          getUTXOs: "platform.getUTXOs",
                                          issueTx: "platform.issueTx",
                                          evm: "https://api.avax.network/ext/bc/P",
                                          exportAvaxType: 4,
                                          importAvaxType: 3)
    
    public static let chainC = Chain.init(identifier: "C",
                                          blockchainId: .xBlockchain,
                                          getUTXOs: "avax.getUTXOs",
                                          issueTx: "avax.issueTx",
                                          evm: "https://api.avax.network/ext/bc/C/avax",
                                          exportAvaxType: 4,
                                          importAvaxType: 3)
    
}
