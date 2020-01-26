//
//  ToolBarView.swift
//  PianoPalPlus
//
//  Created by joshua on 1/20/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import UIKit

protocol ToolBarDelegate: NSObject {
    func scrollLockDidChange()
    func noteLockDidChange()
    func playDidChange()
    func sequenceDidChange()
    func settingsDidChange()
}

class ToolBarView: UIView {
    weak var delegate: ToolBarDelegate?
    var isScrollLocked: Bool = false {
        didSet {
            scrollLockButton.imageView?.tintColor = isScrollLocked ? Colors.scrollLockSelected : Colors.scrollLockUnselected
        }
    }
    var isNoteLocked: Bool = false {
        didSet {
            let lockImage = isNoteLocked ? noteUnlockedImage : noteLockedImage
            noteLockButton.setImage(lockImage, for: .normal)
            sequenceButton.isHidden = !isNoteLocked
            playButton.isHidden = !isNoteLocked
        }
    }
    var isPlaying: Bool = false {
        didSet {
            let lockImage = isPlaying ? stopImage : playImage
            playButton.setImage(lockImage, for: .normal)
        }
    }
    var isSequencing: Bool = false {
        didSet {
            sequenceButton.imageView?.tintColor = isSequencing ? Colors.scrollLockSelected : Colors.scrollLockUnselected
        }
    }
    var title: String = "piano pal plus" {
        didSet {
            titleLabel.text = title
        }
    }
    private let titleLabel = UILabel()
    private let leftHStack = UIStackView()
    private let rightHStack = UIStackView()
    private let scrollLockButton = UIButton()
    private let noteLockButton = UIButton()
    private let playButton = UIButton()
    private let settingsButton = UIButton()
    private let sequenceButton = UIButton()
    private let playImage = UIImage(systemName: "play")?.withRenderingMode(.alwaysTemplate)
    private let stopImage = UIImage(systemName: "stop")?.withRenderingMode(.alwaysTemplate)
    private let scrollImage = UIImage(systemName: "arrow.right.arrow.left")?.withRenderingMode(.alwaysTemplate)
    private let noteLockedImage = UIImage(systemName: "lock")?.withRenderingMode(.alwaysTemplate)
    private let noteUnlockedImage = UIImage(systemName: "lock.open")?.withRenderingMode(.alwaysTemplate)
    private let settingsImage = UIImage(systemName: "gear")?.withRenderingMode(.alwaysTemplate)
    private let sequenceImage = UIImage(systemName: "square.stack.3d.down.dottedline")?.withRenderingMode(.alwaysTemplate)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.backgroundColor = .purple
        
        // Setup left horizontal stack
        leftHStack.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(leftHStack)
        NSLayoutConstraint.activate([
            leftHStack.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            leftHStack.widthAnchor.constraint(equalToConstant: 150),
            leftHStack.heightAnchor.constraint(equalToConstant: 50),
            leftHStack.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
        // setup scroll lock button
        scrollLockButton.setImage(scrollImage, for: .normal)
        scrollLockButton.addTarget(self, action: #selector(scrollLockTapped), for: .touchUpInside)
        noteLockButton.addTarget(self, action: #selector(noteLockTapped), for: .touchUpInside)
        noteLockButton.imageView?.tintColor = .white
        sequenceButton.setImage(sequenceImage, for: .normal)
        sequenceButton.addTarget(self, action: #selector(sequenceTapped), for: .touchUpInside)
        sequenceButton.imageView?.tintColor = .white
        [scrollLockButton, noteLockButton, sequenceButton].forEach { btn in
            btn.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                btn.widthAnchor.constraint(equalToConstant: 50),
                btn.heightAnchor.constraint(equalToConstant: 50)
            ])
            leftHStack.addArrangedSubview(btn)
        }
        isScrollLocked = { self.isScrollLocked }()
        isNoteLocked = { self.isNoteLocked }()
        isSequencing = { self.isSequencing }()
        
        // Setup right horiztonal stack
        rightHStack.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(rightHStack)
        NSLayoutConstraint.activate([
            rightHStack.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            rightHStack.widthAnchor.constraint(equalToConstant: 100),
            rightHStack.heightAnchor.constraint(equalToConstant: 50),
            rightHStack.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        playButton.setImage(playImage, for: .normal)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        playButton.imageView?.tintColor = .white
        settingsButton.setImage(settingsImage, for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        settingsButton.imageView?.tintColor = .white
        [settingsButton, playButton].forEach { btn in
            btn.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                btn.widthAnchor.constraint(equalToConstant: 100),
                btn.heightAnchor.constraint(equalToConstant: 50)
            ])
            rightHStack.addArrangedSubview(btn)
        }
        isScrollLocked = { self.isScrollLocked }()
        isNoteLocked = { self.isNoteLocked }()
        
        // setup title
        titleLabel.textColor = .white
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        title = { self.title }()
        DispatchQueue.main.asyncAfter(deadline: .now() + 6, execute: {
            self.title = ""
        })
    }
    
    @objc func scrollLockTapped() {
        self.isScrollLocked = !isScrollLocked
        delegate?.scrollLockDidChange()
    }
    
    @objc func noteLockTapped() {
        self.isNoteLocked = !isNoteLocked
        delegate?.noteLockDidChange()
    }
    
    @objc func playTapped() {
        self.isPlaying = !isPlaying
        delegate?.playDidChange()
    }
    
    @objc func sequenceTapped() {
        self.isSequencing = !isSequencing
        delegate?.sequenceDidChange()
    }
    
    @objc func settingsTapped() {
        delegate?.settingsDidChange()
    }
}
