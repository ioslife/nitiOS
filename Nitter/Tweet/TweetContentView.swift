//
//  TweetContentView.swift
//  Nitter
//
//  Created by Bronson Lane on 12/14/23.
//

import SwiftUI
import LazyPager

struct TweetContentView: View {
    @StateObject var viewModel: ViewModel
    @State var show = false
    @State var opacity: CGFloat = 1 // Dismiss gesture background opacity
    @State var index = 0
    
    var tweet: String = ""
    var body: some View {
        EmptyView()
        VStack(alignment: .leading) {
            Text(.init(viewModel.getTweet(tweet: tweet)))
            
            if !viewModel.getImagesFromTweet(tweet: tweet).isEmpty {
                TabView {
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
                        .onTapGesture {
                            index = viewModel.getImagesFromTweet(tweet: tweet).firstIndex(of: imageURL)!
                            show.toggle()
                        }
                    }
                }
                .frame(height: 350)
               .tabViewStyle(PageTabViewStyle())
               .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            }
        }
        .fullScreenCover(isPresented: $show) {
            LazyPager(data: viewModel.getImagesFromTweet(tweet: tweet), page: $index) { element in
                AsyncImage(url: URL(string: element!)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Image(systemName: "square.fill")
                        .resizable()
                        .blur(radius: 100)
                }
                .aspectRatio(contentMode: .fit)
            }
            .zoomable(min: 1, max: 5)
            .onDismiss(backgroundOpacity: $opacity) {
                show = false
            }
            .onTap {
                print("tap")
            }
            .background(.black.opacity(opacity))
            .background(ClearFullScreenBackground())
            .ignoresSafeArea()
        }
    }
}
