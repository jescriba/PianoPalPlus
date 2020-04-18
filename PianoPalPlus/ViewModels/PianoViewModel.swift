//
//  PianoViewModel.swift
//  PianoPalPlus
//
//  Created by joshua on 1/30/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import Combine
import UIKit

class PianoViewModel {
    @Published var delaysContentTouches: Bool = false
    @Published var scrollLocked: Bool = false
    @Published var noteLocked: Bool = false
    @Published var playActive: Bool = false
    @Published var sequenceActive: Bool = false
    @Published var scrollNote: NoteOctave?
    private (set) var noteViewModels = [NoteViewModel]()
    let piano: Piano
    private let toolbarViewModel: ToolBarViewModel
    private let audioEngine: AudioEngine
    private let contentModeService: ContentModeService
    
    init(piano: Piano = Piano(),
         toolbarViewModel: ToolBarViewModel,
         audioEngine: AudioEngine = .shared,
         contentModeService: ContentModeService = .shared) {
        self.piano = piano
        self.toolbarViewModel = toolbarViewModel
        self.audioEngine = audioEngine
        self.contentModeService = contentModeService
        
        setupNoteViewModels()
        setupSubscriptions()
        setupToolBarButtons()
    }
    
    deinit {
        removePianoToolbarButtons()
    }
    
