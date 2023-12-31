//
//  SettingsView.swift
//  Nitter
//
//  Created by Bronson Lane on 12/14/23.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: ViewModel
    
    var body: some View {
        List {
            Section(header: Text("Current Instance")) {
                TextField("Instance URL", text: $viewModel.instanceBaseURL)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                Button {
                    viewModel.updateInstanceURL()
                } label: {
                    HStack {
                        Spacer()
                        Text("Save")
                        Spacer()
                    }
                }
            }
            Section(header: Text("Followed Users")) {
                if (viewModel.subscribedFeeds.count == 0) {
                    Text("You aren't currently following anyone.")
                } else {
                    ForEach (viewModel.subscribedFeeds.sorted(by: { $0 > $1 }), id: \.self) { username in
                        Text("@\(username)")
                        .redacted(reason: viewModel.isLoading ? .placeholder : [])
                    }
                    .onDelete(perform: { indexSet in
                        viewModel.deleteItems(at: indexSet)
                    })
                }
                Button {
                    
                    viewModel.showingSearchAlert.toggle()
                    
                } label: {
                    HStack {
                        Spacer()
                        Text("Add User")
                        Spacer()
                    }
                }
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
                .alert("Instance Updated", isPresented: $viewModel.showingConfirmationDialog) {
                    HStack {
                        Button("Dismiss", role: .cancel) { }
                    }
                } message: {
                    Text("The instance has been updated to \(Constants.instanceBaseURL). If it does not work, ensure this instance supports RSS feeds.")
                }
            }
        }
        .onAppear() {
            viewModel.updateFollowList()
        }
    }
}

#Preview {
    SettingsView(viewModel: SettingsView.ViewModel())
}
