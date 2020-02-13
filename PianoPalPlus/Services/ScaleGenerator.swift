//
//  ScaleGenerator.swift
//  PianoPalPlus
//
//  Created by joshua on 2/10/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation

enum ScaleType: String {
    // todo more scale types and compatibilty w/ chords
    case major
    
    func intervals() -> [Interval] {
        switch self {
        case .major:
            return [.majorSecond, .majorThird, .perfectFourth, .perfectFifth, .majorSixth, .majorSeventh]
        }
    }
    
    func chordTypes() -> [ChordType] {
        switch self {
        case .major:
            return [.major, .minor, .minor, .major, .dominantSeventh, .minor, .diminished]
        }
    }
}

class ScaleGenerator {
    static func notes(for type: ScaleType,
                      root: NoteOctave? = nil) -> [NoteOctave] {
        let rootNote = root ?? NoteOctaveGenerator.random()
        var scaleNotes = [NoteOctave]()
        type.intervals().forEach { interval in
            scaleNotes.append(rootNote + interval)
        }
        return scaleNotes
    }
    
}
