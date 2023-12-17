//
//  DeepLinkManager.swift
//  Nitter
//
//  Created by Bronson Lane on 12/16/23.
//

import Foundation

enum LinkIdentifier: Hashable {
  case search
}

enum PageIdentifier: Hashable {
    case username(name: String)
}

extension URL {
    var isDeeplink: Bool {
        return scheme == "nitios" // matches nitios://<rest-of-the-url>
    }

    var linkIdentifier: LinkIdentifier? {
        guard isDeeplink else { return nil }
        
        switch host {
        case "search":
            return .search // matches nitios://search
        default:
            return nil
        }
    }
    
    var userDetailPage: PageIdentifier? {
        var username = absoluteString.replacingOccurrences(of: "nitios://", with: "")

      switch linkIdentifier {
      case .search: return nil // matches my-url-scheme://home/<item-uuid-here>/
          default: return .username(name: username)
      }
    }
}
