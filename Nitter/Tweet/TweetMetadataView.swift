//
//  TweetMetadataView.swift
//  Nitter
//
//  Created by Bronson Lane on 12/14/23.
//

import SwiftUI

struct TweetMetadataView: View {
    var profilePicURL: String = ""
    var tweet: Tweet
    var body: some View {
        NavigationLink(destination: ProfileView(username: tweet.authorUsername.replacingOccurrences(of: "@", with: "").trimmingCharacters(in: .whitespaces))) {
            HStack {
                AsyncImage(url: URL(string: profilePicURL)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Image(systemName: "square.fill")
                        .resizable()
                        .blur(radius: 100)
                }
                .background(Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .frame(width: 35, height: 35)
                VStack(alignment: .leading) {
                    HStack(spacing: 5) {
                        Text(tweet.authorName.trimmingCharacters(in: .whitespaces))
                            .bold()
                        Text(tweet.authorUsername.trimmingCharacters(in: .whitespaces))
                            .font(.caption)
                            .fontWeight(.light)
                    }
                    Text(calculateTimeSince(date: tweet.details.pubDate!))
                }
            }
        }
        .buttonStyle(.plain)
    }
}
