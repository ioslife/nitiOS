//
//  Tweet.swift
//  Nitter
//
//  Created by Bronson Lane on 12/14/23.
//

import Foundation
import FeedKit

struct Tweet: Hashable {
    var details: RSSFeedItem
    var profilePicURL: String
    var authorName: String
    var authorUsername: String
}
