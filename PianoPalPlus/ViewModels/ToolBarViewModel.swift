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
    @Published var playButtonImage: UIImage?
    @Published var playButtonHidden: Bool = false
    @Published var sequenceButtonColor: UIColor = .white
    @Published var sequenceButtonHidden: Bool = false
    @Published var scrollLockButtonColor: UIColor = .white
    @Published var scrollLockButtonHidden: Bool = false
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
            }).store(in: &cancellables)
        toolbar.$scrollLocked
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] scrollLocked in
                guard let selfV = self else { return }
                selfV.scrollLockButtonColor = scrollLocked ? .white : .gray
            }).store(in: &cancellables)
        toolbar.$sequenceActive
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] sequenceActive in
                guard let selfV = self else { return }
                selfV.sequenceButtonColor = sequenceActive ? .lightGray : .white
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
                    selfV.sequenceButtonHidden = false
                case .earTraining(_):
                    selfV.scrollLockButtonHidden = true
                    selfV.noteLockButtonHidden = true
                    selfV.sequenceButtonHidden = true
                case .theory:
                    selfV.noteLockButtonHidden = false
                    selfV.sequenceButtonHidden = false
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
    
    func toggleContentMode() {
        //toolbar.contentMode
    }
}
