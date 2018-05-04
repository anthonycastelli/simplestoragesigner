//
//  Region.swift
//  SimpleStorageSigner
//
//  Created by Anthony Castelli on 5/3/18.
//

import Foundation
import HTTP

/// AWS Region
public enum Region {
    /// US East (N. Virginia)
    case usEast1
    
    /// US East (Ohio)
    case usEast2
    
    /// US West (N. California)
    case usWest1
    
    /// US West (Oregon)
    case usWest2
    
    /// Canada (Central)
    case caCentral1
    
    /// EU (Frankfurt)
    case euCentral1
    
    /// EU (Ireland)
    case euWest1
    
    /// EU (London)
    case euWest2
    
    /// EU (Paris)
    case euWest3
    
    /// Asia Pacific (Tokyo)
    case apNortheast1
    
    /// Asia Pacific (Seoul)
    case apNortheast2
    
    /// Asia Pacific (Osaka-Local)
    case apNortheast3
    
    /// Asia Pacific (Singapore)
    case apSoutheast1
    
    /// Asia Pacific (Sydney)
    case apSoutheast2
    
    /// Asia Pacific (Mumbai)
    case apSouth1
    
    /// South America (São Paulo)
    case saEast1
    
    /// A custom region
    case custom(String)
}

extension Region {
    /// The Server ID
    var id: String {
        switch self {
        case .usEast1: return "us-east-1"
        case .usEast2: return "us-east-2"
        case .usWest1: return "us-west-1"
        case .usWest2: return "us-west-2"
        case .caCentral1: return "ca-central-1" // Canada (Central)
        case .euCentral1: return "eu-central-1" // EU (Frankfurt)
        case .euWest1: return "eu-west-1"
        case .euWest2: return "eu-west-2"
        case .euWest3: return "eu-west-3"
        case .apNortheast1: return "ap-northeast-1"
        case .apNortheast2: return "ap-northeast-2"
        case .apNortheast3: return "ap-northeast-3"
        case .apSoutheast1: return "ap-southeast-1"
        case .apSoutheast2: return "ap-southeast-2"
        case .apSouth1: return "ap-south-1"
        case .saEast1: return "sa-east-1"
        case .custom(let value): return value
        }
    }
}

extension Region {
    /// Generate the base URL
    public var host: String {
        return "https://s3.\(self.id).amazonaws.com".finished(with: "/")
    }
    
    public func host(_ url: URLRepresentable? = nil) -> String {
        guard let absoluteURL = url?.convertToURL()?.absoluteString else {
            return self.host
        }
        return absoluteURL
    }
}
