//
//  StringFormatter.swift
//  Nitter
//
//  Created by Bronson Lane on 12/15/23.
//

import Foundation

func shortenNumberString(numberString: String) -> String {
    let number = Double(numberString.replacingOccurrences(of: ",", with: "")) ?? 0
    if number < 1000 {
        return numberString
    } else if number < 1000000 {
        let shortened = String(format: "%.1fK", number/1000)
        return shortened
    } else {
        let shortened = String(format: "%.2fM", number/1000000)
        return shortened
    }
}
