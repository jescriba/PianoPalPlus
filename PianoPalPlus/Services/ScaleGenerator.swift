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
    // TODONOW @joshua - plan of attack. get the key mode working, then piano/game toggle button, then bug fixing (canceling dispatch queue async after and improve play button binding). and ship this iteration. v0.4 should have basic chord/scale mode. v0.5 functional harmony. Before v1 I should probably get more accurate timing/sequencing figured out
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
