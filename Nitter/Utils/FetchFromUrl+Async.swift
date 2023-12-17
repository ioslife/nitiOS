//
//  FetchFromUrl+Async.swift
//  Nitter
//
//  Created by Bronson Lane on 12/15/23.
//

import Foundation

func fetchFromURL(_ url: URL) async -> String{
    do {
        let session = URLSession.shared
        let (theStringAsData, _) = try await session.data(from: url)
        if let returnableString = String(data: theStringAsData, encoding: .utf8)
        {
            return returnableString
        } else {
            return ""
        }
    } 
    catch {
        return ""
    }
}
