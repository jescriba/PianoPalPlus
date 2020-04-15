//
//  ScaleGenerator.swift
//  PianoPalPlus
//
//  Created by joshua on 2/10/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation

enum ScaleType: String, Stringable, TheoryItemDescriptor {
    // todo more scale types and compatibilty w/ chords
    case major
    case minor
    case melodicMinor
    case harmonicMinor
    case minorPentatonic
    case blues
    case wholeTone
    case chromatic
    case augmented
    case enigmatic
    case enigmaticMinor
    case wholeHalfDiminished
    case bebopDorian
    case bebopMajor
    case bebopDominant
    case persian
    case hungarianMinor
    case hungarianMajor
    
    func intervals() -> [Interval] {
        switch self {
        case .major:
            return [.unison, .majorSecond, .majorThird, .perfectFourth, .perfectFifth, .majorSixth, .majorSeventh, .octave]
        case .minor:
            return [.unison, .majorSecond, .minorThird, .perfectFourth, .perfectFifth, .minorSixth, .minorSeventh, .octave]
        case .melodicMinor:
            return [.unison, .majorSecond, .minorThird, .perfectFourth, .perfectFifth, .majorSixth, .majorSeventh, .octave]
        case .harmonicMinor:
            return [.unison, .majorSecond, .minorThird, .perfectFourth, .perfectFifth, .minorSixth, .majorSeventh, .octave]
        case .minorPentatonic:
            return [.unison, .minorThird, .perfectFourth, .perfectFifth, .minorSeventh, .octave]
        case .blues:
            return [.unison, .minorThird, .perfectFourth, .tritone, .perfectFifth, .minorSeventh, .octave]
        case .wholeTone:
            return [.unison, .majorSecond, .majorThird, .tritone, .minorSixth, .minorSeventh, .octave]
        case .chromatic:
            return Intervals.all
        case .augmented:
            return [.unison, .minorThird, .majorThird, .perfectFifth, .minorSixth, .majorSeventh, .octave]
        case .enigmatic:
            return [.unison, .minorSecond, .majorThird, .tritone, .minorSixth, .minorSeventh, .majorSeventh, .octave]
        case .enigmaticMinor:
            return [.unison, .minorSecond, .minorThird, .tritone, .perfectFifth, .minorSeventh, .majorSeventh, .octave]
        case .wholeHalfDiminished:
            return [.unison, .majorSecond, .minorThird, .perfectFourth, .tritone, .minorSixth, .majorSixth, .majorSeventh, .octave]
        case .bebopDorian:
            return [.unison, .majorSecond, .minorThird, .perfectFourth, .perfectFifth, .majorSixth, .minorSeventh, .majorSeventh, .octave]
        case .bebopMajor:
            return [.unison, .majorSecond, .majorThird, .perfectFourth, .perfectFifth, .minorSixth, .majorSixth, .majorSeventh, .octave]
        case .bebopDominant:
            return [.unison, .majorSecond, .majorThird, .perfectFourth, .perfectFifth, .majorSixth, .minorSeventh, .majorSeventh, .octave]
        case .persian:
            return [.unison, .minorSecond, .majorThird, .perfectFourth, .tritone, .minorSixth, .majorSeventh, .octave]
        case .hungarianMinor:
            return [.unison, .majorSecond, .minorThird, .tritone, .perfectFifth, .minorSixth, .majorSeventh, .octave]
        case .hungarianMajor:
            return [.unison, .minorThird, .majorThird, .tritone, .perfectFifth, .majorSixth, .minorSeventh, .octave]
        }
    }
    
    func chordTypes() -> [ChordType] {
        switch self {
        case .major:
            return [.major, .minor, .minor, .major, .dominantSeventh, .minor, .diminished, .major]
        case .minor:
            return [.minor, .diminished, .major, .minor, .minor, .major, .major, .minor]
        default:
            // TODO - useful for the key generator
            return []
        }
    }
    
    static var all: [TheoryItemDescriptor] = [ScaleType.major,
                                              ScaleType.minor,
                                              ScaleType.melodicMinor,
                                              ScaleType.harmonicMinor,
                                              ScaleType.minorPentatonic,
                                              ScaleType.blues,
                                              ScaleType.wholeTone,
                                              ScaleType.chromatic,
                                              ScaleType.augmented,
                                              ScaleType.enigmatic,
                                              ScaleType.enigmaticMinor,
                                              ScaleType.wholeHalfDiminished,
                                              ScaleType.bebopDorian,
                                              ScaleType.bebopMajor,
                                              ScaleType.bebopDominant,
                                              ScaleType.persian,
                                              ScaleType.hungarianMinor,
                                              ScaleType.hungarianMajor]

    func asString() -> String {
        switch self {
        case .melodicMinor:
            return "melodic minor"
        case .harmonicMinor:
            return "harmonic minor"
        case .minorPentatonic:
            return "minor pentatonic"
        case .wholeTone:
            return "whole tone"
        case .enigmaticMinor:
            return "enigmatic minor"
        case .wholeHalfDiminished:
            return "diminished"
        case .bebopDorian:
            return "bebop dorian"
        case .bebopMajor:
            return "bebop major"
        case .bebopDominant:
            return "bebop dominant"
        case .hungarianMinor:
            return "hungarian minor"
        case .hungarianMajor:
            return "hungarian major"
        default:
            return rawValue
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
