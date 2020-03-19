//
//  ScaleGenerator.swift
//  PianoPalPlus
//
//  Created by joshua on 2/10/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation

enum ScaleType: String, TheoryItemDescriptor {
    // todo more scale types and compatibilty w/ chords
    case major, minor
    
    func intervals() -> [Interval] {
        switch self {
        case .major:
            return [.unison, .majorSecond, .majorThird, .perfectFourth, .perfectFifth, .majorSixth, .majorSeventh]
        case .minor:
            return [.unison, .majorSecond, .minorThird, .perfectFourth, .perfectFifth, .minorSixth, .minorSeventh]
        }
    }
    
    func chordTypes() -> [ChordType] {
        switch self {
        case .major:
            return [.major, .minor, .minor, .major, .dominantSeventh, .minor, .diminished]
        case .minor:
            return [.minor, .diminished, .major, .minor, .minor, .major, .major]
        }
    }
    
    static var all: [TheoryItemDescriptor] = [ScaleType.major, ScaleType.minor]

}

extension ScaleType: Stringable {
    func asString() -> String { return rawValue }
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
