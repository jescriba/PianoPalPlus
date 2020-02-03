//
//  KeyColorPair.swift
//  pianopal
//
//  Created by Joshua Escribano on 8/3/16.
//  Copyright © 2016 Joshua Escribano. All rights reserved.
//

import Foundation
import UIKit

struct NoteColor: Hashable {
    var noteOctave: NoteOctave
    var color: UIColor
}

struct KeyColorPair {
    static let basic = KeyColorPair(whiteKeyColor: .white, blackKeyColor: .black)
    static let selected = KeyColorPair(whiteKeyColor: Colors.highlightedWhiteKey, blackKeyColor: Colors.highlightedBlackKey)
    
    var whiteKeyColor: UIColor
    var blackKeyColor: UIColor
    
    init(whiteKeyColor: UIColor, blackKeyColor: UIColor) {
        self.whiteKeyColor = whiteKeyColor
        self.blackKeyColor = blackKeyColor
    }
}
