//
//  DelegatorInfo.swift
//  
//
//  Created by Hayrettin İletmiş on 31.03.2023.
//

import Foundation

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
