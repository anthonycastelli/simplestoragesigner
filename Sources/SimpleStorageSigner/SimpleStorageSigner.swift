//
//  SimpleStorageSigner.swift
//  SimpleStorageSigner
//
//  Created by Anthony Castelli on 5/3/18.
//

import Foundation
import HTTP
import Crypto

public final class SimpleStorageSigner {
    /// The base URL
    let host: URL?
    
    /// The region where S3 bucket is located.
    let region: Region
    
    /// AWS Access Key
    let accessKey: String
    
    /// AWS Secret Key
    let secretKey: String
    
    /// Security Token. Used to validate temporary credentials, such as
    /// those from an EC2 Instance's IAM role
    let securityToken : String?
    
    /// Used within the HMAC signing
    let service = "s3"
    
    /// Initialize a new Signer
    public init(server: URLRepresentable, accessKey: String, secretKey: String, region: Region, securityToken: String? = nil) {
        self.host = server.convertToURL()
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.region = region
        self.securityToken = securityToken
    }

    /// Generates auth headers for Simple Storage Services
    public func authHeader(for httpMethod: HTTPMethod, to urlString: URLRepresentable, headers: [String: String] = [:], payload: Payload) throws -> HTTPHeaders {
        guard let url = urlString.convertToURL() else {
            throw SignerError(identifier: "invalid-url", reason: "Invalid URL", source: .capture())
        }
        
        let dates = self.getDates(Date())
        let bodyDigest = try payload.hashed()
        var updatedHeaders = self.updateHeaders(headers, url: url, longDate: dates.long, bodyDigest: bodyDigest)
        
        if httpMethod == .PUT && payload.isBytes {
            updatedHeaders["Content-MD5"] = try MD5.hash(payload.data).base64EncodedString()
        }
        
        updatedHeaders["Authorization"] = try self.generateAuthHeader(httpMethod, url: url, headers: updatedHeaders, bodyDigest: bodyDigest, dates: dates)
        
        if httpMethod == .PUT {
            updatedHeaders["Content-Length"] = payload.size
            if url.pathExtension != "" {
                updatedHeaders["Content-Type"] = url.pathExtension
            }
        }
        
        if payload.isUnsigned {
            updatedHeaders["x-amz-content-sha256"] = bodyDigest
        }
        
        var headers = HTTPHeaders()
        for (key, value) in updatedHeaders {
            headers.add(name: key, value: value)
        }
        
        return headers
    }
}
