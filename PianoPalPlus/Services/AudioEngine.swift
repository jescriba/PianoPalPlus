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
    private var notePlayers = [NoteOctave: AVAudioPlayerNode]()
    
    init() {
        _engine = AVAudioEngine()
        
        setupNotePlayers()
        do {
            _ = try _engine.start()
            let audioSession = AVAudioSession.sharedInstance()
            _ = try audioSession.setActive(true)
            _ = try audioSession.setCategory(.playback)
        } catch {
            print("error setting up session")
        }
    }
    
    private func setupNotePlayers() {
        for octave in Octave.min...(Octave.max + 1) {
            Constants.orderedNotes.forEach({ note in
                let notePlayer = AVAudioPlayerNode()
                _engine.attach(notePlayer)
                _engine.connect(notePlayer, to: _engine.mainMixerNode, format: format)
                let noteOctave = NoteOctave(note: note, octave: octave)
                notePlayers[noteOctave] = notePlayer
            })
            _engine.prepare()
        }
    }
    
    func play(_ notes: [NoteOctave], isScale: Bool = false) {
        let notePlayer = notePlayers[notes.first!]!
        let file = try? AVAudioFile(forReading: notes.first!.url() as URL)
        let buffer = AVAudioPCMBuffer(pcmFormat: file!.processingFormat, frameCapacity: AVAudioFrameCount(file!.length))
        _ = try? file?.read(into: buffer!)
        notePlayer.scheduleBuffer(buffer!,
                                  completionHandler: nil)
        notePlayer.play(at: nil)
    }
    
    func stop(_ notes: [NoteOctave]) {
        let notePlayer = notePlayers[notes.first!]!
        notePlayer.stop()
    }
}
