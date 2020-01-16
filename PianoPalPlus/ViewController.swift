//
//  ViewController.swift
//  PianoPalPlus
//
//  Created by joshua on 1/1/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var pianoView: PianoView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.pianoView = PianoView(frame: view.bounds)
        view.addSubview(pianoView)
    }
    
    func noteSelectedForIdentification(_ sender: NoteButton) {
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
    }
    


}

