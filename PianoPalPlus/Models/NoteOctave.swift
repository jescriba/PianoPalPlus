//
//  NoteOctave.swift
//  pianopal
//
//  Created by Joshua Escribano on 8/14/16.
//  Copyright © 2016 Joshua Escribano. All rights reserved.
//

import Foundation

typealias Octave = Int
extension Octave {
    static let max = 6
    static let min = 0
}

class NoteOctaves {
    static var all: [NoteOctave] {
        var values = [NoteOctave]()
        Notes.all.forEach({ note in
            (Octave.min...Octave.max).forEach { octave in
                values.append(NoteOctave(note: note, octave: octave))
            }
        })
        return values
    }
}

class NoteOctave: Equatable, Hashable, Codable {
    var note: Note
    var octave: Int
    var midiNote: UInt8 {
        return UInt8(note.baseInt() + (octave + 1) * 12) // c0 starts at midiNote 12
    }
    
    init(note: Note, octave: Int) {
        self.note = note
        self.octave = octave
    }
    
    func toString() -> String {
        return "\(note.simpleDescription())\(octave)"
    }
    
    func url() -> URL {
        let filePath = Bundle.main.path(forResource: "\(toString())", ofType: "mp3")
        return URL(fileURLWithPath: filePath!)
    }
    
    static func ==(item1: NoteOctave, item2: NoteOctave) -> Bool {
        return item1.note == item2.note && item1.octave == item2.octave
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(note)
        hasher.combine(octave)
    }
    
    static func +(noteOctave: NoteOctave, interval: Interval) -> NoteOctave {
        let noteIndex = Notes.all.firstIndex(of: noteOctave.note)!
        let newNoteIndex = noteIndex + interval.rawValue
        var newOctave = noteOctave.octave
        if newNoteIndex >= Notes.all.count {
            newOctave += 1
        }
        let newNote = Notes.all[newNoteIndex % Notes.all.count]
        return NoteOctave(note: newNote, octave: newOctave)
    }
    
    static func -(noteOctave: NoteOctave, interval: Interval) -> NoteOctave {
        let noteIndex = Notes.all.firstIndex(of: noteOctave.note)!
        var newNoteIndex = noteIndex - interval.rawValue
        var newOctave = noteOctave.octave
        if newNoteIndex < 0 {
            newOctave -= 1
            newNoteIndex += Notes.all.count
        }
        let newNote = Notes.all[newNoteIndex % Notes.all.count]
        return NoteOctave(note: newNote, octave: newOctave)
    }
}
