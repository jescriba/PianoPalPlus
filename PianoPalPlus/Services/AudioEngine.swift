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

typealias PlayableSequence = [[NoteOctave]]

class AudioEngine {
    @Published var isPlaying = false
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
            Notes.all.forEach { note in
                urls.append(NoteOctave(note: note, octave: octave).url())
            }
        }
        try? pianoSampler.loadAudioFiles(at: urls)
        _engine.attach(pianoSampler)
        _engine.connect(pianoSampler, to: _engine.mainMixerNode, format: format)
        _engine.prepare()
    }
    
    private var workItems = [DispatchWorkItem]()
    func play<T: Sequence>(_ notes: T, isSequencing: Bool = false) where T.Iterator.Element == NoteOctave {
        isPlaying = true
        if isSequencing {
            //let seq = AVAudioSequencer(audioEngine: _engine)
            // TODO Use AVAudioSequencer to schedule events so timing is consistent
            notes.enumerated().forEach { (arg) in
                let (index, note) = arg
                // hack sequencing for now...
                let workItem = DispatchWorkItem(block: { [weak self] in
                    guard let selfV = self else { return }
                    selfV.pianoSampler.startNote(note.midiNote, withVelocity: selfV.noteVelocity, onChannel: 0)
                })
                workItems.append(workItem)
                DispatchQueue.global().asyncAfter(deadline: .now() + Double(index) * 0.5, execute: workItem)
            }
        } else {
            notes.forEach {
                pianoSampler.startNote($0.midiNote, withVelocity: self.noteVelocity, onChannel: 0)
            }
        }
    }
    
    func stop<T: Sequence>(_ notes: T) where T.Iterator.Element == NoteOctave {
        notes.forEach { pianoSampler.stopNote($0.midiNote, onChannel: 0) }
        // clear pending work items
        workItems.forEach({ $0.cancel() })
        workItems.removeAll()
        isPlaying = false
    }
    
    func play(_ sequence: PlayableSequence) {
        sequence.enumerated().forEach({ (arg) in
            let (index, noteOctaves) = arg
            let workItem = DispatchWorkItem(block: { [weak self] in
                self?.play(noteOctaves)
            })
            workItems.append(workItem)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.seconds(index), execute: workItem)
        })
    }
    
    func stop(_ sequence: PlayableSequence) {
        stop(sequence.flatMap({ $0 }))
    }
}
