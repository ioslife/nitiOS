//
//  SettingsViewModel.swift
//  Nitter
//
//  Created by Bronson Lane on 12/14/23.
//

import FeedKit
import SwiftUI

extension SettingsView {
    @MainActor class ViewModel: ObservableObject {
        @Published var subscribedFeeds = UserDefaults.standard.object(forKey: "subscribedFeeds") as? [String] ?? [String]()
        
        @Published var instanceBaseURL = UserDefaults.standard.object(forKey: "instanceBaseURL") as? String ?? "nitter.x86-64-unknown-linux-gnu.zip"
        
        @Published var isLoading: Bool = false
        
        @Published var showingSearchAlert: Bool = false
        @Published var showingConfirmationDialog: Bool = false
        
        @Published var searchUsername: String = ""
        
        func updateInstanceURL() {
            Constants.updateConstants(instanceBaseURL: instanceBaseURL)
            UserDefaults.standard.set(instanceBaseURL, forKey: "instanceBaseURL")
            showingConfirmationDialog.toggle()
        }
        
        func updateFollowList() {
            subscribedFeeds = UserDefaults.standard.object(forKey: "subscribedFeeds") as? [String] ?? [String]()
        }
        
        func followUser() {
            subscribedFeeds.append(self.searchUsername)
            UserDefaults.standard.set(subscribedFeeds, forKey: "subscribedFeeds")
            searchUsername = ""
        }
        
        func deleteItems(at offsets: IndexSet) {
            subscribedFeeds.remove(atOffsets: offsets)
            UserDefaults.standard.set(subscribedFeeds, forKey: "subscribedFeeds")
        }
    }
}
