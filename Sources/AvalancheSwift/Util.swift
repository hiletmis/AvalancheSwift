//
//  Util.swift
//  
//
//  Created by Hayrettin İletmiş on 16.03.2023.
//

import Foundation
import EnnoUtil
import BigInteger

class Util {
    
    class func decodeSegwit(address: String) -> [UInt8] {
        let parts = address.split(separator: "-")
        
        let hrp = String(parts[1].prefix(4))
        let addr = String(parts[1])
        
        return EnnoUtil.Web3Crypto.encodeSegwit(hrp: hrp, addr: addr) ?? []
    }
    
    class func decodeBase58Check(data: String) -> [UInt8] {
        return Web3Crypto.validateChecksum(datas: Base58Encoder.decode(data)) ?? []
    }
    
    class func encodeBase58Check(data: String) -> String {
        return Base58Encoder.encode(Web3Crypto.checksum(datas: data.hexToBytes()))
    }
    
    class func getBlockchainId(id: String) -> String {
        switch id {
        case "AVAX-X":
            return BlockchainId.xBlockchain.rawValue
        case "AVAX-P":
            return BlockchainId.pBlockchain.rawValue
        case "AVAX-C":
            return BlockchainId.cBlockchain.rawValue
        default:
            return ""
        }
    }
    
    class func calculateChange(utxos: [TransferableInput], amount: BigUInt) -> BigUInt? {
        var total: BigUInt = 0
         
        for i in utxos {
            total += i.input.amount
        }
        
        if amount > total {
            return nil
        }
        
        return total - amount
    }
    
    class func getPkeyInd(utxos: [TransferableInput]) -> [Int] {
        var sigs: [Int] = []
        for item in utxos {
            for address in item.input.addresses {
                sigs.append(address)
            }
        }
        return sigs
    }
    
    class func hexEncoding(data: [UInt8]) -> String {
        return "0x" + EnnoUtil.Web3Crypto.checksum(datas: data).toHexString()
    }
    
    class func sortLexi(utxos: [TransferableInput], amount: BigUInt, sortOnly: Bool = false) ->  [TransferableInput] {
      
        //let sorted = utxos.sorted(by: {
        //    let comp1 = decodeBase58Check(data: $0.tx_id)!
        //    let comp2 = decodeBase58Check(data: $1.tx_id)!
        //
        //    return comp1[0] < comp2[0]
        //})
 //
        //let sortByUtxo = sorted.sorted(by: {
        //    return $0.tx_id == $1.tx_id && $0.utxo_index < $1.utxo_index
        //})
 //
        //if sortOnly {
        //    return sortByUtxo
        //}
    //
        //var filtered: [TransferableInput] = []
        //
        //var total: BigUInt = 0
        //
        //for item in sortByUtxo {
        //
        //    if item.input.locked == 0 {
        //        total += item.input.amount
        //    }
        //
        //    filtered.append(item)
        //
        //    if total > amount {
        //        return filtered
        //    }
        //}
        return []
    }
    
}
