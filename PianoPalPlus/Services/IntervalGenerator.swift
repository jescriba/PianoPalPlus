//
//  IntervalGenerator.swift
//  PianoPalPlus
//
//  Created by joshua on 2/10/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation

class NoteOctaveGenerator {
    static func random() -> NoteOctave {
        let randomNote = Notes.all.randomElement()!
        let randomOctave = Int.random(in: (Octave.min + 1)..<Octave.max) // keeping chords from going low...
        return NoteOctave(note: randomNote, octave: randomOctave)
    }
}

class IntervalGenerator {
    // Returns [NoteOctave] for specified interval. If no root or direction is specified its chosen at random
    static func notes(for interval: Interval,
                      root: NoteOctave? = nil,
                      direction directionO: IntervalDirection? = nil) -> [NoteOctave] {
        let rootNote = root ?? NoteOctaveGenerator.random()
        let direction = directionO ?? IntervalDirection.random()
        var secondNoteOctave: NoteOctave!
        if direction == .up {
            secondNoteOctave = rootNote + interval
        } else {
            secondNoteOctave = rootNote - interval
        }
        return [rootNote, secondNoteOctave]
    }
}
