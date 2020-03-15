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

enum TheoryModeItem: String {
    case progression, editor
}

class TheoryViewController: UIViewController {
    private let contentModeService: ContentModeService
    private let progressionViewModel: ProgressionViewModel
    private let theoryItemViewModel: TheoryItemViewModel
    private var progressionView: ProgressionView!
    private var theoryItemView: TheoryItemView!
    
    init(contentModeService: ContentModeService = .shared) {
        self.contentModeService = contentModeService
        
        let progression = Progression()
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
        view.addFullBoundsSubview(progressionView)
        view.addFullBoundsSubview(theoryItemView)
        setupSubscriptions()
    }
    
    private var cancellables = Set<AnyCancellable>()
    private func setupSubscriptions() {
        contentModeService.$contentMode
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] contentMode in
                guard let selfV = self else { return }
                if contentMode == .theory(.editor) {
                    selfV.view.bringSubviewToFront(selfV.theoryItemView)
                } else if contentMode == .theory(.progression) {
                    selfV.view.bringSubviewToFront(selfV.progressionView)
                }
            }).store(in: &cancellables)
    }
}
