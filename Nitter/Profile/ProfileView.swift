//
//  ProfileView.swift
//  Nitter
//
//  Created by Bronson Lane on 12/15/23.
//

import SwiftUI

import SwiftUI
import ScalingHeaderScrollView

struct ProfileView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.presentationMode) var presentationMode
    @State private var isUserDeepLinkPushed = false
    @AppStorage("deepLinkUsername") var deepLinkUsername = ""
    
    @StateObject private var viewModel: ViewModel
    
    
    init(username: String = "Braves") {
        _viewModel = StateObject(wrappedValue: ViewModel(username: username))
    }
    
    @State private var selectedTab: Tab = .tweets
    
    @State var progress: CGFloat = 0
    
    private let minHeightHomeButton = 75.0
    private let minHeightModern = 115.0
    private let maxHeight = 200.0
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScalingHeaderScrollView {
                    ZStack {
                        viewModel.isDarkModeEnabled(colorScheme: colorScheme) ? Color.black.edgesIgnoringSafeArea(.all) : Color.white.edgesIgnoringSafeArea(.all)
                        largeHeader(progress: progress)
                    }
                    
                } content: {
                    ZStack(alignment: .topTrailing) {
                        VStack(alignment: .leading) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(viewModel.profile.fullName)
                                        .font(.headline)
                                    Text(viewModel.profile.username)
                                        .font(.subheadline)
                                    HStack() {
                                        Image(systemName: "calendar")
                                        Text(viewModel.profile.joinDate)
                                    }
                                    .font(.footnote)
                                    .fontWeight(.light)
                                }
                                Spacer()
                                HStack {
                                    VStack {
                                        Text("Tweets")
                                            .font(.caption)
                                        Text(viewModel.profile.postCount)
                                            .font(.headline)
                                    }
                                    VStack {
                                        Text("Following")
                                            .font(.caption)
                                        Text(viewModel.profile.followingCount)
                                            .font(.headline)
                                    }
                                    VStack {
                                        Text("Followers")
                                            .font(.caption)
                                        Text(viewModel.profile.followerCount)
                                            .font(.headline)
                                    }
                                }
                            }
                            .redacted(reason: viewModel.isLoading ? .placeholder : [])
                            HStack {
                                Text(viewModel.profile.bio)
                                    .padding(.top)
                                    .redacted(reason: viewModel.isLoading ? .placeholder : [])
                                Spacer()
                                withAnimation {
                                    Button(
                                        action: {
                                            if viewModel.isOnFollowList(username: viewModel.profile.username) {
                                                viewModel.removeFromFollowList(userName: viewModel.profile.username)
                                            } else {
                                                viewModel.followUser()
                                            }
                                        },
                                        label: {
                                            if viewModel.isOnFollowList(username: viewModel.profile.username) {
                                                Text("Following")
                                            } else {
                                                Text("Follow")
                                            }
                                        })
                                    .buttonStyle(.bordered)
                                }
                            }
                            
                            .padding(.bottom)
                                
                            Picker("", selection: $selectedTab) {
                              ForEach(Tab.accountTabs,
                                      id: \.self)
                              { tab in
                                Image(systemName: tab.iconName)
                                  .tag(tab)
                              }
                            }
                            .pickerStyle(.segmented)
                            .padding(.vertical)
                            .id("status")
                            
                            switch selectedTab {
                            case .tweets:
//                                EmptyView()
                                TimelineView(viewModel: TimelineView.ViewModel(profileUsername: viewModel.username))
                                    .padding(.horizontal, -10)
                                    .redacted(reason: viewModel.isLoading ? .placeholder : [])
                            case .replies:
                                EmptyView()
//                                CompletionProgressView(viewModel: viewModel.completionProgressViewModel)
                            case .media:
                                EmptyView()
//                                RecentAchievementsView(viewModel: viewModel.recentAchievementsViewModel)
                            }
                        }
                        .padding()
                    }
                }
                .height(min: viewModel.hasHomeButton() ? minHeightHomeButton : minHeightModern, max: maxHeight)
                .collapseProgress($progress)
                .setHeaderSnapMode(.afterFinishAccelerating)
                
            }
            .edgesIgnoringSafeArea(.top)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .task {
            await viewModel.loadViewData()
        }
    }
    
    private func largeHeader(progress: CGFloat) -> some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: URL(string: viewModel.profile.bannerURL)) { image in
                image
                    .resizable()
            } placeholder: {
                Image(systemName: "square.fill")
                    .resizable()
                    .blur(radius: 100)
            }
            .blur(radius: 1)
                .scaledToFill()
                .frame(height: maxHeight)
                .opacity(1 - progress)
            
            AsyncImage(url: URL(string: viewModel.profile.profilePicURL)) { image in
                image
                    .resizable()
            } placeholder: {
                Image(systemName: "square.fill")
                    .resizable()
                    .blur(radius: 100)
            }
            .frame(width: 75, height: 75)
            .clipShape(RoundedRectangle(cornerRadius: 5.0))
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(viewModel.isDarkModeEnabled(colorScheme: colorScheme) ? Color.white : Color.black, lineWidth: 1))
            .opacity(1 - progress)
            .padding()
            .zIndex(1)
            
            
            ZStack {
                if colorScheme == ColorScheme.dark {
                    RoundedRectangle(cornerRadius: 40.0, style: .circular)
                        .foregroundColor(.clear)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.black.opacity(0.0), .black]), startPoint: .top, endPoint: .bottom)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 40.0, style: .circular)
                        .foregroundColor(.clear)
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.white.opacity(0.0), .white]), startPoint: .top, endPoint: .bottom)
                        )
                }
                smallHeader
                    .opacity(progress)
                    .opacity(max(0, min(1, (progress - 0.75) * 4.0)))
            }
            .frame(height: 80.0)
            
        }
        .redacted(reason: viewModel.isLoading ? .placeholder : [])
    }
    
    private var smallHeader: some View {
        HStack(spacing: 12.0) {
            AsyncImage(url: URL(string: viewModel.profile.profilePicURL)) { image in
                image
                    .resizable()
            } placeholder: {
                Image(systemName: "square.fill")
                    .resizable()
                    .blur(radius: 100)
            }
                .frame(width: 40.0, height: 40.0)
                .clipShape(RoundedRectangle(cornerRadius: 6.0))
                .redacted(reason: viewModel.isLoading ? .placeholder : [])

            Text(viewModel.profile.username)
        }
    }
    
    struct VisualEffectView: UIViewRepresentable {

        var effect: UIVisualEffect?

        func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
        func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
    }
}

#Preview {
    ProfileView()
}
extension ProfileView {
    
    struct HeroImageView: View {
        var imageURL: String
        var body: some View {
            AsyncImage(url: URL(string: "https://retroachievements.org\(imageURL)")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay(.black.opacity(0.50))
                    .frame(height: 200)
                    .clipped()
            } placeholder: {
                Image(systemName: "square.fill")
                    .resizable()
            }
            .frame(height: 200)
        }
    }

    enum Tab: Int {
        case tweets, replies, media
        
        static var accountTabs: [Tab] {
            [.tweets, .replies, .media]
        }
        
        var iconName: String {
            switch self {
            case .tweets: "bubble"
            case .replies: "bubble.left.and.bubble.right"
            case .media: "photo"
            }
        }
    }
}

