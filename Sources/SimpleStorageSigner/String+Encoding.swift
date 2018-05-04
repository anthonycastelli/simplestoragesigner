//
//  String+Encoding.swift
//  SimpleStorageSigner
//
//  Created by Anthony Castelli on 5/3/18.
//

import Foundation

enum EncodingType: String {
    case queryAllowed = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-._~=&"
    case pathAllowed  = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-._~/"
}

extension String {
    func encode(with type: EncodingType) -> String? {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: type.rawValue)
        return self.addingPercentEncoding(withAllowedCharacters: allowed)
    }
}
