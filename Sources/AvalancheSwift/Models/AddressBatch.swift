//
//  AddressBatch.swift
//  
//
//  Created by Hayrettin İletmiş on 31.03.2023.
//

import Foundation

// MARK: - AddressBatch
struct AddressBatch: Codable {
    let walletAddresses: [String]
    let internalAddresses: [String]
}
