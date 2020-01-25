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
    
  //  func noteSelectedForIdentification(_ sender: NoteButton) {
//        if sender.illuminated {
//            sender.deIlluminate()
//            pianoView.highlightedNoteButtons.remove(at: pianoView.highlightedNoteButtons.index(of: sender)!)
//            notesToIdentify.remove(at: notesToIdentify.index(of: sender.note!)!)
//        } else {
//            sender.illuminate([KeyColorPair(whiteKeyColor: Colors.highlightedWhiteKey, blackKeyColor: Colors.highlightedBlackKey)])
//            pianoView.highlightedNoteButtons.append(sender)
//            notesToIdentify.append(sender.note!)
//        }
//        DispatchQueue.global().async(execute: {
//            self.identifiedChord = ChordIdentifier.chordForNotes(self.notesToIdentify)
//            var chordDescription: String?
//            if self.identifiedChord == nil {
//                chordDescription = "N/A"
//            } else {
//                chordDescription = self.identifiedChord?.simpleDescription()
//            }
//            DispatchQueue.main.async(execute: {
//                let navController = self.navigationController as! PianoNavigationViewController
//                navController.customNavigationItem.title = chordDescription
//            })
//        })
  //  }
    


}

