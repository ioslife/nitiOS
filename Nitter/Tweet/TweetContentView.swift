//
//  TweetContentView.swift
//  Nitter
//
//  Created by Bronson Lane on 12/14/23.
//

import SwiftUI

struct TweetContentView: View {
    @StateObject var viewModel: ViewModel
    var tweet: String = ""
    var body: some View {
        EmptyView()
        VStack(alignment: .leading) {
            Text(.init(viewModel.getTweet(tweet: tweet)))
            
            if !viewModel.getImagesFromTweet(tweet: tweet).isEmpty {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 0) {
                        ForEach(viewModel.getImagesFromTweet(tweet: tweet), id: \.self) { imageURL in
                            AsyncImage(url: URL(string: imageURL!)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                Image(systemName: "square.fill")
                                    .resizable()
                                    .blur(radius: 100)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 25.0))
                            .padding(.horizontal, 20)
                            .containerRelativeFrame(.horizontal)
                        }
                    }
                }
                .scrollTargetBehavior(.paging)
            }
        }
    }
}
