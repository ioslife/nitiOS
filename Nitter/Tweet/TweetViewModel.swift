//
//  TweetViewModel.swift
//  Nitter
//
//  Created by Bronson Lane on 12/15/23.
//

import SwiftSoup
import Foundation

extension TweetContentView {
    @MainActor class ViewModel: ObservableObject {
        
        func getTweet(tweet: String) -> String {
            let parsedTweet = parseTweetHTML(tweet: tweet)
            let linksInTweet = getLinksFromTweet(tweet: tweet)
            
            return replaceLinks(parsedTweet, linksInTweet)
        }
        
        func parseTweetHTML(tweet: String) -> String {
            do {
               let doc: Document = try SwiftSoup.parse(tweet)
               return try doc.text()
            } catch Exception.Error(_, let message) {
                print(message)
            } catch {
                print("error")
            }
            return ""
        }
        
        func replaceLinks(_ text: String, _ links: [Link]) -> String {
            var result = text
            for link in links {
                result = result.replacingOccurrences(of: link.text, with: "[\(link.text)](\(link.url))")
            }
            return result
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
        
        func getLinksFromTweet(tweet: String) -> [Link] {
            var links: [Link] = []
            guard let els: Elements = try? SwiftSoup.parse(tweet).select("a") else { return links }
            for element: Element in els.array() {
                let url = try! element.attr("href")
                if (url.hasPrefix(Constants.instanceHTTPS) || url.hasPrefix(Constants.instanceHTTP)) {
                    var nitiOSURL = url.replacingOccurrences(of: Constants.instanceHTTPS, with: "nitios:/").replacingOccurrences(of: Constants.instanceHTTP, with: "nitios:/")
                    links.append(Link(text: try! element.text(), url: nitiOSURL))
                } else {
                    links.append(Link(text: try! element.text(), url: url))
                }
            }
            
            return links
        }
    }
}

struct Link {
    var text: String
    var url: String
}
