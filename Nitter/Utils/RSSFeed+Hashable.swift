//
//  RSSFeed+Hashable.swift
//  Nitter
//
//  Created by Bronson Lane on 12/15/23.
//

import FeedKit

extension RSSFeedItem: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(pubDate)
        hasher.combine(author)
        hasher.combine(description)
        hasher.combine(title)
    }
}

extension RSSFeed: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
}
