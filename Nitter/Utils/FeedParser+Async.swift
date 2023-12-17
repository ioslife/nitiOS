//
//  FeedKit+Extension.swift
//  Nitter
//
//  Created by Bronson Lane on 12/14/23.
//

import SwiftUI
import FeedKit

extension FeedParser {
    func asyncParse() async -> Result<Feed, ParserError> {
        await withCheckedContinuation { continuation in
            self.parseAsync(queue: DispatchQueue(label: "my.concurrent.queue", attributes: .concurrent)) { result in
                continuation.resume(returning: result)
            }
        }
    }
}
