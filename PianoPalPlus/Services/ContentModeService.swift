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
    case freePlay, earTraining(EarTrainingItem), theory(TheoryModeItem)
    
    func title() -> String {
        switch self {
        case .earTraining(let item):
            return "Ear Training - \(item.title())"
        case .theory(let item):
            return "Theory \(item.asString())"
        default:
            return "Free Play \0/"
        }
    }
    
    func description() -> String? {
        switch self {
        case .earTraining(let item):
            return "practice ear training: \(item.description() ?? "")"
        case .theory(_):
            return "study theory"
        default:
            return nil
        }
    }
}

class ContentModeService {
    static let shared = ContentModeService()
    @Published var contentMode: ContentMode = .freePlay
    @Published var contentVC: ContentVC = .piano
    private let deepLinkService: DeepLinkService
    
    init(deepLinkService: DeepLinkService = .shared) {
        self.deepLinkService = deepLinkService
        
        setupSubscriptions()
    }
    
    private var cancellables = Set<AnyCancellable>()
    private func setupSubscriptions() {
        deepLinkService.$deepLink
            .filter({ $0 != nil })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { deepLink in
                guard let deepLink = deepLink else { return }
                switch deepLink.deeplinkId {
                case .session:
                    self.contentMode = .theory(.library(deepLink as? Session))
                }
            }).store(in: &cancellables)
    }
    
}
