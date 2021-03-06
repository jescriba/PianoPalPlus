//
//  ChordGenerator.swift
//  PianoPalPlus
//
//  Created by joshua on 2/10/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation

typealias Chord = [NoteOctave]

enum ChordType: String, Stringable, TheoryItemDescriptor {
    // todo a lot more chords and altered chord types
    case major
    case majorSixth
    case minor
    case minorSixth
    case augmented
    case diminished
    case majorSeventh
    case minorSeventh
    case dominantSeventh
    case halfDiminishedSeventh
    case diminishedSeventh
    
    func intervals() -> [Interval] {
        switch self {
        case .major:
            return [.unison, .majorThird, .perfectFifth]
        case .majorSixth:
            return [.unison, .majorThird, .perfectFifth, .majorSixth]
        case .minor:
            return [.unison, .minorThird, .perfectFifth]
        case .minorSixth:
            return [.unison, .minorThird, .perfectFifth, .majorSixth]
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
        case .halfDiminishedSeventh:
            return [.unison, .minorThird, .tritone, .minorSeventh]
        case .diminishedSeventh:
            return [.unison, .minorThird, .tritone, .majorSixth]
        }
    }
    
    func asString() -> String {
        switch self {
        case .majorSeventh:
            return "M7"
        case .minorSeventh:
            return "m7"
        case .dominantSeventh:
            return "7"
        case .majorSixth:
            return "M6"
        case .minorSixth:
            return "m6"
        case .halfDiminishedSeventh:
            return "m7b5"
        case .diminishedSeventh:
            return "dim7"
        default:
            return rawValue
        }
    }

        
    static var all: [TheoryItemDescriptor] = [ChordType.major,
                                              ChordType.minor,
                                              ChordType.augmented,
                                              ChordType.diminished,
                                              ChordType.majorSixth,
                                              ChordType.minorSixth,
                                              ChordType.majorSeventh,
                                              ChordType.minorSeventh,
                                              ChordType.dominantSeventh,
                                              ChordType.halfDiminishedSeventh,
                                              ChordType.diminishedSeventh]
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
