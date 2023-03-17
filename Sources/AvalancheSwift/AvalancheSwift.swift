import Foundation
import BigInteger

public final class AvalancheSwift {
     
    public private(set) static var shared: AvalancheSwift!

    init(seed: String, delegate: AvalancheInitDelegate) {
        API.initial(seed: seed, delegate: delegate)
    }
    
    deinit {
        AvalancheSwift.shared = nil
    }

    public class func isInitialized() -> Bool {
        return AvalancheSwift.shared != nil
    }

    public class func initialization(seed: String, delegate: AvalancheInitDelegate) {
        if !isInitialized()  {
            AvalancheSwift.shared = AvalancheSwift(seed:seed, delegate: delegate)
        } else {
            API.shared.checkState(delegate: delegate)
        }
    }

    public class func getChains() -> [Chain] {
        return [Constants.chainX, Constants.chainP, Constants.chainC]
    }

    public class func getXChain() -> Chain {
        return Constants.chainX
    }

    public class func getPChain() -> Chain {
        return Constants.chainP
    }

    public class func getCChain() -> Chain {
        return Constants.chainC
    }

    public class func getAddresses() -> [Chain] {
        return [Constants.chainX, Constants.chainP, Constants.chainC]
    }

    public class func delegateAvax(info: delegatorInfo, amount: String, isValidate: Bool = false, completion: @escaping (_ transaction: UnsignedDelegator?) -> () ) {
        API.shared.delegateAvax(info: info, amount: amount, completion: completion)
    }
    
    public class func importAvaxC(from: Chain, to: Chain, web3Address: String, completion: @escaping (_ transaction: BaseImportTxEvm?)->()) {
        API.shared.importAvaxC(from: from, to: to, web3Address: web3Address, completion: completion)
    }
    
    public class func importAvax(from: Chain, to: Chain, completion: @escaping (_ transaction: UnsignedImportTx?)->()) {
        API.shared.importAvax(from: from, to: to, completion: completion)
    }

    public class func exportToAvaxC(from: Chain, to: Chain, amount: String, web3Address: String, nonce: BigUInt, completion: @escaping (_ transaction: BaseExportTxEvm?)->()) {
        API.shared.exportToAvaxC(from: from, to: to, amount: amount, web3Address: web3Address, nonce: nonce, completion: completion)
    }
    
    public class func exportAvax(from: Chain, to: Chain, amount: String, completion: @escaping (_ transaction: UnsignedExportTx?)->()) {
        API.shared.exportAvax(from: from, to: to, amount: amount, completion: completion)
    }
    
    public class func createTx(transaction: [UInt8], chain: Chain, signature : [[UInt8]], isSegwit: Bool, completion: @escaping (_ transaction: IssueTxResult?)->()) {
        API.shared.createTx(transaction: transaction, chain: chain, signature: signature, isSegwit: isSegwit, completion: completion)
    }

}

