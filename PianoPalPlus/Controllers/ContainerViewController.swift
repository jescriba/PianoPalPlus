//
//  ViewController.swift
//  PianoPalPlus
//
//  Created by joshua on 1/1/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import UIKit
import Combine

enum ContentVC {
    case piano, game
}

class ContainerViewController: UIViewController {
    private var frontVC: ContentVC = .piano
    // controllers
    private var pianoViewController: PianoViewController!
    private var gameViewController: GameViewController!
    // view models
    private var toolBarViewModel: ToolBarViewModel!
    private var pianoViewModel: PianoViewModel!
    private var toolBarView: ToolBarView!
    // constants
    private let toolBarViewHeight: CGFloat = 50
    private let borderPadding: CGFloat = 1
    // combine
    private var cancellables = Set<AnyCancellable>()
    // services
    private let contentModeService: ContentModeService
    
    init(contentModeService: ContentModeService = ContentModeService.shared) {
        self.contentModeService = contentModeService
        toolBarViewModel = ToolBarViewModel(contentModeService: contentModeService)
        pianoViewModel = PianoViewModel()
        
        pianoViewController = PianoViewController(pianoViewModel: pianoViewModel)
        gameViewController = GameViewController()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // sigh... ipad likes to change it's orientation after loading...
        if previousTraitCollection?.verticalSizeClass == .regular && traitCollection.verticalSizeClass == .compact {
            view.subviews.forEach({ $0.removeFromSuperview() })
            children.forEach({ self.removeViewController($0) })
            setupViews()
        }
    }
    
    private func setupViews() {
        setupToolBarView()
        addViewController(pianoViewController)
        addViewController(gameViewController)
        setupSubscriptions()
    }
    
    private func addViewController(_ viewController: UIViewController) {
        addChild(viewController)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(viewController.view)
        NSLayoutConstraint.activate([
            viewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            viewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            viewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            viewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: toolBarViewHeight - borderPadding)
        ])
        self.view.sendSubviewToBack(viewController.view)
        viewController.didMove(toParent: self)
    }
    
    private func removeViewController(_ viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }
    
    private func setupToolBarView() {
        self.toolBarView = ToolBarView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: toolBarViewHeight))
        view.addSubview(toolBarView)
        toolBarView.viewModel = toolBarViewModel
    }
    
    private func setupSubscriptions() {
        toolBarView.$settingsButtonPublisher
            .filter({ $0 == true})
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.settingsOpened()
            }).store(in: &cancellables)
        toolBarView.$noteLockButtonPublisher
            .filter({ $0 == true })
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.toolBarViewModel.toggleNoteLock()
                self?.pianoViewModel.toggleNoteLock()
            }).store(in: &cancellables)
        toolBarView.$scrollLockButtonPublisher
            .filter({ $0 == true })
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.toolBarViewModel.toggleScrollLock()
                self?.pianoViewModel.toggleScrollLock()
            }).store(in: &cancellables)
        toolBarView.$sequenceButtonPublisher
            .filter({ $0 == true })
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.toolBarViewModel.toggleSequenceButton()
                self?.pianoViewModel.toggleSequenceActive()
            }).store(in: &cancellables)
        toolBarView.$playButtonPublisher
            .filter({ $0 == true })
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let selfV = self else { return }
                selfV.toolBarViewModel.togglePlayButton()
                switch selfV.contentModeService.contentMode {
                case .earTraining(_):
                    selfV.gameViewController.togglePlayActive()
                default:
                    selfV.pianoViewModel.togglePlayActive()
                }
            }).store(in: &cancellables)
        contentModeService.$contentMode
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] contentMode in
                guard let selfV = self else { return }
                if contentMode == ContentMode.freePlay {
                    selfV.frontVC = .piano
                    selfV.view.bringSubviewToFront(selfV.pianoViewController.view)
                } else {
                    selfV.frontVC = .game
                    selfV.view.bringSubviewToFront(selfV.gameViewController.view)
                }
            }).store(in: &cancellables)
        toolBarView.$pianoToggleButtonPublisher
            .filter({ $0 == true })
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                guard let selfV = self else { return }
                // TODONOw @joshua state with this and the above block fix
                selfV.toolBarViewModel.togglePiano()
                if selfV.frontVC == .piano {
                    selfV.frontVC = .game
                    selfV.view.bringSubviewToFront(selfV.gameViewController.view)
                    selfV.toolBarViewModel.scrollLockButtonHidden = true
                } else {
                    selfV.frontVC = .piano
                    selfV.view.bringSubviewToFront(selfV.pianoViewController.view)
                    selfV.toolBarViewModel.scrollLockButtonHidden = false
                }
            }).store(in: &cancellables)
    }
    
    // MARK: NAVIGATION
    func settingsOpened() {
        let navigationVC = NavigationViewController()
        navigationVC.providesPresentationContextTransitionStyle = true
        navigationVC.definesPresentationContext = true
        navigationVC.modalPresentationStyle = .overCurrentContext
        self.present(navigationVC, animated: false)
    }

}

