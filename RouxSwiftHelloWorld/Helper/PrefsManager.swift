//
//  PrefsManager.swift
//  RouxSwiftHelloWorld
//
//  Created by Jayesh Mardiya on 13/07/20.
//  Copyright © 2020 Scandy. All rights reserved.
//

import Foundation

private let K_IPINFO_DATA = "IpPort"

struct IPModel: Codable {
    let ipAddress: String
    let port: String
}

class PrefsManager {
    
    static func setIPInformation(model: IPModel) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(model) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: K_IPINFO_DATA)
        }
    }
    
    static func getIPInformation() -> IPModel {
        let defaults = UserDefaults.standard
        if let savedIpInfo = defaults.object(forKey: K_IPINFO_DATA) as? Data {
            let decoder = JSONDecoder()
            if let ipInfo = try? decoder.decode(IPModel.self, from: savedIpInfo) {
                return ipInfo
            }
        }
        
        return IPModel(ipAddress: "192.168.10.122", port: "6550")
    }
}
