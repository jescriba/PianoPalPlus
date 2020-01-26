//
//  NoteButton.swift
//  pianotools
//
//  Created by Joshua Escribano on 6/13/16.
//  Copyright © 2016 Joshua Escribano. All rights reserved.
//

import UIKit

extension UIView {
    func addFullBoundsSubview(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: self.leftAnchor),
            view.rightAnchor.constraint(equalTo: self.rightAnchor),
            view.topAnchor.constraint(equalTo: self.topAnchor),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}

protocol NoteViewTouchDelegate: NSObject {
    func hasTouch(_ hasTouch: Bool, noteView: NoteView)
}

class NoteView: UIView {
    weak var touchDelegate: NoteViewTouchDelegate?
    var touches: Set<UITouch> = Set<UITouch>() {
        didSet {
            if touches.count > 0 {
                if oldValue.isEmpty {
                    touchDelegate?.hasTouch(true, noteView: self)
                }
            } else {
                touchDelegate?.hasTouch(false, noteView: self)
            }
        }
    }
    var noteOctave: NoteOctave
    var note: Note {
        return noteOctave.note
    }
    var octave: Int {
        return noteOctave.octave
    }
    var gradient: CAGradientLayer = CAGradientLayer()
    var illuminated = false
    var title: String? = "" {
        didSet {
            titleLabel.text = title
        }
    }
    var titleColor: UIColor = .black {
        didSet {
            titleLabel.textColor = titleColor
        }
    }
    private var titleLabel = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, note: Note, octave: Int) {
        self.noteOctave = NoteOctave(note: note, octave: octave)
        super.init(frame: frame)
        self.backgroundColor = determineNoteColor(note)
        self.layer.borderWidth = 1
        self.layer.borderColor = Colors.keyBorder
        titleLabel.textAlignment = .center
        self.addFullBoundsSubview(titleLabel)
    }
    
    func determineNoteColor(_ note: Note) -> UIColor {
        if note.isWhiteKey() {
            return UIColor.white
        }
        return UIColor.black
    }
    
    func illuminate(_ colorPairs: [KeyColorPair] = [KeyColorPair(whiteKeyColor: Colors.highlightedWhiteKey,
                                                                 blackKeyColor: Colors.highlightedBlackKey)]) {
        gradient.removeFromSuperlayer()
        if colorPairs.count == 1 {
            let whiteKeyColor = colorPairs[0].whiteKeyColor!
            let blackKeyColor = colorPairs[0].blackKeyColor!
            if (self.note.isWhiteKey()) {
                self.backgroundColor = whiteKeyColor
            } else {
                self.backgroundColor = blackKeyColor
            }
        } else {
            gradient.frame = self.bounds
            gradient.colors = []
            gradient.locations = [0]
            if (self.note.isWhiteKey()) {
                for (index, colorPair) in colorPairs.enumerated() {
                    gradient.colors!.append(colorPair.whiteKeyColor!.cgColor)
                    gradient.colors!.append(colorPair.whiteKeyColor!.cgColor)
                    gradient.locations!.append(Double(index + 1)/Double(colorPairs.count) as NSNumber)
                    gradient.locations!.append(Double(index + 1)/Double(colorPairs.count) as NSNumber)
                }
            } else {
                for (index, colorPair) in colorPairs.enumerated() {
                    gradient.colors!.append(colorPair.blackKeyColor!.cgColor)
                    gradient.colors!.append(colorPair.blackKeyColor!.cgColor)
                    gradient.locations!.append(Double(index + 1)/Double(colorPairs.count) as NSNumber)
                    gradient.locations!.append(Double(index + 1)/Double(colorPairs.count) as NSNumber)
                }
            }
            gradient.locations!.append(1.0)

            self.layer.insertSublayer(gradient, at: 0)
        }
        illuminated = true
    }
    
    func deIlluminate() {
        gradient.removeFromSuperlayer()
        self.backgroundColor = determineNoteColor(note)
        illuminated = false
    }
    
    func highlightBorder() {
        layer.borderColor = Colors.highlightedKeyBorder
        layer.shadowRadius = 10.0
        layer.shadowOpacity = 1
        layer.borderWidth = 5
    }
    
    func dehighlightBorder() {
        layer.borderColor = Colors.keyBorder
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 0
        layer.borderWidth = 1
    }
    
    func label(_ label: String? = nil) {
        var description = label
        if (description == nil) {
            description = "\(note.simpleDescription())\(octave)"
        }
        self.title = description
        if note.isWhiteKey() {
            self.titleColor = .black
        } else {
            self.titleColor = .white
        }
    }
}
