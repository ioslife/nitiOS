//
//  FeedKitViewModel.swift
//  Nitter
//
//  Created by Bronson Lane on 12/14/23.
//

import FeedKit
import SwiftUI
import SwiftSoup

extension TimelineView {
    @MainActor class ViewModel: ObservableObject {
        var subscribedFeeds = UserDefaults.standard.object(forKey: "subscribedFeeds") as? [String] ?? [String]()
        var profileUsername: String
        
        init(profileUsername: String = "") {
            self.profileUsername = profileUsername
        }
        
        @Published var feeds: [Feed] = []
        @Published var tweets: [Tweet] = []
        
        @Published var parsedCount: Int = 0
        
        @Published var isLoading: Bool = true
        @Published var isRefreshing: Bool = false
        
        @Published var showingSearchAlert: Bool = false
        
        @Published var searchUsername: String = ""
        
        func loadViewData() async {
            if self.isRefreshing || feeds.count == 0 {
                self.isLoading = true
                if profileUsername == "" {
                    self.feeds = await self.getFeeds(for: getFollowedUsers())
                } else {
                    self.feeds = await self.getFeeds(for: [URL(string: "\(Constants.instanceHTTPS)/\(profileUsername)/rss")!])
                }
                self.parsedCount = feeds.count
            }
        }
        
        //Search URL
//                URL(string: "https://nitter.1d4.us/search/rss?q=%23Braves")!
        
        
        func getFollowedUsers() -> [URL] {
            subscribedFeeds = UserDefaults.standard.object(forKey: "subscribedFeeds") as? [String] ?? [String]()
            var followedUsers: [URL] = []
            for username in subscribedFeeds {
                followedUsers.append(URL(string: "\(Constants.instanceHTTPS)/\(username)/rss")!)
            }
            
            return followedUsers
        }
        
        func getTweets() -> [Tweet] {
            return tweets.sorted(by: { $0.details.pubDate! > $1.details.pubDate! })
        }
        
        func getFeeds(for feedURLs: [URL]) async -> [Feed] {
            let taskResult = await withTaskGroup(of: Optional<Feed>.self, returning: [Feed].self) { group in
                for feedURL in feedURLs {
                    group.addTask {
                        let parser = FeedParser(URL: feedURL)
                        let result = await parser.asyncParse()
                        switch result {
                        case let .success(feed):
                            return (feed)
                        case .failure(_):
                            return (nil)
                        }
                    }
                }
                
                var result: [Feed] = []
                for await feedResult in group {
                    if let feed = feedResult {
                        result.append(feed)
                        
                        for item in feed.rssFeed!.items! {
                            if !tweets.contains(where: { $0.details.guid == item.guid }) {
                                let author = feed.rssFeed!.title!.split(separator: "/")
                                
                                if isRetweet(string: item.title!) {
                                    item.description! = prependRetweetText(tweet: item)
                                    tweets.insert(Tweet(details: item, profilePicURL: feed.rssFeed!.image!.url!, authorName: String(author.first!), authorUsername: String(author.last!)), at: 0)
                                } else {
                                    tweets.insert(Tweet(details: item, profilePicURL: feed.rssFeed!.image!.url!, authorName: String(author.first!), authorUsername: String(author.last!)), at: 0)
                                }
                           }
                        }
                    }
                }
                return result
            }
            self.isLoading = false
            return taskResult
        }
        
        func prependRetweetText(tweet: RSSFeedItem) -> String {
            return "RT from <a href='nitios://\(tweet.dublinCore!.dcCreator!.replacingOccurrences(of: "@", with: ""))'>\(tweet.dublinCore!.dcCreator!)</a>: \(tweet.description!)"
        }
        
        func isRetweet(string: String) -> Bool {
            return string.hasPrefix("RT")
        }
        
        func followUser() {
            subscribedFeeds.append(self.searchUsername)
            UserDefaults.standard.set(subscribedFeeds, forKey: "subscribedFeeds")
            searchUsername = ""
        }
    }
}


