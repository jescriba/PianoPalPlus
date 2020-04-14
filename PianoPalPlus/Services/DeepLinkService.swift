//
//  DeepLinkService.swift
//  PianoPalPlus
//
//  Created by joshua on 4/13/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import UIKit
import Combine

class DeepLink {
    static let scheme = "pianopalplus"
}

enum DeepLinkId: String {
    case session
}

protocol DeepLinkable: Codable {
    var deeplinkId: DeepLinkId { get }
}

class DeepLinkService {
    static let shared = DeepLinkService()
    @Published var deepLink: DeepLinkable?
    
    func handle(url: URL) {
        deepLink = DeepLinkService.deeplink(from: url)
    }
    
    static func deeplink(from url: URL) -> DeepLinkable? {
        guard url.scheme == DeepLink.scheme,
            let host = url.host,
            let id = DeepLinkId(rawValue: host) else {
                return nil
        }
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard let json = components?.queryItems?.first(where: { $0.name == "json" })?.value,
            let data = json.data(using: .utf8) else {
                return nil
        }
        
        switch id {
        case .session:
            return try? JSONDecoder().decode(Session.self, from: data)
        }
    }
    
    static func url<T: DeepLinkable>(for deeplinkable: T) -> URL? {
        guard let encoded = try? JSONEncoder().encode(deeplinkable),
            let json = String(data: encoded, encoding: .utf8),
            let jsonURL = json.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else {
                return nil
        }
        return URL(string: "\(DeepLink.scheme)://\(deeplinkable.deeplinkId.rawValue)?json=\(jsonURL)")
    }
    
}
