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
    static let basic = KeyColorPair(whiteKeyColor: UIColor.whiteKey, blackKeyColor: UIColor.blackKey)
    static let selected = KeyColorPair(whiteKeyColor: UIColor.selectedWhiteKey, blackKeyColor: UIColor.selectedBlackKey)
    static let playing = KeyColorPair(whiteKeyColor: UIColor.playingWhiteKey, blackKeyColor: UIColor.playingBlackKey)
    
    var whiteKeyColor: UIColor
    var blackKeyColor: UIColor
    
    init(whiteKeyColor: UIColor, blackKeyColor: UIColor) {
        self.whiteKeyColor = whiteKeyColor
        self.blackKeyColor = blackKeyColor
    }
}
