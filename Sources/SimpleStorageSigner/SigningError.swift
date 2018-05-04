//
//  SigningError.swift
//  SimpleStorageSigner
//
//  Created by Anthony Castelli on 5/3/18.
//

import Debugging

/// Errors that can be thrown while working with Local Adapter.
public struct SignerError: Debuggable {
    public static let readableName = "Simple Storage Signer Error"
    public let identifier: String
    public var reason: String
    public var sourceLocation: SourceLocation?
    public var stackTrace: [String]
    public var suggestedFixes: [String]
    public var possibleCauses: [String]
    
    init(identifier: String, reason: String, suggestedFixes: [String] = [], possibleCauses: [String] = [], source: SourceLocation) {
        self.identifier = identifier
        self.reason = reason
        self.sourceLocation = source
        self.stackTrace = SignerError.makeStackTrace()
        self.suggestedFixes = suggestedFixes
        self.possibleCauses = possibleCauses
    }
}
