//
//  NitterApp.swift
//  Nitter
//
//  Created by Bronson Lane on 12/14/23.
//

import SwiftUI

@main
struct NitterApp: App {
    var body: some Scene {
        WindowGroup {
            AppShellView()
        }
    }
}


struct AppShellView: View {
    @State private var selectedTab = "One"
    @State private var isGameDeepLinkPushed = false
    @State private var isUserDeepLinkPushed = false
//    @AppStorage("deepLinkProfile") var deepLinkGameProfile = 0
    @AppStorage("deepLinkUsername") var deepLinkUsername = ""
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                TimelineView(viewModel: TimelineView.ViewModel())
                    .navigationTitle(Text("Home"))
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationDestination(isPresented: $isUserDeepLinkPushed) {
                        ProfileView(username: deepLinkUsername)
                    }
            }
            .tag("One")
            .tabItem {
                Label("Timeline", systemImage: "rectangle.stack")
            }
            .onOpenURL { url in
                if case .username(let username) = url.userDetailPage {
                    deepLinkUsername = username
                    isUserDeepLinkPushed = true
                }
            }
            
            NavigationStack {
                SettingsView(viewModel: SettingsView.ViewModel())
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag("Two")
        }
    }
}
