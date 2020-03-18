//
//  Progression.swift
//  PianoPalPlus
//
//  Created by joshua on 2/20/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation

protocol Stringable {
    func asString() -> String
}

extension String: Stringable {
    func asString() -> String { return self }
}

protocol TheoryItemDescriptor: Stringable {
    static var all: [TheoryItemDescriptor] { get set }
    func intervals() -> [Interval]
}

enum MusicTheoryItem: String {
    case chord, scale
    
    func descriptors() -> [TheoryItemDescriptor] {
        switch self {
        case .chord:
            return ChordType.all
        case .scale:
            return ScaleType.all
        }
    }
        
    static var all: [MusicTheoryItem] {
        return [.chord, .scale]
    }
}

extension MusicTheoryItem: Stringable {
    func asString() -> String { return rawValue }
}

class ProgressionItem {
    var guid: String = ""
    var sequence: PlayableDataSequence? {
        get {
            if type == .scale {
                return items.map({ PlayableData(playable: [$0], guid: guid) })
            } else {
                return [PlayableData(playable: items, guid: guid)]
            }
        }
    }
    var title: String {
        return "\(root.note.asString()) \(description.asString())" + " \(type == .scale ? type.rawValue : "")"
    }
    private(set) var type: MusicTheoryItem
    private(set) var description: TheoryItemDescriptor
    private(set) var root: NoteOctave
    private var items = [NoteOctave]()
    
    init(type: MusicTheoryItem, description: TheoryItemDescriptor, root: NoteOctave) {
        self.type = type
        self.root = root
        self.description = description
        createItems()
    }
    
    private func createItems() {
        if type == .scale, let scaleType = description as? ScaleType {
            self.items = ScaleGenerator.notes(for: scaleType, root: root)
        } else if type == .chord, let chordType = description as? ChordType {
            self.items = ChordGenerator.notes(for: chordType, root: root)
        }
    }
}

class Progression {
    @Published var items: [ProgressionItem]
    @Published var currentItem: ProgressionItem?
    var sequences: [PlayableDataSequence] {
        return items.compactMap({ $0.sequence })
    }
    
    init(items: [ProgressionItem] = [ProgressionItem]()) {
        self.items = items
    }
    
    func updateGuids() {
        items.enumerated().forEach({ index, item in
            item.guid = "progressionItem-\(index)"
        })
    }
}
