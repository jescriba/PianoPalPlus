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
    case piano, game, progression
}

class ContainerViewController: UIViewController {
    // controllers
    private var pianoViewController: PianoViewController!
    private var gameViewController: GameViewController?
    private var progressionViewController: TheoryViewController?
    // view models
    private var toolBarViewModel: ToolBarViewModel!
    private var pianoViewModel: PianoViewModel!
    // views
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
        pianoViewModel = PianoViewModel(toolbarViewModel: toolBarViewModel)
        pianoViewController = PianoViewController(pianoViewModel: pianoViewModel)
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
    
    private func removeViewController(_ viewController: UIViewController?) {
        guard let vc = viewController else { return }
        removeViewController(vc)
    }
    
    private func bringViewControllerToFront(_ frontVC: ContentVC) {
        contentModeService.contentVC = frontVC
        switch frontVC {
        case .game:
            if gameViewController == nil {
                gameViewController = GameViewController(toolbarViewModel: toolBarViewModel)
                addViewController(gameViewController!)
            }
            if progressionViewController != nil {
                removeViewController(progressionViewController!)
                progressionViewController = nil
            }
            self.view.bringSubviewToFront(self.gameViewController!.view)
        case .progression:
            // TODO refactor
            if progressionViewController == nil {
                if gameViewController != nil {
                    removeViewController(gameViewController!)
                    gameViewController = nil
                }
                progressionViewController = TheoryViewController(toolbarViewModel: toolBarViewModel, pianoViewModel: pianoViewModel)
                addViewController(progressionViewController!)
            }
            self.view.bringSubviewToFront(self.progressionViewController!.view)
        case .piano:
            self.view.bringSubviewToFront(self.pianoViewController.view)
        }
    }
    
    private func setupToolBarView() {
        self.toolBarView = ToolBarView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: toolBarViewHeight))
        view.addSubview(toolBarView)
        let settingsButton = ToolBarButton(id: .settings,
                                           priority: 0,
                                           position: .right,
                                           image: UIImage(systemName: "gear"),
                                           action: { [weak self] in self?.settingsOpened() })
        toolBarViewModel.addButton(settingsButton)
        toolBarView.viewModel = toolBarViewModel
    }
    
    private func setupSubscriptions() {
        setupToolBarSubscriptions()
        contentModeService.$contentMode
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] contentMode in
                guard let selfV = self else { return }
                switch contentMode {
                case .freePlay:
                    selfV.bringViewControllerToFront(.piano)
                case .earTraining(_):
                    selfV.bringViewControllerToFront(.game)
                case .theory:
                    selfV.bringViewControllerToFront(.progression)
                }
            }).store(in: &cancellables)
    }
    
    // MARK: ToolBar Providing
    private func setupToolBarSubscriptions() {
        contentModeService.$contentMode
            .combineLatest(contentModeService.$contentVC)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] (contentMode, contentVC) in
                guard let selfV = self else { return }
                switch (contentMode, contentVC) {
                case (.freePlay, _):
                    selfV.toolBarViewModel.remove(buttonId: .pianoToggle)
                    selfV.removeViewController(selfV.progressionViewController)
                    selfV.removeViewController(selfV.gameViewController)
                    selfV.progressionViewController = nil
                    selfV.gameViewController = nil
                case (.earTraining,  _):
                    selfV.toolBarViewModel.addButton(ToolBarButton(id: .pianoToggle,
                                                 priority: 1,
                                                 active: contentVC == .piano,
                                                 position: .left,
                                                 image: UIImage(named: "piano"),
                                                 activeImage: UIImage(systemName: "square.grid.2x2.fill"), action: { [weak self] in
                                                    if contentVC == .piano {
                                                        self?.bringViewControllerToFront(.game)
                                                    } else {
                                                        self?.bringViewControllerToFront(.piano)
                                                    }
                    }), replace: true)
                case (.theory, _):
                    selfV.toolBarViewModel.addButton(ToolBarButton(id: .pianoToggle,
                                                 priority: 1,
                                                 active: contentVC == .piano,
                                                 position: .left,
                                                 image: UIImage(named: "piano"),
                                                 activeImage: UIImage(systemName: "square.grid.2x2.fill"), action: { [weak self] in
                                                    if contentVC == .piano {
                                                        self?.bringViewControllerToFront(.progression)
                                                    } else {
                                                        self?.bringViewControllerToFront(.piano)
                                                    }
                    }), replace: true)
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

