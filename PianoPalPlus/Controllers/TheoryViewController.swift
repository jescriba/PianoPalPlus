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
    case progression(Session?), editor(ProgressionItem?), library(Session?), sessionDetail
    
    func asString() -> String {
        switch self {
        case .progression:
            return "progression"
        case .editor(let item):
            guard let guid = item?.guid else {
                return "editor"
            }
            return "editor \(String(describing: guid))"
        case .library:
            return "library"
        case .sessionDetail:
            return "session"
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
    private let sessionsViewModel: SessionsViewModel
    private var sessionDetailViewModel: SessionDetailViewModel
    private var progressionView: ProgressionView!
    private var theoryItemView: TheoryItemView!
    private var sessionsView: SessionsView!
    private var sessionDetailView: SessionDetailView!
    private var currentSession: Session
    var progression: Progression {
        return currentSession.progression
    }
    private let pianoViewModel: PianoViewModel
    private let toolbarViewModel: ToolBarViewModel
    
    init(contentModeService: ContentModeService = .shared,
         audioEngine: AudioEngine = .shared,
         toolbarViewModel: ToolBarViewModel,
         pianoViewModel: PianoViewModel) {
        self.contentModeService = contentModeService
        self.audioEngine = audioEngine
        self.toolbarViewModel = toolbarViewModel
        self.pianoViewModel = pianoViewModel
        self.pianoViewModel.lockScroll(false)
        let sessionsStore = Store<Sessions>()
        let sessionStore = Store<Session>()
        self.sessionsViewModel = SessionsViewModel(sessionsStore: sessionsStore, sessionStore: sessionStore)
        self.currentSession = sessionsViewModel.currentSession
        self.sessionDetailViewModel = SessionDetailViewModel(sessionsStore: sessionsStore,
                                                             sessionStore: sessionStore)
        self.progressionViewModel = ProgressionViewModel(session: currentSession, store: sessionStore)
        self.theoryItemViewModel = TheoryItemViewModel(session: currentSession)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.progressionView = ProgressionView(viewModel: progressionViewModel)
        self.theoryItemView = TheoryItemView(viewModel: theoryItemViewModel)
        self.sessionsView = SessionsView(viewModel: sessionsViewModel)
        self.sessionDetailView = SessionDetailView(viewModel: sessionDetailViewModel)
        view.addFullBoundsSubview(theoryItemView)
        view.addFullBoundsSubview(sessionsView)
        view.addFullBoundsSubview(sessionDetailView)
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
        sessionsViewModel.$currentSession
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] session in
                self?.currentSession = session
                self?.theoryItemViewModel.session = session
                self?.progressionViewModel.session = session
                self?.progressionViewModel.updateSubscriptions()
                self?.updateSessionSubscriptions()
            }).store(in: &cancellables)
        contentModeService.$contentVC
            .combineLatest(contentModeService.$contentMode)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (contentVC, contentMode) in
                guard let selfV = self else { return }
                if contentVC == .progression {
                    switch contentMode {
                    case .theory(.library(_)):
                        selfV.toolbarViewModel.remove(buttonId: .sessionsToggle)
                        selfV.toolbarViewModel.remove(buttonId: .shareProgression)
                        selfV.toolbarViewModel.remove(buttonId: .progressionPlay)
                    default:
                        selfV.toolbarViewModel.addButton(selfV.sessionsButton)
                        selfV.toolbarViewModel.addButton(selfV.shareSessionButton)
                        selfV.toolbarViewModel.addButton(selfV.playButton)
                    }
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
                case .theory(.library(let newSessionO)):
                    if let newSession = newSessionO {
                        selfV.sessionsViewModel.add(newSession)
                    }
                    selfV.view.bringSubviewToFront(selfV.sessionsView)
                case .theory(.editor(let item)):
                    selfV.theoryItemViewModel.edit(item: item)
                    selfV.view.bringSubviewToFront(selfV.theoryItemView)
                case .theory(.progression):
                    selfV.progressionView.resetSelections()
                    if selfV.currentSession.progression.items.count > 0 {
                        let items = selfV.currentSession.progression.items
                        selfV.toolbarViewModel.setTitles(items.map({ $0.title }))
                    }
                    selfV.view.bringSubviewToFront(selfV.progressionView)
                case .theory(.sessionDetail):
                    selfV.view.bringSubviewToFront(selfV.sessionDetailView)
                default:
                    break
                }
            }).store(in: &cancellables)
        audioEngine.$isPlaying
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isPlaying in
                guard let selfV = self else { return }
                let updatedButton = selfV.playButton
                updatedButton.active = isPlaying
                selfV.toolbarViewModel.replaceButton(updatedButton)
            }).store(in: &cancellables)
        setupSessionSubscriptions()
    }
    
    private var sessionCancellables = Set<AnyCancellable>()
    private func setupSessionSubscriptions() {
        // theoryVC does the binding to piano. Is passing a piano to progressionViewModel better?
        progression.$currentItem
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] progressionItemO in
                guard let progressionItem = progressionItemO else { return }
                if let index = self?.progression.items.firstIndex(where: { $0 == progressionItem }) {
                    self?.toolbarViewModel.selectTitle(at: index)
                }
                self?.pianoViewModel.exclusiveHighlight(notes: progressionItem.items)
                self?.pianoViewModel.conditionalScrollTo(notes: progressionItem.items)
            }).store(in: &sessionCancellables)
        progression.$items
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] items in
                if items.count > 0 {
                    self?.toolbarViewModel.setTitles(items.map({ $0.title }))
                } else {
                    self?.toolbarViewModel.setTitles(["Progression"])
                }
            }).store(in: &sessionCancellables)
        toolbarViewModel.$selectedTitleIndex
            .combineLatest(progression.$currentItem, audioEngine.$isPlaying)
            .receive(on: DispatchQueue.main)
            .debounce(for: 0.1, scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (index, currentItem, isPlaying) in
                guard !isPlaying else { return } // tool bar can change current item only if not playing
                
                guard let progression = self?.progression else { return }
                
                guard currentItem != nil else {
                    if progression.items.count > index {
                        self?.progression.currentItem = progression.items[index]
                    }
                    return
                }
                
                // check current index not the new index otherwise noop
                guard let currentIndex = progression.items.firstIndex(where: { $0 == currentItem }),
                    currentIndex != index else {
                        return
                }
                
                self?.progression.currentItem = progression.items[index]
            }).store(in: &sessionCancellables)
    }
    
    private func updateSessionSubscriptions() {
        sessionCancellables.forEach({ $0.cancel() })
        sessionCancellables.removeAll()
        setupSessionSubscriptions()
    }
    
    func togglePlayActive() {
        audioEngine.isPlaying ? audioEngine.stop(progression.sequences) : audioEngine.play(progression.sequences)
    }
    
    func shareSession() {
        let session = sessionsViewModel.currentSession
        guard let url = DeepLinkService.url(for: session) else { return }
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(vc, animated: true, completion: nil)
    }
    
    func openSessionsLibrary() {
        contentModeService.contentMode = .theory(.library(nil))
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
                        self?.openSessionsLibrary()
        })
    }
    
    var shareSessionButton: ToolBarButton {
        ToolBarButton(id: .shareProgression,
                      priority: 0,
                      position: .left,
                      image: UIImage(systemName: "square.and.arrow.up"),
                      action: { [weak self] in
                        self?.shareSession()
        })
    }
    
}
