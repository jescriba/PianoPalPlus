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
        // TODO more sophisticated and refactor
        var music = [[NoteOctave]]()
        let scaleNotes = ScaleGenerator.notes(for: scaleType, root: root)
        let sequenceLength = Int.random(in: 2...11)
        for _ in 0...sequenceLength {
            // todo leverage some extended notion of tonic, pd, d
            let chanceOfChord = Int.random(in: 0...6)
            if chanceOfChord < 4 {
                // hack to get started with pd, d, tonic progressions
                if chanceOfChord < 3 {
                    let tonicDominantPredominantTones = [0, 3, 4]
                    let firstChordIndex = tonicDominantPredominantTones.randomElement()!
                    let secondChordIndex = tonicDominantPredominantTones.filter({ $0 != firstChordIndex }).randomElement()!
                    music.append(ChordGenerator.notes(for: scaleType.chordTypes()[firstChordIndex], root: scaleNotes[firstChordIndex]))
                    music.append(ChordGenerator.notes(for: scaleType.chordTypes()[secondChordIndex], root: scaleNotes[secondChordIndex]))
                } else {
                    // just add some random diatonic chord
                    let noteIndex = Int.random(in: 0..<scaleNotes.count)
                    let chordType = scaleType.chordTypes()[noteIndex]
                    music.append(ChordGenerator.notes(for: chordType, root: scaleNotes[noteIndex]))
                }
            } else {
                // generate note
                music.append([scaleNotes.randomElement()!])
            }
        }
        
        return music
    }
}
