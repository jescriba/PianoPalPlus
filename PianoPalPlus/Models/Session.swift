//
//  Session.swift
//  PianoPalPlus
//
//  Created by joshua on 4/13/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation

typealias Sessions = [Session]

struct Session: Codable, DeepLinkable {
    var deeplinkId: DeepLinkId = .session
    var id: String
    var title: String
    var progression: Progression
    
    enum CodingKeys: String, CodingKey {
        case id, title, progression
    }
    
    init(id: String,
         title: String,
         progression: Progression) {
        self.id = id
        self.title = title
        self.progression = progression
    }
    
//    init(url: URL) {
//        
//    }
    
}
