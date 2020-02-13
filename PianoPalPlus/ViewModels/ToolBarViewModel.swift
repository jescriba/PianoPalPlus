//
//  ToolBarViewModel.swift
//  PianoPalPlus
//
//  Created by joshua on 1/30/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import UIKit
import Combine

class ToolBarViewModel {
    @Published var title: String = ""
    @Published var noteLockButtonImage: UIImage?
    @Published var noteLockButtonHidden: Bool = false
    @Published var pianoToggleButtonImage: UIImage?
    @Published var pianoToggleButtonHidden: Bool = false
    @Published var playButtonImage: UIImage?
    @Published var playButtonHidden: Bool = false
    @Published var sequenceButtonColor: UIColor = UIColor.imageTint
    @Published var sequenceButtonHidden: Bool = false
    @Published var scrollLockButtonColor: UIColor = UIColor.imageTint
    @Published var scrollLockButtonHidden: Bool = false
    private let pianoImage = UIImage(named: "piano")?.withRenderingMode(.alwaysTemplate)
    private let gridImage = UIImage(systemName: "square.grid.2x2.fill")?.withRenderingMode(.alwaysTemplate)
    private let noteLockedImage = UIImage(systemName: "lock")?.withRenderingMode(.alwaysTemplate)
    private let noteUnlockedImage = UIImage(systemName: "lock.open")?.withRenderingMode(.alwaysTemplate)
    private let playImage = UIImage(systemName: "play")?.withRenderingMode(.alwaysTemplate)
    private let stopImage = UIImage(systemName: "stop")?.withRenderingMode(.alwaysTemplate)
    private let toolbar: ToolBar
    private let contentModeService: ContentModeService
    private let contentModes: [ContentMode]  = [.freePlay, .earTraining(.interval)]
    
    init(toolBar: ToolBar = ToolBar(), contentModeService: ContentModeService = ContentModeService.shared) {
        self.toolbar = toolBar
        self.contentModeService = contentModeService
        
        setupSubscriptions()
    }
    
    private var cancellables = Set<AnyCancellable>()
    private func setupSubscriptions() {
        toolbar.$noteLocked
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] noteLocked in
                guard let selfV = self else { return }
                selfV.noteLockButtonImage = noteLocked ? selfV.noteUnlockedImage : selfV.noteLockedImage
                selfV.sequenceButtonHidden = !noteLocked
            }).store(in: &cancellables)
        toolbar.$pianoToggled
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] pianoToggled in
                guard let selfV = self else { return }
                selfV.pianoToggleButtonImage = pianoToggled ? selfV.gridImage : selfV.pianoImage
            }).store(in: &cancellables)
        toolbar.$scrollLocked
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] scrollLocked in
                guard let selfV = self else { return }
                selfV.scrollLockButtonColor = scrollLocked ? UIColor.imageTint : UIColor.imageSelectedTint
            }).store(in: &cancellables)
        toolbar.$sequenceActive
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] sequenceActive in
                guard let selfV = self else { return }
                selfV.sequenceButtonColor = sequenceActive ? UIColor.imageSelectedTint : UIColor.imageTint
            }).store(in: &cancellables)
        toolbar.$playActive
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] playActive in
                guard let selfV = self else { return }
                selfV.playButtonImage = playActive ? selfV.stopImage : selfV.playImage
            }).store(in: &cancellables)
        contentModeService.$contentMode
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] contentMode in
                guard let selfV = self else { return }
                selfV.title = contentMode.title()
                switch contentMode {
                case .freePlay:
                    selfV.noteLockButtonHidden = false
                    selfV.sequenceButtonHidden = true
                    selfV.scrollLockButtonHidden = false
                    selfV.pianoToggleButtonHidden = true
                    selfV.toolbar.pianoToggled = true
                case .earTraining(_):
                    selfV.scrollLockButtonHidden = true
                    selfV.noteLockButtonHidden = true
                    selfV.sequenceButtonHidden = true
                    selfV.pianoToggleButtonHidden = false
                    selfV.toolbar.pianoToggled = false
                case .theory:
                    selfV.noteLockButtonHidden = false
                    selfV.sequenceButtonHidden = false
                    selfV.pianoToggleButtonHidden = true
                }
            }).store(in: &cancellables)
    }
    
    func toggleNoteLock() {
        toolbar.noteLocked = !toolbar.noteLocked
    }
    
    func toggleScrollLock() {
        toolbar.scrollLocked = !toolbar.scrollLocked
    }
    
    func togglePlayButton() {
        toolbar.playActive = !toolbar.playActive
    }
    
    func toggleSequenceButton() {
        toolbar.sequenceActive = !toolbar.sequenceActive
    }
    
    func togglePiano() {
        toolbar.pianoToggled = !toolbar.pianoToggled
        switch contentModeService.contentMode {
        case .earTraining(_):
            scrollLockButtonHidden = !toolbar.pianoToggled
        default:
            break
        }
    }
}
