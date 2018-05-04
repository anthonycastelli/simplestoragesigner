//
//  Payload.swift
//  SimpleStorageSigner
//
//  Created by Anthony Castelli on 5/3/18.
//

import Foundation
import Core
import Crypto

public enum Payload {
    /// Data payload
    case data(Data)
    
    /// Empty payload
    case none
    
    /// Unsigned payload
    case unsigned
}

extension Payload {
    internal func hashed() throws -> String {
        switch self {
        case .data(let data): return try SHA256.hash(data).hexEncodedString()
        case .none: return try SHA256.hash("".convertToData()).hexEncodedString()
        case .unsigned: return "UNSIGNED-PAYLOAD"
        }
    }
    
    internal var data: Data {
        switch self {
        case .data(let bytes): return bytes
        default: return "".convertToData()
        }
    }
    
    internal var isBytes: Bool {
        switch self {
        case .data( _), .none: return true
        default: return false
        }
    }
    
    internal var size: String {
        switch self {
        case .data, .none: return self.data.count.description
        case .unsigned: return "UNSIGNED-PAYLOAD"
        }
    }
    
    internal var isUnsigned: Bool {
        switch self {
        case .unsigned: return true
        default: return false
        }
    }
}
