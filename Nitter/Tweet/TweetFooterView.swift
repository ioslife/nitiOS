//
//  TweetFooterView.swift
//  Nitter
//
//  Created by Bronson Lane on 12/14/23.
//

import SwiftUI

struct TweetFooterView: View {
    var tweetURL: String
    var body: some View {
        HStack(alignment: .center) {
            ShareLink(item: URL(string: tweetURL)!) {
                Image(systemName: "square.and.arrow.up")
            }
            .buttonStyle(.plain)
            Image(systemName: "bookmark")
        }
        .padding(.vertical, 5)
    }
}
