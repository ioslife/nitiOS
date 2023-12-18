//
//  SearchViewModel.swift
//  Nitter
//
//  Created by Bronson Lane on 12/17/23.
//

import FeedKit
import SwiftUI
import SwiftSoup

extension SearchView {
    @MainActor class ViewModel: ObservableObject {
        init(searchText: String = "", searchType: String = "tweets") {
            self.searchText = searchText
            self.searchType = searchType
        }
        
        @Published var feeds: [Feed] = []
        @Published var tweets: [Tweet] = []
        
        @Published var isLoading: Bool = true
        @Published var isRefreshing: Bool = false
        
        @Published var searchText: String = ""
        @Published var searchType: String = ""
        @Published var isSearching: Bool = false
        
        func search() async {
            if self.searchText == "" {
                self.isSearching = false
            } else {
                self.tweets = []
                self.feeds = []
                self.isSearching = true
                if self.isRefreshing || feeds.count == 0 {
                    self.isLoading = true
                    if searchText != "" {
                        self.feeds = await self.getFeeds(for: [URL(string: "\(Constants.instanceHTTPS)/search/rss?f=\(searchType)&q=\(searchText)")!])
                    }
                }
            }
        }
        
        func getTweets() -> [Tweet] {
            return tweets.sorted(by: { $0.details.pubDate! > $1.details.pubDate! })
        }
        
        func getImagesFromTweet(tweet: String) -> [String?] {
            do {
                let doc: Document = try SwiftSoup.parse(tweet)
                let srcs: Elements = try doc.select("img[src]")
                let srcsStringArray: [String?] = srcs.array().map { try? $0.attr("src").description }
                
                return srcsStringArray
            } catch Exception.Error(_, let message) {
                print(message)
            } catch {
                print("error")
            }
            return []
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
                                if isRetweet(string: item.title!) {
                                    item.description! = prependRetweetText(tweet: item)
                                } else if isReply(string: item.title!) {
                                    item.description! = prependReplyText(tweet: item)
                                }
                                tweets.insert(Tweet(details: item, profilePicURL: feed.rssFeed!.image?.url ?? "", authorName: "", authorUsername: item.dublinCore!.dcCreator!), at: 0)
                           }
                        }
                    }
                }
                return result
            }
            self.isLoading = false
            return taskResult
        }
        
        func isRetweet(string: String) -> Bool {
            return string.hasPrefix("RT")
        }
        
        func prependRetweetText(tweet: RSSFeedItem) -> String {
            return "RT from <a href='nitios://\(tweet.dublinCore!.dcCreator!.replacingOccurrences(of: "@", with: ""))'>\(tweet.dublinCore!.dcCreator!)</a>: \(tweet.description!)"
        }
        
        func isReply(string: String) -> Bool {
            return string.hasPrefix("R to @")
        }
        
        func prependReplyText(tweet: RSSFeedItem) -> String {
            let replyToUser: String = getTextBetweenAtAndColon(string: tweet.title!)!
            return "Replying to <a href='nitios://\(replyToUser)'>@\(replyToUser)</a>: \(tweet.description!)"
        }
        
        func getTextBetweenAtAndColon(string: String) -> String? {
            let range = string.range(of: "@")
            if let range = range {
                let start = string.index(after: range.lowerBound)
                if let colonRange = string.range(of: ":", range: start..<string.endIndex) {
                    return String(string[start..<colonRange.lowerBound])
                }
            }
            return nil
        }
    }
}
