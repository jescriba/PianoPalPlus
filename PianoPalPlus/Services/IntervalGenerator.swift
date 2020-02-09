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
        let randomNote = Constants.orderedNotes.randomElement()!
        let randomOctave = Int.random(in: Octave.min..<Octave.max)
        return NoteOctave(note: randomNote, octave: randomOctave)
    }
}

class IntervalGenerator {
    // Returns [NoteOctave] for specified interval. If no root or direction is specified its chosen at random
    static func notes(for interval: Interval,
                      root: NoteOctave? = nil,
                      direction directionO: IntervalDirection? = nil) -> [NoteOctave] {
        let rootNote = root ?? NoteOctaveGenerator.random()
        let rootNoteIndex = Constants.orderedNotes.firstIndex(of: rootNote.note)!
        let direction = directionO ?? IntervalDirection.random()
        var secondNoteIndex: Int!
        var secondOctave = rootNote.octave
        if direction == .up {
            secondNoteIndex = rootNoteIndex + interval.rawValue
            if secondNoteIndex >= Constants.orderedNotes.count {
                secondOctave += 1
            }
        } else {
            secondNoteIndex = rootNoteIndex - interval.rawValue
            if secondNoteIndex < 0 {
                secondNoteIndex += Constants.orderedNotes.count
                secondOctave -= 1
            }
        }
        let secondNote = Constants.orderedNotes[secondNoteIndex % Constants.orderedNotes.count]
        let secondNoteOctave = NoteOctave(note: secondNote, octave: secondOctave)
        return [rootNote, secondNoteOctave]
    }
}
