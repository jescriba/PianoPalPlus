//
//  KeyGenerator.swift
//  PianoPalPlus
//
//  Created by joshua on 2/10/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation

class KeyGenerator {
    // random 'music' generator in the key of the root note with the specified scale typ
    static func notesAndChords(for root: NoteOctave, scaleType: ScaleType = .major) -> [[NoteOctave]] {
        // TODO more sophisticated
        var music = [[NoteOctave]]()
        let scaleNotes = ScaleGenerator.notes(for: scaleType, root: root)
        for _ in 0...Int.random(in: 2..<11) {
            if Int.random(in: 0...3) < 1 {
                // generate chord
                // todo leverage some notion of tonic, pd, d
                let noteIndex = Int.random(in: 0..<scaleNotes.count)
                let chordType = scaleType.chordTypes()[noteIndex]
                music.append(ChordGenerator.notes(for: chordType, root: scaleNotes[noteIndex]))
            } else {
                // generate note
                music.append([scaleNotes.randomElement()!])
            }
        }
        
        return music
    }
}
