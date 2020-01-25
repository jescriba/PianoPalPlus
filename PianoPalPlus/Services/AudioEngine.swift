//
//  AudioEngine.swift
//  PianoPalPlus
//
//  Created by joshua on 1/20/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import AVFoundation

class AudioEngine {
    static let shared = AudioEngine()
    let format = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)
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
    
    func play(_ notes: [NoteOctave], isScale: Bool = false) {
        notes.forEach { pianoSampler.startNote($0.midiNote, withVelocity: 60, onChannel: 0) }
    }
    
    func stop(_ notes: [NoteOctave]) {
        notes.forEach { pianoSampler.stopNote($0.midiNote, onChannel: 0) }
    }
}
