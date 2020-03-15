//
//  progressionViewController.swift
//  PianoPalPlus
//
//  Created by joshua on 2/15/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import UIKit
import Combine

enum TheoryModeItem: Stringable, Equatable {
    case progression, editor(ProgressionItem?)
    
    func asString() -> String {
        switch self {
        case .progression:
            return "progression"
        case .editor(let item):
            guard let guid = item?.guid else {
                return "editor"
            }
            return "editor \(String(describing: guid))"
        }
    }
    
    static func == (lhs: TheoryModeItem, rhs: TheoryModeItem) -> Bool {
        return lhs.asString() == rhs.asString()
    }
}

class TheoryViewController: UIViewController {
    private let contentModeService: ContentModeService
    private let audioEngine: AudioEngine
    private let progressionViewModel: ProgressionViewModel
    private let theoryItemViewModel: TheoryItemViewModel
    private var progressionView: ProgressionView!
    private var theoryItemView: TheoryItemView!
    private var progression: Progression
    
    init(contentModeService: ContentModeService = .shared, audioEngine: AudioEngine = .shared) {
        self.contentModeService = contentModeService
        self.audioEngine = audioEngine
        self.progression = Progression()
        self.progressionViewModel = ProgressionViewModel(progression: progression)
        self.theoryItemViewModel = TheoryItemViewModel(progression: progression)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.progressionView = ProgressionView(viewModel: progressionViewModel)
        self.theoryItemView = TheoryItemView(viewModel: theoryItemViewModel)
        view.addFullBoundsSubview(progressionView)
        view.addFullBoundsSubview(theoryItemView)
        setupSubscriptions()
    }
    
    private var cancellables = Set<AnyCancellable>()
    private func setupSubscriptions() {
        contentModeService.$contentMode
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] contentMode in
                guard let selfV = self else { return }
                switch contentMode {
                case .theory(.editor(let item)):
                    selfV.theoryItemViewModel.edit(item: item)
                    selfV.view.bringSubviewToFront(selfV.theoryItemView)
                case .theory(.progression):
                     selfV.view.bringSubviewToFront(selfV.progressionView)
                default:
                    break
                }
            }).store(in: &cancellables)
    }
    
    func togglePlayActive() {
        audioEngine.isPlaying ? audioEngine.stop(progression.playable) : audioEngine.play(progression.playable)
    }
}
