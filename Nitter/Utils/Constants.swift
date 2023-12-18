//
//  Constants.swift
//  Nitter
//
//  Created by Bronson Lane on 12/14/23.
//

import Foundation

class Constants {
    static var instanceBaseURL = UserDefaults.standard.object(forKey: "instanceBaseURL") as? String ?? "nitter.x86-64-unknown-linux-gnu.zip"
    static var instanceHTTPS = "https://\(instanceBaseURL)"
    static var instanceHTTP = "http://\(instanceBaseURL)"
    
    static func updateConstants(instanceBaseURL: String) {
        Constants.instanceBaseURL = instanceBaseURL
        Constants.instanceHTTPS = "https://\(instanceBaseURL)"
        Constants.instanceHTTP = "http://\(instanceBaseURL)"
    }
}
