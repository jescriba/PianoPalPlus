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
    var modifiedDate: Date = Date()
    
    enum CodingKeys: String, CodingKey {
        case id, title, progression
    }
    
    init(id: String = UUID().uuidString,
         title: String = String.todaysDate(),
         progression: Progression = Progression(items: []),
         modifiedDate: Date = Date()) {
        self.id = id
        self.title = title
        self.progression = progression
        self.modifiedDate = modifiedDate
    }
    
}
