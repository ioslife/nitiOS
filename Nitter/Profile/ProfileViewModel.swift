//
//  ProfileViewModel.swift
//  Nitter
//
//  Created by Bronson Lane on 12/15/23.
//

import SwiftUI
import SwiftSoup

extension ProfileView {
    @MainActor class ViewModel: ObservableObject {
        @Published var subscribedFeeds = UserDefaults.standard.object(forKey: "subscribedFeeds") as? [String] ?? [String]()
        @Published var profile: ProfileInfo = ProfileInfo(fullName: "Mock Full Name", username: "MockUsername", bio: "This is my mock bio", location: "location", website: "mock website", joinDate: "Joined on a date", postCount: "999", followingCount: "999", followerCount: "999")
        @Published var username: String
        
        var isLoading: Bool = true
        
        init(username: String) {
            self.username = username
        }
        
        func loadViewData() async {
            await getProfileInfo(username: username)
        }
        
        func getProfileInfo(username: String) async {
            
                let url = URL(string:"\(Constants.instanceHTTPS)/\(username)")!
                let html = await fetchFromURL(url)
                do {
                    let document = try SwiftSoup.parse(html)

                    let profileBannerClass = try document.getElementsByClass("profile-banner").first() ?? Element.init(Tag(""), "")
                    let profileBannerLink = try profileBannerClass.select("a").first  ?? Element.init(Tag(""), "")
                    let profileBannerPath = try profileBannerLink.attr("href")
                    self.profile.bannerURL = Constants.instanceHTTPS + profileBannerPath
                    
                    
                    let avatarClass = try document.getElementsByClass("profile-card-avatar").first() ?? Element.init(Tag(""), "")
                    let avatarPath = try avatarClass.attr("href")
                    self.profile.profilePicURL = Constants.instanceHTTPS + avatarPath
                    
                    let fullNameClass = try document.getElementsByClass("profile-card-fullname").first() ?? Element.init(Tag(""), "")
                    let fullName = try fullNameClass.text()
                    self.profile.fullName = fullName
                    
                    let isVerified = isVerifiedAccount(document: fullNameClass)
                    self.profile.isVerified = isVerified
                    
                    let usernameClass = try document.getElementsByClass("profile-card-username").first() ?? Element.init(Tag(""), "")
                    let username = try usernameClass.text()
                    self.profile.username = username
                    
                    let bioClass = try document.getElementsByClass("profile-bio").first() ?? Element.init(Tag(""), "")
                    let bio = try bioClass.text()
                    self.profile.bio = bio
                    
                    let locationClass = try document.getElementsByClass("profile-location").first() ?? Element.init(Tag(""), "")
                    let location = try locationClass.text()
                    self.profile.location = location
                    
                    let websiteClass = try document.getElementsByClass("profile-website").first() ?? Element.init(Tag(""), "")
                    let website = try websiteClass.text()
                    self.profile.website = website
                    
                    let joinDateClass = try document.getElementsByClass("profile-joindate").first() ?? Element.init(Tag(""), "")
                    let joinDate = try joinDateClass.text()
                    self.profile.joinDate = joinDate
                    
                    
                    let statListClass = try document.getElementsByClass("profile-statlist").first() ?? Element.init(Tag(""), "")
                    let postsClass = try statListClass.getElementsByClass("posts").first() ?? Element.init(Tag(""), "")
                    let postCountClass = try postsClass.getElementsByClass("profile-stat-num").first() ?? Element.init(Tag(""), "")
                    let postCount = try postCountClass.text()
                    self.profile.postCount = shortenNumberString(numberString: postCount)
                    
                    let followingClass = try statListClass.getElementsByClass("following").first() ?? Element.init(Tag(""), "")
                    let followingCountClass = try followingClass.getElementsByClass("profile-stat-num").first() ?? Element.init(Tag(""), "")
                    let followingCount = try followingCountClass.text()
                    self.profile.followingCount = shortenNumberString(numberString: followingCount)
                    
                    let followersClass = try statListClass.getElementsByClass("followers").first() ?? Element.init(Tag(""), "")
                    let followersCountClass = try followersClass.getElementsByClass("profile-stat-num").first() ?? Element.init(Tag(""), "")
                    let followersCount = try followersCountClass.text()
                    self.profile.followerCount = shortenNumberString(numberString: followersCount)
                    
                } catch {}
            isLoading = false
        }
        
        func updateFollowList() {
            subscribedFeeds = UserDefaults.standard.object(forKey: "subscribedFeeds") as? [String] ?? [String]()
        }
        
        func isOnFollowList(username: String) -> Bool {
            return subscribedFeeds.contains(username.replacingOccurrences(of: "@", with: "").trimmingCharacters(in: .whitespaces))
        }
        
        func removeFromFollowList(userName: String) {
            if let index = subscribedFeeds.firstIndex(of: userName.replacingOccurrences(of: "@", with: "").trimmingCharacters(in: .whitespaces)) {
                subscribedFeeds.remove(at: index)
            }
            UserDefaults.standard.set(subscribedFeeds, forKey: "subscribedFeeds")
        }
        
        func followUser() {
            subscribedFeeds.append(self.username.replacingOccurrences(of: "@", with: "").trimmingCharacters(in: .whitespaces))
            UserDefaults.standard.set(subscribedFeeds, forKey: "subscribedFeeds")
        }
        
        func deleteItems(at offsets: IndexSet) {
            subscribedFeeds.remove(atOffsets: offsets)
            UserDefaults.standard.set(subscribedFeeds, forKey: "subscribedFeeds")
        }
        
        func isVerifiedAccount(document: Element) -> Bool {
            do {
                let verified = try document.getElementsByClass("icon-container").first()
                if verified != nil {
                    return true
                }
                return false
            }
            catch {
            }
            return false
        }
        
        func hasHomeButton() -> Bool {
            let keyWindow = UIApplication
                .shared
                .connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .last
            
            if keyWindow?.safeAreaInsets.bottom ?? 0 > 0 {
                return false
              }
            return true
        }
        
        func isDarkModeEnabled(colorScheme: ColorScheme) -> Bool {
            return colorScheme == ColorScheme.dark
        }
    }
}

struct ProfileInfo {
    var bannerURL: String = ""
    var profilePicURL: String = ""
    var fullName: String = ""
    var username: String = ""
    var isVerified: Bool = false
    var bio: String = ""
    var location: String = ""
    var website: String = ""
    var joinDate: String = ""
    var postCount: String = ""
    var followingCount: String = ""
    var followerCount: String = ""
}

