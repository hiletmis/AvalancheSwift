import Foundation

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

}

