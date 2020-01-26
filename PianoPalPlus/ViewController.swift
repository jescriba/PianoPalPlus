//
//  ViewController.swift
//  PianoPalPlus
//
//  Created by joshua on 1/1/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ToolBarDelegate {
    var pianoView: PianoView!
    var toolBar: ToolBarView!

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
        view.addSubview(pianoView)
        self.toolBar = ToolBarView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
        view.addSubview(toolBar)
        toolBar.delegate = self
        toolBar.isScrollLocked = pianoView.isScrollLocked
        toolBar.isNoteLocked = pianoView.isNoteLocked
    }
    
    func scrollLockDidChange() {
        pianoView.isScrollLocked = !pianoView.isScrollLocked
    }
    
    func noteLockDidChange() {
        pianoView.isNoteLocked = !pianoView.isNoteLocked
    }
    
    func playDidChange() {
        if toolBar.isPlaying &&
            pianoView.isNoteLocked,
            let lockedNotes = pianoView.lockedNotes {
            AudioEngine.shared.play(lockedNotes, isSequencing: toolBar.isSequencing)
        } else if let lockedNotes = pianoView.lockedNotes {
            AudioEngine.shared.stop(lockedNotes)
        }
    }
    
    func sequenceDidChange() {
        
        //
    }
    
    func settingsDidChange() {
        //
    }

}

