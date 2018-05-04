//
//  SimpleStorageSigner+Signing.swift
//  SimpleStorageSigner
//
//  Created by Anthony Castelli on 5/3/18.
//

import Foundation
import HTTP
import Crypto

extension SimpleStorageSigner {
    func canonicalHeaders(_ headers: [String: String]) -> String {
        let headerList = Array(headers.keys)
            .map { "\($0.lowercased()):\(headers[$0]!)" }
            .filter { $0 != "authorization" }
            .sorted(by: { $0.localizedCompare($1) == ComparisonResult.orderedAscending })
            .joined(separator: "\n")
            .appending("\n")
        return headerList
    }
    
    func createCanonicalRequest(_ httpMethod: HTTPMethod, url: URL, headers: [String: String], bodyDigest: String) throws -> String {
        return try [httpMethod.description, self.path(url), self.query(url), self.canonicalHeaders(headers),self.signedHeaders(headers), bodyDigest].joined(separator: "\n")
    }
    
    func createSignature(_ stringToSign: String, timeStampShort: String) throws -> String {
        let dateKey = try HMAC.SHA256.authenticate(timeStampShort.convertToData(), key: "AWS4\(self.secretKey)".convertToData())
        let dateRegionKey = try HMAC.SHA256.authenticate(self.region.id.convertToData(), key: dateKey)
        let dateRegionServiceKey = try HMAC.SHA256.authenticate(self.service.convertToData(), key: dateRegionKey)
        let signingKey = try HMAC.SHA256.authenticate("aws4_request".convertToData(), key: dateRegionServiceKey)
        let signature = try HMAC.SHA256.authenticate(stringToSign.convertToData(), key: signingKey)
        return signature.hexEncodedString()
    }
    
    func createStringToSign(_ canonicalRequest: String, dates: Dates) throws -> String {
        let canonRequestHash = try SHA256.hash(canonicalRequest.convertToData()).hexEncodedString()
        return ["AWS4-HMAC-SHA256", dates.long, self.credentialScope(dates.short), canonRequestHash].joined(separator: "\n")
    }
    
    func credentialScope(_ timeStampShort: String) -> String {
        return [timeStampShort, self.region.id, self.service, "aws4_request"].joined(separator: "/")
    }
    
    func generateAuthHeader(_ httpMethod: HTTPMethod, url: URL, headers: [String: String], bodyDigest: String, dates: Dates) throws -> String {
        let canonicalRequestHex = try self.createCanonicalRequest(httpMethod, url: url, headers: headers, bodyDigest: bodyDigest)
        let stringToSign = try self.createStringToSign(canonicalRequestHex, dates: dates)
        let signature = try self.createSignature(stringToSign, timeStampShort: dates.short)
        let authHeader = "AWS4-HMAC-SHA256 Credential=\(self.accessKey)/\(self.credentialScope(dates.short)), SignedHeaders=\(self.signedHeaders(headers)), Signature=\(signature)"
        return authHeader
    }
    
    func getDates(_ date: Date) -> Dates {
        return Dates(date)
    }
    
    func path(_ url: URL) -> String {
        return !url.path.isEmpty ? url.path.encode(with: .pathAllowed) ?? "/" : "/"
    }
    
    func presignedURLCanonRequest(_ httpMethod: HTTPMethod, dates: Dates, expiration: Expiration, url: URL, headers: [String: String]) throws -> (String, URL) {
        guard let credScope = self.credentialScope(dates.short).encode(with: .queryAllowed),
            let signHeaders = self.signedHeaders(headers).encode(with: .queryAllowed) else {
                throw SignerError(identifier: "invalid-encoding", reason: "Invalid Encoding", source: .capture())
        }
        let fullURL = "\(url.absoluteString)?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=\(self.accessKey)%2F\(credScope)&X-Amz-Date=\(dates.long)&X-Amz-Expires=\(expiration.value)&X-Amz-SignedHeaders=\(signHeaders)"
        
        // This should never throw.
        guard let url = URL(string: fullURL) else {
            throw SignerError(identifier: "invalid-url", reason: "Invalid URL", source: .capture())
        }
        
        return try ([httpMethod.description, self.path(url), self.query(url), self.canonicalHeaders(headers), self.signedHeaders(headers), "UNSIGNED-PAYLOAD"].joined(separator: "\n"), url)
    }
    
    func query(_ url: URL) throws -> String {
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            let items = queryItems.map({ ($0.name.encode(with: .queryAllowed) ?? "", $0.value?.encode(with: .queryAllowed) ?? "") })
            let encodedItems = items.map({ "\($0.0)=\($0.1)" })
            return encodedItems.sorted().joined(separator: "&")
        }
        return ""
    }
    
    func signedHeaders(_ headers: [String: String]) -> String {
        return Array(headers.keys).map { $0.lowercased() }.filter { $0 != "authorization" }.sorted().joined(separator: ";")
    }
    
    func updateHeaders(_ headers: [String: String], url: URL, longDate: String, bodyDigest: String) -> [String: String] {
        var updatedHeaders = headers
        updatedHeaders["X-Amz-Date"] = longDate
        updatedHeaders["Host"] = url.host ?? self.region.host(self.host)
        
        if bodyDigest != "UNSIGNED-PAYLOAD" && self.service == "s3" {
            updatedHeaders["x-amz-content-sha256"] = bodyDigest
        }
        // According to http://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_temp_use-resources.html#RequestWithSTS
        if let token = self.securityToken {
            updatedHeaders["X-Amz-Security-Token"] = token
        }
        return updatedHeaders
    }
}
