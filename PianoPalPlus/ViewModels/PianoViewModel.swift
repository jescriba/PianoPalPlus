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
    @Published var scrollLocked: Bool = false
    @Published var noteLocked: Bool = false
    @Published var playActive: Bool = false
    @Published var sequenceActive: Bool = false
    private (set) var noteViewModels = [NoteViewModel]()
    let piano: Piano
    private let audioEngine: AudioEngine
    private let contentModeService: ContentModeService
    
    init(piano: Piano = Piano(),
         audioEngine: AudioEngine = .shared,
         contentModeService: ContentModeService = .shared) {
        self.piano = piano
        self.audioEngine = audioEngine
        self.contentModeService = contentModeService
        
        setupNoteViewModels()
        setupSubscriptions()
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
                    selfV.piano.selectedNotes.removeAll()
                }
            }).store(in: &cancellables)
        piano.selectedNotes.$changedElements
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] changedElementsO in
                guard let selfV = self, let changedElements = changedElementsO else { return }
                if changedElements.change == .added {
                    selfV.noteViewModels.filter({ changedElements.values.contains($0.noteOctave) })
                        .forEach({ $0.keyColorPair = .selected })
                    if !selfV.noteLocked && selfV.contentModeService.contentMode == .freePlay {
                        selfV.audioEngine.play(changedElements.values)
                    }
                } else if changedElements.change == .removed {
                    selfV.noteViewModels.filter({ changedElements.values.contains($0.noteOctave) })
                        .forEach({ $0.keyColorPair = .basic })
                    if !selfV.noteLocked {
                        selfV.audioEngine.stop(changedElements.values)
                    }
                }
            }).store(in: &cancellables)
        piano.$playing
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] playing in
                guard let selfV = self, selfV.piano.noteLocked else { return }
                if playing {
                    let playableSequence = selfV.piano.sequencing ? selfV.piano.selectedNotes.array.map({ [$0] }) : [selfV.piano.selectedNotes.array]
                    selfV.audioEngine.play(playableSequence)
                } else {
                    selfV.audioEngine.stop(selfV.piano.selectedNotes.array)
                }
            }).store(in: &cancellables)
        piano.$playingNotes
            .combineLatest(piano.selectedNotes.$changedElements,
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
                    } else if selfV.piano.selectedNotes.contains(noteViewModel.noteOctave) {
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
            }).store(in: &cancellables)
    }
    
    func hasTouch(_ hasTouch: Bool, noteOctave: NoteOctave) {
        if hasTouch {
            if noteLocked && piano.selectedNotes.contains(noteOctave) {
                piano.selectedNotes.remove(noteOctave)
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
}
