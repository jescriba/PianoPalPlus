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

typealias Playable = [NoteOctave]
typealias PlayableSequence = [Playable]
typealias PlayableDataSequence = [PlayableDataP]
protocol PlayableDataP {
    var playable: Playable { get set }
    var guid: String { get set }
}
class PlayableData: PlayableDataP {
    var playable: Playable
    var guid: String
    
    init(playable: Playable, guid: String = "") {
        self.playable = playable
        self.guid = guid
    }
}
extension Playable: PlayableDataP {
    var playable: Playable {
        get {
            return self
        } set { self = newValue }
    }
    var guid: String {
        get { return "" } set { }
    }
}

class AudioEngine {
    @Published var isPlaying = false
    @Published private(set) var playData: PlayableDataP?
    static let shared = AudioEngine()
    private let audioSerialQueue = DispatchQueue(label: "audioQueue", qos: .userInitiated)
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

    func play(_ data: PlayableDataP) {
        isPlaying = true
        playData = data
        data.playable.forEach({ note in
            pianoSampler.startNote(note.midiNote, withVelocity: self.noteVelocity, onChannel: 0)
        })
    }
    
    func stop(_ data: PlayableDataP) {
        data.playable.forEach({ pianoSampler.stopNote($0.midiNote, onChannel: 0) })
        playData = nil
        isPlaying = false
    }
    
    private var playGroups = [DispatchGroup]()
    private var previousPlay: PlayableDataP?
    func play(_ sequence: PlayableDataSequence, delay: Int = 0) {
        let newGroup = DispatchGroup()
        newGroup.enter()
        let sequenceWorkItem = DispatchWorkItem(block: { [weak self] in
            sequence.enumerated().forEach({ arg in
                let (index, data) = arg
                newGroup.enter()
                let workItem = DispatchWorkItem(block: { [weak self] in
                    guard let selfV = self else { return }
                    if let previous = selfV.previousPlay {
                        selfV.stop(previous)
                    }
                    selfV.play(data)
                    selfV.previousPlay = data
                    newGroup.leave()
                })
                self?.workItems.append(workItem)
                self?.audioSerialQueue.asyncAfter(deadline: .now() + .milliseconds(600 * index), execute: workItem)
            })
            newGroup.leave()
        })
        self.workItems.append(sequenceWorkItem)
        let lastGroupO = playGroups.last
        self.playGroups.append(newGroup)
        guard let lastGroup = lastGroupO else {
            audioSerialQueue.asyncAfter(deadline: .now() + .seconds(delay), execute: sequenceWorkItem)
            return
        }
        // basically want to notify with the delay
        let delayedWorkItem = DispatchWorkItem { [weak self] in
            self?.audioSerialQueue.asyncAfter(deadline: .now() + .seconds(delay), execute: sequenceWorkItem)
        }
        self.workItems.append(delayedWorkItem)
        lastGroup.notify(queue: audioSerialQueue, work: delayedWorkItem)
    }
    
    func stop(_ sequence: PlayableDataSequence) {
        sequence.forEach({ stop($0) })
        workItems.forEach({ $0.cancel() })
        workItems.removeAll()
        playGroups.removeAll()
    }
    
    func play(_ sequences: [PlayableDataSequence]) {
        sequences.enumerated().forEach({ (index, sequence) in
            play(sequence, delay: index == 0 ? 0 : 1)
        })
    }
    
    func stop(_ sequences: [PlayableDataSequence]) {
        sequences.forEach({ stop($0) })
    }
}
