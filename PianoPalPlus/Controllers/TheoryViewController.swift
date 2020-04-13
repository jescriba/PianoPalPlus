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
    private let piano: Piano
    private let toolbarViewModel: ToolBarViewModel
    
    init(contentModeService: ContentModeService = .shared,
         audioEngine: AudioEngine = .shared,
         store: Store = .shared,
         toolbarViewModel: ToolBarViewModel,
         piano: Piano) {
        self.contentModeService = contentModeService
        self.audioEngine = audioEngine
        self.progression = store.load(from: .progression) ?? Progression()
        self.toolbarViewModel = toolbarViewModel
        self.piano = piano
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
        view.addFullBoundsSubview(theoryItemView)
        view.addFullBoundsSubview(progressionView)
        setupSubscriptions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toolbarViewModel.addButton(playButton, replace: true)
        toolbarViewModel.addButton(sessionsButton)
        toolbarViewModel.addButton(shareSessionButton)
    }
    
    deinit {
        toolbarViewModel.remove(buttonId: .progressionPlay)
        toolbarViewModel.remove(buttonId: .sessionsToggle)
        toolbarViewModel.remove(buttonId: .shareProgression)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioEngine.stop()
    }
    
    private var cancellables = Set<AnyCancellable>()
    private func setupSubscriptions() {
        contentModeService.$contentVC
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] contentVC in
                guard let selfV = self else { return }
                if contentVC == .progression {
                    selfV.toolbarViewModel.addButton(selfV.sessionsButton)
                    selfV.toolbarViewModel.addButton(selfV.shareSessionButton)
                } else {
                    selfV.toolbarViewModel.removeButton(selfV.sessionsButton)
                    selfV.toolbarViewModel.removeButton(selfV.shareSessionButton)
                }
            }).store(in: &cancellables)
        contentModeService.$contentMode
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] contentMode in
                guard let selfV = self else { return }
                switch contentMode {
                case .theory(.editor(let item)):
                    selfV.theoryItemViewModel.edit(item: item)
                    selfV.view.bringSubviewToFront(selfV.theoryItemView)
                case .theory(.progression):
                    selfV.progressionView.resetSelections()
                    selfV.view.bringSubviewToFront(selfV.progressionView)
                default:
                    break
                }
            }).store(in: &cancellables)
        toolbarViewModel.$selectedTitleIndex
            .combineLatest(progression.$currentItem, audioEngine.$isPlaying)
            .receive(on: DispatchQueue.main)
            .debounce(for: 0.1, scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (index, currentItem, isPlaying) in
                guard !isPlaying else { return } // tool bar can change current item only if not playing
                
                guard let progression = self?.progression else { return }
                
                guard currentItem != nil else {
                    self?.progression.currentItem = progression.items[index]
                    return
                }
                
                // check current index not the new index otherwise noop
                guard let currentIndex = progression.items.firstIndex(where: { $0 == currentItem }),
                    currentIndex != index else {
                        return
                }
                
                self?.progression.currentItem = progression.items[index]
            }).store(in: &cancellables)
        // theoryVC does the binding to piano. Is passing a piano to progressionViewModel better?
        progression.$currentItem
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] progressionItemO in
                guard let progressionItem = progressionItemO else { return }
                if let index = self?.progression.items.firstIndex(where: { $0 == progressionItem }) {
                    self?.toolbarViewModel.selectTitle(at: index)
                }
                self?.piano.highlightedNotes.array
                    .filter({ !progressionItem.items.contains($0) })
                    .forEach({ self?.piano.highlightedNotes.remove($0) })
                progressionItem.items.forEach({ self?.piano.highlightedNotes.insert($0) })
            }).store(in: &cancellables)
        progression.$items
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] items in
                if items.count > 0 {
                    self?.toolbarViewModel.setTitles(items.map({ $0.title }))
                } else {
                    self?.toolbarViewModel.setTitles(["Progression"])
                }
            }).store(in: &cancellables)
        audioEngine.$isPlaying
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isPlaying in
                guard let selfV = self else { return }
                let updatedButton = selfV.playButton
                updatedButton.active = isPlaying
                selfV.toolbarViewModel.addButton(updatedButton, replace: true)
            }).store(in: &cancellables)
    }
    
    func togglePlayActive() {
        audioEngine.isPlaying ? audioEngine.stop(progression.sequences) : audioEngine.play(progression.sequences)
    }
    
    var playButton: ToolBarButton {
        ToolBarButton(id: .progressionPlay,
                      priority: 2,
                      position: .right,
                      image: UIImage(systemName: "play"),
                      activeImage: UIImage(systemName: "stop"),
                      action: { [weak self] in
                        self?.togglePlayActive()
        })
    }
    
    var sessionsButton: ToolBarButton {
        ToolBarButton(id: .sessionsToggle,
                      priority: 1,
                      position: .right,
                      image: UIImage(systemName: "tray.full"),
                      action: { [weak self] in
        })
    }
    
    var shareSessionButton: ToolBarButton {
        ToolBarButton(id: .shareProgression,
                      priority: 0,
                      position: .left,
                      image: UIImage(systemName: "square.and.arrow.up"),
                      action: { [weak self] in
        })
    }
    
}
