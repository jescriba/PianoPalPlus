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
    private let piano: Piano
    private let audioEngine: AudioEngine
    
    init(piano: Piano = Piano(),
         audioEngine: AudioEngine = AudioEngine.shared) {
        self.piano = piano
        self.audioEngine = audioEngine
        
        setupNoteViewModels()
        setupSubscriptions()
        setupAudioBinding()
    }
    
    private func setupNoteViewModels() {
        // DRY
        for octave in Octave.min...(Octave.max + 1) {
            for note in Constants.orderedNotes.sorted(by: { a,b in
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
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] scrollLocked in
                self?.scrollLocked = scrollLocked
            }).store(in: &cancellables)
        piano.$noteLocked
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] noteLocked in
                guard let selfV = self else { return }
                selfV.noteLocked = noteLocked
                if !noteLocked {
                    selfV.piano.selectedNotes.removeAll()
                }
            }).store(in: &cancellables)
        piano.$selectedNotes
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] noteOctaves in
                guard let selfV = self else { return }
                if selfV.noteLocked {
                    selfV.noteViewModels.forEach({ $0.keyColorPair =  noteOctaves.contains($0.noteOctave) ? .selected : .basic })
                } else {
                    selfV.noteViewModels.forEach({ $0.keyColorPair =  noteOctaves.contains($0.noteOctave) ? .selected : .basic })
                    selfV.piano.playingNotes = noteOctaves
                    //selfV.pian
                    //selfV.modifiedNoteColors
                    //selfV.noteColors.insert(noteOctave, color)
                }
            }).store(in: &cancellables)
        piano.$playingNotes
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] noteOctaves in
                guard let selfV = self else { return }
                selfV.audioEngine.stop(Set(selfV.noteViewModels.map { $0.noteOctave }).subtracting(noteOctaves))
                selfV.audioEngine.play(noteOctaves, isSequencing: selfV.piano.sequencing)
            }).store(in: &cancellables)
        piano.$playing
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] playing in
                guard let selfV = self else { return }
                if playing {
                    selfV.audioEngine.play(selfV.piano.selectedNotes, isSequencing: selfV.piano.sequencing)
                } else {
                    selfV.audioEngine.stop(selfV.piano.selectedNotes)
                }
            }).store(in: &cancellables)
    }
    
    private func setupAudioBinding() {
        
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
