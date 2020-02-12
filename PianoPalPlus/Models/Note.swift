//
//  Note.swift
//  pianotools
//
//  Created by Joshua Escribano on 6/13/16.
//  Copyright © 2016 Joshua Escribano. All rights reserved.
//

import Foundation

class Notes {
    static var all: [Note] {
        return [Note.c,
                Note.dFlat,
                Note.d,
                Note.eFlat,
                Note.e,
                Note.f,
                Note.fSharp,
                Note.g,
                Note.aFlat,
                Note.a,
                Note.bFlat,
                Note.b]
    }
}

enum Note : Int {
    case c, dFlat, d, eFlat, e, f, fSharp, g, aFlat, a, bFlat, b
    
    func isWhiteKey() -> Bool {
        return !isBlackKey()
    }
    
    func isBlackKey() -> Bool {
        switch self {
        case .c, .d, .e, .f, .g, .a, .b:
            return false
        default:
            return true
        }
    }
    
    func simpleDescription() -> String {
        switch self {
        case .c:
            return "C"
        case .dFlat:
            return "Db"
        case .d:
            return "D"
        case .eFlat:
            return "Eb"
        case .e:
            return "E"
        case .f:
            return "F"
        case .fSharp:
            return "Gb"
        case .g:
            return "G"
        case .aFlat:
            return "Ab"
        case .a:
            return "A"
        case .bFlat:
            return "Bb"
        case .b:
            return "B"
        }
    }
    
    func baseInt() -> Int {
        return Notes.all.firstIndex(of: self)!
    }
}
