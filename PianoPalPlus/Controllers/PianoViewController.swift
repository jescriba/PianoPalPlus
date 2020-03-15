//
//  PianoViewController.swift
//  PianoPalPlus
//
//  Created by joshua on 1/30/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import UIKit
import Combine

class PianoViewController: UIViewController {
    private var pianoView: PianoView!
    private let pianoViewModel: PianoViewModel
    
    init(pianoViewModel: PianoViewModel) {
        self.pianoViewModel = pianoViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViews()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // sigh... ipad likes to change it's orientation after loading...
        if previousTraitCollection?.verticalSizeClass == .regular && traitCollection.verticalSizeClass == .compact {
            view.subviews.forEach({ $0.removeFromSuperview() })
            setupViews()
        }
    }
    
    private func setupViews() {
        self.pianoView = PianoView(frame: view.bounds)
        self.pianoView.viewModel = pianoViewModel
        view.addSubview(pianoView)
    }
    
}
