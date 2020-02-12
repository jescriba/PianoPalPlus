//
//  ToolBarView.swift
//  PianoPalPlus
//
//  Created by joshua on 1/20/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import UIKit
import Combine

class ToolBarView: UIView {
    // dry toolbar items
    @Published var settingsButtonPublisher = false // would prefer a void approach..
    @Published var playButtonPublisher = false
    @Published var sequenceButtonPublisher = false
    @Published var scrollLockButtonPublisher = false
    @Published var noteLockButtonPublisher = false
    @Published var pianoToggleButtonPublisher = false
    weak var viewModel: ToolBarViewModel? {
        didSet {
            bindViewModel()
        }
    }
    var cancellables = Set<AnyCancellable>()
    let titleLabel = UILabel()
    let noteLockButton = UIButton()
    let sequenceButton = UIButton()
    private let leftHStack = UIStackView()
    private let rightHStack = UIStackView()
    private let scrollLockButton = UIButton()
    private let playButton = UIButton()
    private let settingsButton = UIButton()
    private let pianoToggleButton = UIButton()
    private let scrollImage = UIImage(systemName: "arrow.right.arrow.left")?.withRenderingMode(.alwaysTemplate)
    private let settingsImage = UIImage(systemName: "gear")?.withRenderingMode(.alwaysTemplate)
    private let sequenceImage = UIImage(systemName: "square.stack.3d.down.dottedline")?.withRenderingMode(.alwaysTemplate)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bindViewModel() {
        // dry
        viewModel?.$title
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] title in
                self?.titleLabel.text = title
            }).store(in: &cancellables)
        viewModel?.$pianoToggleButtonImage
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] image in
                self?.pianoToggleButton.setImage(image, for: .normal)
            }).store(in: &cancellables)
        viewModel?.$pianoToggleButtonHidden
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] hidden in
                self?.pianoToggleButton.isHidden = hidden
            }).store(in: &cancellables)
        viewModel?.$noteLockButtonImage
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] image in
                self?.noteLockButton.setImage(image, for: .normal)
            }).store(in: &cancellables)
        viewModel?.$playButtonImage
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] image in
                self?.playButton.setImage(image, for: .normal)
            }).store(in: &cancellables)
        viewModel?.$sequenceButtonColor
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] color in
                self?.sequenceButton.imageView?.tintColor = color
            }).store(in: &cancellables)
        viewModel?.$scrollLockButtonColor
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] color in
                self?.scrollLockButton.imageView?.tintColor = color
            }).store(in: &cancellables)
        viewModel?.$noteLockButtonHidden
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] hidden in
                self?.noteLockButton.isHidden = hidden
            }).store(in: &cancellables)
        viewModel?.$sequenceButtonHidden
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] hidden in
                self?.sequenceButton.isHidden = hidden
            }).store(in: &cancellables)
        viewModel?.$scrollLockButtonHidden
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] hidden in
                self?.scrollLockButton.isHidden = hidden
            }).store(in: &cancellables)
    }

    private func setup() {
        self.backgroundColor = UIColor.toolbar
        
        // setup title
        titleLabel.textColor = UIColor.text
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Setup left horizontal stack
        leftHStack.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(leftHStack)
        NSLayoutConstraint.activate([
            leftHStack.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            leftHStack.rightAnchor.constraint(equalTo: self.titleLabel.leftAnchor, constant: -10),
            leftHStack.heightAnchor.constraint(equalToConstant: 50),
            leftHStack.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])

        // setup scroll lock button
        scrollLockButton.setImage(scrollImage, for: .normal)
        scrollLockButton.addTarget(self, action: #selector(scrollLockTapped), for: .touchUpInside)
        noteLockButton.addTarget(self, action: #selector(noteLockTapped), for: .touchUpInside)
        noteLockButton.imageView?.tintColor = UIColor.imageTint
        sequenceButton.setImage(sequenceImage, for: .normal)
        sequenceButton.addTarget(self, action: #selector(sequenceTapped), for: .touchUpInside)
        sequenceButton.imageView?.tintColor = UIColor.imageTint
        pianoToggleButton.imageView?.tintColor = UIColor.imageTint
        pianoToggleButton.addTarget(self, action: #selector(pianoToggleTapped), for: .touchUpInside)
        [scrollLockButton, noteLockButton, sequenceButton, pianoToggleButton].forEach { btn in
            btn.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                btn.widthAnchor.constraint(equalToConstant: 50),
                btn.heightAnchor.constraint(equalToConstant: 50)
            ])
            leftHStack.addArrangedSubview(btn)
        }

        // Setup right horiztonal stack
        rightHStack.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(rightHStack)
        NSLayoutConstraint.activate([
            rightHStack.leftAnchor.constraint(equalTo: self.titleLabel.rightAnchor),
            rightHStack.widthAnchor.constraint(equalToConstant: 200),
            rightHStack.heightAnchor.constraint(equalToConstant: 50),
            rightHStack.rightAnchor.constraint(equalTo: self.rightAnchor)
        ])
        //playButton.setImage(playImage, for: .normal)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        playButton.imageView?.tintColor = UIColor.imageTint
        settingsButton.setImage(settingsImage, for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        settingsButton.imageView?.tintColor = UIColor.imageTint
        [settingsButton, playButton].forEach { btn in
            btn.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                btn.widthAnchor.constraint(equalToConstant: 50),
                btn.heightAnchor.constraint(equalToConstant: 50)
            ])
            rightHStack.addArrangedSubview(btn)
        }
    }

    // MARK: EVENTS
    @objc func scrollLockTapped() {
        scrollLockButtonPublisher = true
    }

    @objc func noteLockTapped() {
        noteLockButtonPublisher = true
    }

    @objc func playTapped() {
        playButtonPublisher = true
    }

    @objc func sequenceTapped() {
        sequenceButtonPublisher = true
    }
    
    @objc func pianoToggleTapped() {
        pianoToggleButtonPublisher = true
    }

    @objc func settingsTapped() {
        settingsButtonPublisher = true
    }
}
