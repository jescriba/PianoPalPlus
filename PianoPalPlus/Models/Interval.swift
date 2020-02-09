//
//  Interval.swift
//  PianoPalPlus
//
//  Created by joshua on 2/9/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation

class Intervals {
    static var all: [Interval] {
        return [.unison, .minorSecond, .majorSecond, .minorThird,
                .majorThird, .perfectFourth, .tritone, .perfectFifth,
                .minorSixth, .majorSixth, .minorSeventh, .majorSeventh, .octave]
    }
}

enum IntervalDirection: String {
    case up, down
    
    static func random() -> IntervalDirection {
        return [IntervalDirection.up, IntervalDirection.down].randomElement()!
    }
}

enum Interval: Int {
    case unison
    case minorSecond
    case majorSecond
    case minorThird
    case majorThird
    case perfectFourth
    case tritone
    case perfectFifth
    case minorSixth
    case majorSixth
    case minorSeventh
    case majorSeventh
    case octave
    
    func title() -> String {
        // dry
        switch self {
        case .unison:
            return "unison"
        case .minorSecond:
            return "minor second"
        case .majorSecond:
            return "major second"
        case .minorThird:
            return "minor third"
        case .majorThird:
            return "major third"
        case .perfectFourth:
            return "perfect fourth"
        case .tritone:
            return "tritone"
        case .perfectFifth:
            return "perfect fifth"
        case .minorSixth:
            return "minor sixth"
        case .majorSixth:
            return "major sixth"
        case .minorSeventh:
            return "minor seventh"
        case .majorSeventh:
            return "major seventh"
        case .octave:
            return "octave"
        }
    }
}
