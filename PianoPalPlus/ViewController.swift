//
//  ViewController.swift
//  PianoPalPlus
//
//  Created by joshua on 1/1/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let pianoView = PianoView()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        pianoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pianoView)
        NSLayoutConstraint.activate([
            pianoView.leftAnchor.constraint(equalTo: view.leftAnchor),
            pianoView.rightAnchor.constraint(equalTo: view.rightAnchor),
            pianoView.topAnchor.constraint(equalTo: view.topAnchor),
            pianoView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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

