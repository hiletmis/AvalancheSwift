//
//  AvalancheInitDelegate.swift
//  
//
//  Created by Hayrettin İletmiş on 17.03.2023.
//

import Foundation

public protocol AvalancheInitDelegate: AnyObject {
    func addressesInitialized()
    func balanceXInitialized()
    func balancePInitialized()
    func delegationInitialized()
}
