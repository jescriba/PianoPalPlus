//
//  NoteViewModel.swift
//  PianoPalPlus
//
//  Created by joshua on 2/2/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import UIKit
import Combine

class NoteViewModel {
    @Published var label: String?
    @Published var backgroundColor: UIColor = .white
    @Published var borderColor: UIColor = Colors.keyBorder
    var isWhiteKey: Bool {
        return noteOctave.note.isWhiteKey()
    }
    var isBlackKey: Bool {
        return noteOctave.note.isBlackKey()
    }
    var keyColorPair: KeyColorPair = .basic {
        didSet {
            backgroundColor = isWhiteKey ? keyColorPair.whiteKeyColor : keyColorPair.blackKeyColor
        }
    }
    let noteOctave: NoteOctave
    
    init(noteOctave: NoteOctave) {
        self.noteOctave = noteOctave
        defer {
            self.keyColorPair = .basic
        }
    }
}
