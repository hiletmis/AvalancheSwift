import Foundation

public final class AvalancheSwift {

    private weak var delegate: AvalancheInitDelegate?
    
    public private(set) static var shared: AvalancheSwift!

    init() {}
    
    public class func initialize(seed: String) {
        AvaxAPI.initVars(seed)
        if AvalancheSwift.shared != nil { return }
        shared = AvalancheSwift()
    }

    deinit {
        AvalancheSwift.shared = nil
    }
    
    public func getChains() -> [AvalancheChain] {
        return [Constants.XChain, Constants.PChain, Constants.CChain]
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

    public func delegateAvax(info: DelegatorInfo, amount: String, isValidate: Bool = false,
                             completion: @escaping (_ txId: String?, _ tx: String?)->()) {
        AvaxAPI.delegateAvax(info: info, amount: amount, completion: completion)
    }
    
    public func checkState(delegate: AvalancheInitDelegate) {
        AvaxAPI.checkState(delegate: delegate)
    }
    
    public func importAvaxC(from: String, to: String, web3Address: String,
                            completion: @escaping (_ txId: String?, _ tx: String?)->()) {
        guard let from = chainIdentifier.init(rawValue: from) else { return }
        guard let to = chainIdentifier.init(rawValue: to) else { return }
        
        AvaxAPI.importAvaxC(from: from.getChain(), to: to.getChain(), web3Address: web3Address, completion: completion)
    }
    
    public func importAvax(from: String, to: String,
                           completion: @escaping (_ txId: String?, _ tx: String?)->()) {
        guard let from = chainIdentifier.init(rawValue: from) else { return }
        guard let to = chainIdentifier.init(rawValue: to) else { return }
        
        AvaxAPI.importAvax(from: from.getChain(), to: to.getChain(), completion: completion)
    }

    public func exportToAvaxC(from: String, to: String, amount: String, web3Address: String, nonce: String,
                              completion: @escaping (_ txId: String?, _ tx: String?)->()) {
        guard let from = chainIdentifier.init(rawValue: from) else { return }
        guard let to = chainIdentifier.init(rawValue: to) else { return }
                
        AvaxAPI.exportToAvaxC(from: from.getChain(), to: to.getChain(), amount: amount, web3Address: web3Address, nonce: nonce, completion: completion)
    }
    
    public func exportAvax(from: String, to: String, amount: String,
                           completion: @escaping (_ txId: String?, _ tx: String?)->()) {
        guard let from = chainIdentifier.init(rawValue: from) else { return }
        guard let to = chainIdentifier.init(rawValue: to) else { return }
        
        AvaxAPI.exportAvax(from: from.getChain(), to: to.getChain(), amount: amount, completion: completion)
    }
    
    public func createTx(transaction: [UInt8], chain: Chain, signatures : [Int], isSegwit: Bool,
                         completion: @escaping (_ txId: String?, _ tx: String?)->()) {
        AvaxAPI.createTx(transaction: transaction, chain: chain, signatures: signatures, isSegwit: isSegwit, completion: completion)
    }
    
    public func getValidators(completion: @escaping (_ validators: ValidatorsModel?)->()) {
        AvaxAPI.getValidators(completion: completion)
    }
    
    public func getAtomicTx(chain: String, id: String, completion: @escaping (_ txId: String?, _ tx: String?)->()) {
        guard let chain = chainIdentifier.init(rawValue: chain) else { return }
        AvaxAPI.getAtomicTx(chain: chain.getChain(), id: id, completion: completion)
    }
    
}

