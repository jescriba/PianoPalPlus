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
    
    private func setupViews() {
        self.pianoView = PianoView(frame: view.bounds)
        view.addSubview(pianoView)
        self.toolBar = ToolBarView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
        view.addSubview(toolBar)
        toolBar.delegate = self
        toolBar.isScrollLocked = pianoView.isScrollLocked
    }
    
    func scrollLockDidChange() {
        toolBar.isScrollLocked = !toolBar.isScrollLocked
        pianoView.isScrollLocked = !pianoView.isScrollLocked
    }

}

