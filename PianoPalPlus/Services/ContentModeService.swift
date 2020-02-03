//
//  ContentModeService.swift
//  PianoPalPlus
//
//  Created by joshua on 2/1/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import Combine

enum ContentMode: Equatable {
    case freePlay, earTraining(EarTrainingItem), theory
    
    func title() -> String {
        switch self {
        case .earTraining(let item):
            return "Ear Training - \(item.title())"
        default:
            return "free play"
        }
    }
    
    func description() -> String? {
        switch self {
        case .earTraining(let item):
            return "practice ear training: \(item.description() ?? "")"
        default:
            return nil
        }
    }
}

class ContentModeService {
    static let shared = ContentModeService()
    @Published var contentMode: ContentMode = .freePlay
    
}
