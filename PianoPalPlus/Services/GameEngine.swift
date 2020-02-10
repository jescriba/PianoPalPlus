//
//  GameEngine.swift
//  PianoPalPlus
//
//  Created by joshua on 2/4/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import Combine

struct Selection {
    var title: String?
}

class GameEngine {
    static let shared = GameEngine()
    @Published private (set) var selectionItems = [Selection]()
    private var isPlaying = false
    private let contentModeService: ContentModeService
    private let audioEngine: AudioEngine
    private var currentPlayable = [[NoteOctave]]()
    private var currentAnswer: Selection?
    
    init(contentModeService: ContentModeService = .shared, audioEngine: AudioEngine = AudioEngine.shared) {
        self.contentModeService = contentModeService
        self.audioEngine = audioEngine
        setupSubscriptions()
    }
    
    private var cancellables = Set<AnyCancellable>()
    private func setupSubscriptions() {
        contentModeService.$contentMode
            .sink(receiveValue: { [weak self] mode in
                // TODO
                self?.setupSelectionItems(mode: mode)
                self?.generatePlayable(mode: mode)
            }).store(in: &cancellables)
    }
    
    func play() {
        isPlaying = true
        currentPlayable.enumerated().forEach({ (arg) in
            let (index, noteOctaves) = arg
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(index), execute: { [weak self] in
                self?.audioEngine.play(noteOctaves)
            })
        })
    }
    
    func stop() {
        isPlaying = false
        audioEngine.stop(currentPlayable.flatMap({ $0 }))
    }
    
    func next() {
        generatePlayable(mode: contentModeService.contentMode)
    }
    
    func submit(index: Int, completion: ((Bool, Selection?) -> Void)) {
        guard index < selectionItems.count else { return }
        let selection = selectionItems[index]
        let result = isCorrectSubmission(selection)
        completion(result, currentAnswer)
    }
    
    func togglePlayState() {
        isPlaying ? stop() : play()
    }
    
    private func isCorrectSubmission(_ selection: Selection) -> Bool {
        guard let current = currentAnswer else { return false }
        return current.title == selection.title
    }
    
    private func generatePlayable(mode: ContentMode) {
        // TODO
        switch mode {
        case .earTraining(.interval):
            let randomInterval = Intervals.all.randomElement()!
            let noteOctaves = IntervalGenerator.notes(for: randomInterval)
            currentPlayable = [[NoteOctave]]()
            noteOctaves.forEach({ currentPlayable.append([$0]) })
            currentAnswer = Selection(title: randomInterval.title())
        case .earTraining(.key):
            let randomNote = NoteOctaveGenerator.random()
            currentPlayable = KeyGenerator.notesAndChords(for: randomNote)
            currentAnswer = Selection(title: randomNote.note.simpleDescription() + " maj")
            break
        case .earTraining(.chordType):
            let randomChordType = ChordTypes.all.randomElement()!
            let noteOctaves = ChordGenerator.notes(for: randomChordType)
            currentPlayable = [noteOctaves]
            currentAnswer = Selection(title: randomChordType.rawValue)
        default:
            break
        }
    }
    
    private func setupSelectionItems(mode: ContentMode) {
        switch mode {
        case .earTraining(.interval):
            selectionItems = Intervals.all.map { Selection(title: $0.title()) }
        case .earTraining(.key):
            selectionItems = Notes.all.map { Selection(title: $0.simpleDescription() + " maj") }
        case .earTraining(.chordType):
            selectionItems = ChordTypes.all.map { Selection(title: $0.rawValue) }
        default:
            break
        }
    }
}