    private func setupNoteViewModels() {
        // DRY
        for octave in Octave.min...(Octave.max + 1) {
            for note in Notes.all.sorted(by: { a,b in
                if a.isWhiteKey() && b.isBlackKey() {
                    return true
                }
                return false
            }) {
                noteViewModels.append(NoteViewModel(noteOctave: NoteOctave(note: note, octave: octave)))
            }
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    private func setupSubscriptions() {
        piano.$scrollLocked
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] scrollLocked in
                self?.scrollLocked = scrollLocked
            }).store(in: &cancellables)
        piano.$noteLocked
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] noteLocked in
                guard let selfV = self else { return }
                selfV.noteLocked = noteLocked
                if !noteLocked {
                    selfV.toolbarViewModel.removeButton(selfV.sequencerButton)
                    selfV.piano.selectedNotes.removeAll()
                    selfV.piano.highlightedNotes.removeAll()
                } else {
                    selfV.toolbarViewModel.addButton(selfV.sequencerButton)
                }
            }).store(in: &cancellables)
        piano.$scrollLocked
            .combineLatest(piano.$noteLocked)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (scrollLock, noteLock) in
                // prevent note locking unintentionally while scrolling
                self?.delaysContentTouches = noteLock && !scrollLock
            }).store(in: &cancellables)
        piano.selectedNotes.$changedElements
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] changedElementsO in
                guard let selfV = self, let changedElements = changedElementsO else { return }
                if changedElements.change == .added {
                    changedElements.values.forEach({ selfV.piano.highlightedNotes.insert($0) })
                    if !selfV.noteLocked {
                        selfV.audioEngine.play(changedElements.values)
                    }
                } else if changedElements.change == .removed {
                    changedElements.values.forEach({ selfV.piano.highlightedNotes.remove($0) })
                    if !selfV.noteLocked {
                        selfV.audioEngine.stop(changedElements.values)
                    }
                }
            }).store(in: &cancellables)
        piano.highlightedNotes.$changedElements
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] changedElementsO in
                guard let selfV = self, let changedElements = changedElementsO else { return }
                if changedElements.change == .added {
                    selfV.noteViewModels.filter({ changedElements.values.contains($0.noteOctave) })
                        .forEach({ $0.keyColorPair = .selected })
                } else if changedElements.change == .removed {
                    selfV.noteViewModels.filter({ changedElements.values.contains($0.noteOctave) })
                        .forEach({ $0.keyColorPair = .basic })
                }
            }).store(in: &cancellables)
        piano.$playing
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] playing in
                guard let selfV = self, selfV.piano.noteLocked else { return }
                if playing {
                    let playableSequence = selfV.piano.sequencing ? selfV.piano.highlightedNotes.array.map({ [$0] }) : [selfV.piano.highlightedNotes.array]
                    selfV.audioEngine.play(playableSequence)
                } else {
                    selfV.audioEngine.stop(selfV.piano.highlightedNotes.array)
                }
            }).store(in: &cancellables)
        piano.$playingNotes
            .combineLatest(piano.highlightedNotes.$changedElements,
                           contentModeService.$contentMode)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] arg in
                let (notes, changedElements, contentMode) = arg
                // ear training doesnt show playing notes
                switch contentMode {
                case .earTraining(_):
                    return
                default:
                    break
                }
                guard let selfV = self else { return }
                selfV.noteViewModels.forEach({ noteViewModel in
                    if notes?.contains(noteViewModel.noteOctave) ?? false {
                        noteViewModel.keyColorPair = .playing
                    } else if selfV.piano.highlightedNotes.contains(noteViewModel.noteOctave) {
                        // todo having to combine these to get latest selected notes state :/ refactor
                        if let changed = changedElements,
                            changed.change == .removed && changed.values.contains(noteViewModel.noteOctave) {
                            noteViewModel.keyColorPair = .basic
                        } else {
                            noteViewModel.keyColorPair = .selected
                        }
                    } else {
                        noteViewModel.keyColorPair = .basic
                    }
                })
            }).store(in: &cancellables)
        audioEngine.$playData
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] playableData in
                self?.piano.playingNotes = playableData?.playable
            }).store(in: &cancellables)
        contentModeService.$contentMode
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                // reset selected note state if mode changes
                self?.piano.selectedNotes.removeAll()
                self?.piano.highlightedNotes.removeAll()
                self?.piano.noteLocked = false
            }).store(in: &cancellables)
        contentModeService.$contentMode
            .combineLatest(piano.$noteLocked)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (contentMode, noteLocked) in
                guard let selfV = self else { return }
                if contentMode == .freePlay {
                    if noteLocked {
                        selfV.toolbarViewModel.addButton(selfV.playButton)
                    } else {
                        selfV.toolbarViewModel.removeButton(selfV.playButton)
                    }
                }
            }).store(in: &cancellables)
    }
    
    func hasTouch(_ hasTouch: Bool, noteOctave: NoteOctave) {
        if hasTouch {
            if noteLocked && piano.highlightedNotes.contains(noteOctave) {
                piano.highlightedNotes.remove(noteOctave)
            } else if noteLocked {
                piano.highlightedNotes.insert(noteOctave)
            } else {
                piano.selectedNotes.insert(noteOctave)
            }
        } else if !noteLocked {
            piano.selectedNotes.remove(noteOctave)
        }
    }
    
    func toggleScrollLock() {
        piano.scrollLocked = !piano.scrollLocked
    }
    
    func toggleNoteLock() {
        piano.noteLocked = !piano.noteLocked
    }
    
    func toggleSequenceActive() {
        piano.sequencing = !piano.sequencing
    }
    
    func togglePlayActive() {
        piano.playing = !piano.playing
    }
    
    func exclusiveHighlight(notes: [NoteOctave]) {
        piano.highlightedNotes.array
            .filter({ !notes.contains($0) })
            .forEach({ piano.highlightedNotes.remove($0) })
        notes.forEach({ piano.highlightedNotes.insert($0) })
    }
    
    func conditionalScrollTo(notes: [NoteOctave]) {
        guard !piano.scrollLocked else { return }
        scrollNote = notes.sorted(by: { $0.midiNote < $1.midiNote }).first
    }
    
    private func setupToolBarButtons() {
        contentModeService.$contentMode
            .combineLatest(contentModeService.$contentVC)
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (contentMode, contentVC) in
                guard let selfV = self else { return }
                switch (contentMode, contentVC) {
                case (.freePlay, .piano):
                    selfV.toolbarViewModel.addButton(selfV.scrollLockButton, replace: true)
                    selfV.toolbarViewModel.addButton(selfV.noteLockButton, replace: true)
                case (.earTraining, .piano), (.theory, .piano):
                    selfV.toolbarViewModel.addButton(selfV.scrollLockButton, replace: true)
                default:
                    selfV.removePianoToolbarButtons()
                }
            }).store(in: &cancellables)
    }
    
    private func removePianoToolbarButtons() {
        toolbarViewModel.removeButton(scrollLockButton)
        toolbarViewModel.removeButton(noteLockButton)
        toolbarViewModel.removeButton(sequencerButton)
        toolbarViewModel.removeButton(playButton)
    }
    
    // MARK: ToolBar Buttons
    private var scrollLockButton: ToolBarButton {
        ToolBarButton(id: .scrollLock,
                      priority: 0,
                      active: false,
                      position: .left,
                      image: UIImage(systemName: "arrow.right.arrow.left"),
                      action: { [weak self] in
                        self?.toggleScrollLock()
        })
    }
    private var noteLockButton: ToolBarButton {
        ToolBarButton(id: .noteLock,
                      priority: 1,
                      active: false,
                      position: .left,
                      image: UIImage(systemName: "lock"),
                      activeImage: UIImage(systemName: "lock.open"),
                      action: { [weak self] in
                        self?.toggleNoteLock()
        })
    }
    private var sequencerButton: ToolBarButton {
        ToolBarButton(id: .sequenceLock,
                      priority: 2,
                      active: false,
                      position: .left,
                      image: UIImage(systemName: "square.stack.3d.down.dottedline"),
                      action: { [weak self] in
                        self?.toggleSequenceActive()
        })
    }
    private var playButton: ToolBarButton {
        ToolBarButton(id: .noteLockPlay,
                      priority: 1,
                      active: false,
                      position: .right,
                      image: UIImage(systemName: "play"),
                      activeImage: UIImage(systemName: "stop"),
                      action: { [weak self] in
                        self?.togglePlayActive()
        })
    }
}
