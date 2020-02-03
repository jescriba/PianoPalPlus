//
//  AudioEngine.swift
//  PianoPalPlus
//
//  Created by joshua on 1/20/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import AVFoundation
import Combine

class AudioEngine {
    static let shared = AudioEngine()
    let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)
    private let noteVelocity: UInt8 = 127
    private var _engine: AVAudioEngine
    private var pianoSampler = AVAudioUnitSampler()
    
    init() {
        _engine = AVAudioEngine()
        
        setup()
        do {
            _ = try _engine.start()
            let audioSession = AVAudioSession.sharedInstance()
            _ = try audioSession.setActive(true)
            _ = try audioSession.setCategory(.playback)
        } catch {
            print("error setting up session")
        }
    }
    
    private func setup() {
        var urls = [URL]()
        for octave in Octave.min...Octave.max {
            Constants.orderedNotes.forEach { note in
                urls.append(NoteOctave(note: note, octave: octave).url())
            }
        }
        try? pianoSampler.loadAudioFiles(at: urls)
        _engine.attach(pianoSampler)
        _engine.connect(pianoSampler, to: _engine.mainMixerNode, format: format)
        _engine.prepare()
    }
    
    func play<T: Sequence>(_ notes: T, isSequencing: Bool = false) where T.Iterator.Element == NoteOctave {
        if isSequencing {
            //let seq = AVAudioSequencer(audioEngine: _engine)
            // TODO Use AVAudioSequencer to schedule events so timing is consistent
            
            notes.enumerated().forEach { (arg) in
                let (index, note) = arg
                // hack sequencing for now...
                DispatchQueue.global().asyncAfter(deadline: .now() + Double(index) * 0.5, execute: {
                    self.pianoSampler.startNote(note.midiNote, withVelocity: self.noteVelocity, onChannel: 0)
                    })
            }
        } else {
            notes.forEach {
                pianoSampler.startNote($0.midiNote, withVelocity: self.noteVelocity, onChannel: 0)
            }
        }
    }
    
    func stop<T: Sequence>(_ notes: T) where T.Iterator.Element == NoteOctave {
        notes.forEach { pianoSampler.stopNote($0.midiNote, onChannel: 0) }
    }
}
