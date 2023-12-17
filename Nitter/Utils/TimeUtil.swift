//
//  TimeUtil.swift
//  Nitter
//
//  Created by Bronson Lane on 12/14/23.
//

import Foundation

func calculateTimeSince(date: Date) -> String {
    let now = Date()
    let timeInterval = now.timeIntervalSince1970 - date.timeIntervalSince1970
    
    
    return convertTimeIntervalToString(interval: timeInterval)
}

func convertTimeIntervalToString(interval: TimeInterval) -> String {
    let now = Date()
    let past = now.addingTimeInterval(-interval)
    
    let calendar = Calendar.current
    let components = calendar.dateComponents([.minute, .hour, .day], from: past, to: now)
    
    if components.day! == 1 {
        return "\(components.day!) day ago"
    } else if components.day! > 1 {
        return "\(components.day!) days ago"
    } else if components.hour! > 0 {
        return "\(components.hour!) hr. ago"
    } else if components.minute! > 0 {
        return "\(components.minute!) min. ago"
    } else {
        return "Just now"
    }
}
