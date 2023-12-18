//
//  SearchView.swift
//  Nitter
//
//  Created by Bronson Lane on 12/17/23.
//

import SwiftUI

struct SearchView: View {
    @StateObject var viewModel: ViewModel
    var body: some View {
        VStack {
            if (!viewModel.isSearching) {
                EmptyFollowingListView(viewModel: viewModel)
            } else {
                ScrollView {
                    ForEach((viewModel.getTweets()), id: \.self) { tweet in
                        VStack(alignment: .leading) {
                            TweetView(tweet: tweet)
                            
                            //TODO: User this for share sheet later
                            //                            Button("Save to image") {
                            //                                let image = TweetView(tweet: tweet).snapshot()
                            //                                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                            //                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .redacted(reason: viewModel.isLoading ? .placeholder : [])
                .refreshable {
                    viewModel.isRefreshing.toggle()
                    await viewModel.search()
                }
            }
        }
        .searchable(text: $viewModel.searchText)
        .onSubmit(of: .search) {
            print("submit")
            Task {
                await viewModel.search()
            }
        }
    }
        
    struct TweetView: View {
        var tweet: Tweet
        var body: some View {
            TweetMetadataView(profilePicURL: tweet.profilePicURL, tweet: tweet)
            
            TweetContentView(viewModel: TweetContentView.ViewModel(), tweet: tweet.details.description ?? "")
                .multilineTextAlignment(.leading)
            
            TweetFooterView(tweetURL: tweet.details.link!)
            Divider()
        }
    }
        
    struct EmptyFollowingListView: View {
        @StateObject var viewModel: ViewModel
        
        var body: some View {
            ZStack {
                VStack {
                    Text("Search for something.")
                        .multilineTextAlignment(.center)
                }
                .padding()
            }
        }
    }
}
