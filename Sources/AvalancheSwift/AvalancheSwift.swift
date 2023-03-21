import Foundation
import BigInteger

public final class AvalancheSwift {

    private weak var delegate: AvalancheInitDelegate?
    
    public private(set) static var shared: AvalancheSwift!

    init() {}
    
    public class func initialize(seed: String) {
        if AvalancheSwift.shared != nil {
           return
        }
        
        let xBatch = AvaxAPI.getXBatch(seed, 0)
        let xIntBatch = AvaxAPI.getXBatch(seed, 1)
        
        AvaxAPI.initializeAddresses(wallet: xBatch, intX: xIntBatch)
        shared = AvalancheSwift()
    }
    
    public class func initialize(xPub: String) {
        let xBatch = AvaxAPI.getXBatch(xPub, 0, isPubKey: true)
        let xIntBatch = AvaxAPI.getXBatch(xPub, 1, isPubKey: true)
        
        AvaxAPI.initializeAddresses(wallet: xBatch, intX: xIntBatch)
        shared = AvalancheSwift()
    }
    
    deinit {
        AvalancheSwift.shared = nil
    }
    
    public func isInitialized() -> Bool {
        return AvalancheSwift.shared != nil
    }

    public func getChains() -> [Chain] {
        return [Constants.chainX, Constants.chainP, Constants.chainC]
    }

    public func getXChain() -> Chain {
        return Constants.chainX
    }

    public func getPChain() -> Chain {
        return Constants.chainP
    }

    public func getCChain() -> Chain {
        return Constants.chainC
    }

    public func getAddresses() -> [Chain] {
        return [Constants.chainX, Constants.chainP, Constants.chainC]
    }

    public func delegateAvax(info: delegatorInfo, amount: String, isValidate: Bool = false, completion: @escaping (_ transaction: UnsignedDelegator?) -> () ) {
        AvaxAPI.delegateAvax(info: info, amount: amount, completion: completion)
    }
    
    public func checkState(delegate: AvalancheInitDelegate) {
        AvaxAPI.checkState(delegate: delegate)
    }
    
    public func importAvaxC(from: String, to: String, web3Address: String, completion: @escaping (_ transaction: BaseImportTxEvm?)->()) {
        guard let from = chainIdentifier.init(rawValue: from) else { return }
        guard let to = chainIdentifier.init(rawValue: to) else { return }
        
        AvaxAPI.importAvaxC(from: from.getChain(), to: to.getChain(), web3Address: web3Address, completion: completion)
    }
    
    public func importAvax(from: String, to: String, completion: @escaping (_ transaction: UnsignedImportTx?)->()) {
        guard let from = chainIdentifier.init(rawValue: from) else { return }
        guard let to = chainIdentifier.init(rawValue: to) else { return }
        
        AvaxAPI.importAvax(from: from.getChain(), to: to.getChain(), completion: completion)
    }

    public func exportToAvaxC(from: String, to: String, amount: String, web3Address: String, nonce: BigUInt, completion: @escaping (_ transaction: BaseExportTxEvm?)->()) {
        guard let from = chainIdentifier.init(rawValue: from) else { return }
        guard let to = chainIdentifier.init(rawValue: to) else { return }
        
        AvaxAPI.exportToAvaxC(from: from.getChain(), to: to.getChain(), amount: amount, web3Address: web3Address, nonce: nonce, completion: completion)
    }
    
    public func exportAvax(from: String, to: String, amount: String, completion: @escaping (_ transaction: UnsignedExportTx?)->()) {
        guard let from = chainIdentifier.init(rawValue: from) else { return }
        guard let to = chainIdentifier.init(rawValue: to) else { return }
        
        AvaxAPI.exportAvax(from: from.getChain(), to: to.getChain(), amount: amount, completion: completion)
    }
    
    public func createTx(transaction: [UInt8], chain: Chain, signature : [[UInt8]], isSegwit: Bool, completion: @escaping (_ transaction: IssueTxResult?)->()) {
        AvaxAPI.createTx(transaction: transaction, chain: chain, signature: signature, isSegwit: isSegwit, completion: completion)
    }
    
}

