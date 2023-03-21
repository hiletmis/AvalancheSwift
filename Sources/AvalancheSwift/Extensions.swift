//
//  File 2.swift
//  
//
//  Created by Hayrettin İletmiş on 16.03.2023.
//

import Foundation
import BigInteger

extension String {

    func hexToBytes() -> [UInt8] {
        var hex = self
        hex = hex.replacingOccurrences(of: "0x", with: "")

        var length = hex.count

        if length & 1 != 0 {
            hex = "0" + hex
            length += 1
        }
        var bytes = [UInt8]()
        bytes.reserveCapacity(length/2)
        var index = hex.startIndex
        for _ in 0..<length/2 {
            let nextIndex = hex.index(index, offsetBy: 2)
            if let b = UInt8(hex[index..<nextIndex], radix: 16) {
                bytes.append(b)
            } else {
                return []
            }
            index = nextIndex
        }
        return bytes
    }

    private func stringFromResult(result: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String {
        let hash = NSMutableString()
        for i in 0..<length {
            hash.appendFormat("%02x", result[i])
        }
        return String(hash).lowercased()
    }
}


extension URL {

  func appending(item: URLQueryItem) -> URL {

      guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }

      // Create array of existing query items
      var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []

      // Append the new query item in the existing query items array
      queryItems.append(item)

      // Append updated query items array in the url component object
      urlComponents.queryItems = queryItems

      // Returns the url from new url components
      return urlComponents.url!
  }
}

public extension Encodable {

    subscript(key: String) -> Any? {
        return dictionary[key]
    }

    var data: Data? {
        return try? JSONEncoder().encode(self)
    }

    var dictionary: [String: Any] {
        guard let data = data else { return [:] }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any] ?? [:]
    }
}

public extension String {
    
    /// Conveniently create a substring to more easily match JavaScript APIs
    ///
    /// - Parameters:
    ///   - offset: Starting index fo substring
    ///   - length: Length of desired substring
    /// - Returns: String representing the substring if passed indexes are in bounds
    func substr(_ offset: Int,  _ length: Int) -> String? {
        guard offset + length <= self.count else { return nil }
        let start = index(startIndex, offsetBy: offset)
        let end = index(start, offsetBy: length)
        return String(self[start..<end])
    }
}


extension SECP256K1OutputOwners {
    func toByte() {
        var encodedType:[UInt8] = []
        
        let typeId = self.type_id.byter(len: 4)
        let locktime = self.locktime.byter(len: 8)
        let threshold = self.threshold.byter(len: 4)
        let addressSize = Int32(self.addresses.count).byter(len: 4)
        
        encodedType.append(contentsOf: typeId)
        encodedType.append(contentsOf: locktime)
        encodedType.append(contentsOf: threshold)
        encodedType.append(contentsOf: addressSize)
        
        for address in self.addresses {
            encodedType.append(contentsOf: Util.decodeSegwit(address: address))
        }
    }
}







extension Int32 {
    func byter(len: Int) -> [UInt8] {
        return withUnsafeBytes(of: self.bigEndian, Array.init)
    }

}
extension String {
    func byter() -> [UInt8] {
        return data(using: String.Encoding.utf8, allowLossyConversion: true)?.bytes ?? Array(utf8)
    }
}

extension BigUInt {
    func byter(len: Int) -> [UInt8] {
        return self.serialize().bytes
    }
}
