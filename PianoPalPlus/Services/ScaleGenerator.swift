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
            return [.unison, .majorSecond, .majorThird, .perfectFourth, .perfectFifth, .majorSixth, .majorSeventh]
        case .minor:
            return [.unison, .majorSecond, .minorThird, .perfectFourth, .perfectFifth, .minorSixth, .minorSeventh]
        case .melodicMinor:
            return [.unison, .majorSecond, .minorThird, .perfectFourth, .perfectFifth, .majorSixth, .majorSeventh]
        case .harmonicMinor:
            return [.unison, .majorSecond, .minorThird, .perfectFourth, .perfectFifth, .minorSixth, .majorSeventh]
        case .minorPentatonic:
            return [.unison, .minorThird, .perfectFourth, .perfectFifth, .minorSeventh]
        case .blues:
            return [.unison, .minorThird, .perfectFourth, .tritone, .perfectFifth, .minorSeventh]
        case .wholeTone:
            return [.unison, .majorSecond, .majorThird, .tritone, .minorSixth, .minorSeventh]
        case .chromatic:
            return Intervals.all
        case .augmented:
            return [.unison, .minorThird, .majorThird, .perfectFifth, .minorSixth, .majorSeventh]
        case .enigmatic:
            return [.unison, .minorSecond, .majorThird, .tritone, .minorSixth, .minorSeventh, .majorSeventh]
        case .enigmaticMinor:
            return [.unison, .minorSecond, .minorThird, .tritone, .perfectFifth, .minorSeventh, .majorSeventh]
        case .wholeHalfDiminished:
            return [.unison, .majorSecond, .minorThird, .perfectFourth, .tritone, .minorSixth, .majorSixth, .majorSeventh]
        case .bebopDorian:
            return [.unison, .majorSecond, .minorThird, .perfectFourth, .perfectFifth, .majorSixth, .minorSeventh, .majorSeventh]
        case .bebopMajor:
            return [.unison, .majorSecond, .majorThird, .perfectFourth, .perfectFifth, .minorSixth, .majorSixth, .majorSeventh]
        case .bebopDominant:
            return [.unison, .majorSecond, .majorThird, .perfectFourth, .perfectFifth, .majorSixth, .minorSeventh, .majorSeventh]
        case .persian:
            return [.unison, .minorSecond, .majorThird, .perfectFourth, .tritone, .minorSixth, .majorSeventh]
        case .hungarianMinor:
            return [.unison, .majorSecond, .minorThird, .tritone, .perfectFifth, .minorSixth, .majorSeventh]
        case .hungarianMajor:
            return [.unison, .minorThird, .majorThird, .tritone, .perfectFifth, .majorSixth, .minorSeventh]
        }
    }
    
    func chordTypes() -> [ChordType] {
        switch self {
        case .major:
            return [.major, .minor, .minor, .major, .dominantSeventh, .minor, .diminished]
        case .minor:
            return [.minor, .diminished, .major, .minor, .minor, .major, .major]
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
