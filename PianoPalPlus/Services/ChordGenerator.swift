//
//  ChordGenerator.swift
//  PianoPalPlus
//
//  Created by joshua on 2/10/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation

class ChordTypes {
    static var all: [ChordType]  {
        return [.major, .minor, .augmented, .diminished, .majorSeventh,
                .minorSeventh, .dominantSeventh]
    }
}

enum ChordType: String {
    // todo a lot more chords and altered chord types
    case major
    case minor
    case augmented
    case diminished
    case majorSeventh
    case minorSeventh
    case dominantSeventh
    
    func intervals() -> [Interval] {
        switch self {
        case .major:
            return [.unison, .majorThird, .perfectFifth]
        case .minor:
            return [.unison, .minorThird, .perfectFifth]
        case .augmented:
            return [.unison, .majorThird, .minorSixth]
        case .diminished:
            return [.unison, .minorThird, .tritone]
        case .majorSeventh:
            return [.unison, .majorThird, .perfectFifth, .majorSeventh]
        case .minorSeventh:
            return [.unison, .minorThird, .perfectFifth, .minorSeventh]
        case .dominantSeventh:
            return [.unison, .majorThird, .perfectFifth, .minorSeventh]
        }
    }
}

class ChordGenerator {
    // Returns [NoteOctave] for specified chord type. If no root is specified its chosen at random
    // TODO: Arpeggios and voicing options
    static func notes(for type: ChordType,
                      root: NoteOctave? = nil) -> [NoteOctave] {
        let rootNote = root ?? NoteOctaveGenerator.random()
        var notes = [NoteOctave]()
        type.intervals().forEach({ interval in
            notes.append(rootNote + interval)
        })
        return notes
    }
}
