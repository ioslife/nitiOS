//
//  FeedKitView.swift
//  Nitter
//
//  Created by Bronson Lane on 12/14/23.
//

import FeedKit
import SwiftUI
import RichText

struct TimelineView: View {
    @StateObject var viewModel: ViewModel
        
    var body: some View {
        if (viewModel.getFollowedUsers().count == 0) {
            EmptyFollowingListView(viewModel: viewModel)
        } else {
            NavigationStack {
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
                    await viewModel.loadViewData()
                }
                .task {
                    await viewModel.loadViewData()
                }
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
    
    
//                                RichText(html: tweet.details.description!)
//                                    .lineHeight(150)
//                                    .imageRadius(12)
//                                    .foregroundColor(light: Color.primary, dark: .white)
//                                    .linkColor(light: Color.blue, dark: Color.blue)
//                                    .linkOpenType(.SFSafariView())
//                                    .placeholder {
//                                        Text("Redacted Redacted Redacted Redacted Redacted Redacted Redacted Redacted Redacted Redacted Redacted Redacted Redacted Redacted Redacted")
//                                            .redacted(reason: .placeholder)
//                                    }
//                                    .transition(.easeOut)
    
    struct EmptyFollowingListView: View {
        @StateObject var viewModel: ViewModel
        
        var body: some View {
            ZStack {
                VStack {
                    Text("You aren't currently following anyone. Follow a user by tapping the button below. You can add more on the Settings page later.")
                        .multilineTextAlignment(.center)
                    Divider()
                    Button {
                        viewModel.showingSearchAlert.toggle()
                    } label: {
                        HStack {
                            Spacer()
                            Text("Add User")
                            Spacer()
                        }
                    }
                    .buttonStyle(.bordered)
                    .frame(width: 115)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(5)
                .background(Color(.systemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(.gray.opacity(0.35), lineWidth: 1)
                )
                .alert("Search for user", isPresented: $viewModel.showingSearchAlert) {
                    TextField("Username", text: $viewModel.searchUsername)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    
                    HStack {
                        Button("Cancel", role: .cancel) { }
                        Button {
                            viewModel.followUser()
                        } label: {
                            Text("Add")
                                .fontWeight(.heavy)
                        }
                    }
                }
            }
            .padding()
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView(viewModel: TimelineView.ViewModel(profileUsername: "Braves"))
    }
}


extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
