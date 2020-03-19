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

protocol TheoryItemDescriptor: Stringable, Codable {
    static var all: [TheoryItemDescriptor] { get set }
    func intervals() -> [Interval]
}

enum MusicTheoryItem: String, Codable {
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

class ProgressionItem: Codable {
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
    
    enum CodingKeys: String, CodingKey {
        case guid, type, description, root
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.guid = try container.decode(String.self, forKey: .guid)
        self.type = try container.decode(MusicTheoryItem.self, forKey: .type)
        self.root = try container.decode(NoteOctave.self, forKey: .root)
        if type == .chord {
            self.description = try container.decode(ChordType.self, forKey: .description)
        } else {
            self.description = try container.decode(ScaleType.self, forKey: .description)
        }
        self.createItems()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(guid, forKey: .guid)
        try container.encode(type, forKey: .type)
        try container.encode(root, forKey: .root)
        if type == .chord {
            try container.encode(description as? ChordType, forKey: .description)
        } else {
            try container.encode(description as? ScaleType, forKey: .description)
        }
    }
    
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

class Progression: Codable {
    @Published var items: [ProgressionItem]
    @Published var currentItem: ProgressionItem?
    var sequences: [PlayableDataSequence] {
        return items.compactMap({ $0.sequence })
    }
    
    init(items: [ProgressionItem] = [ProgressionItem]()) {
        self.items = items
    }
    
    enum CodingKeys: String, CodingKey {
        case items
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.items = try container.decode([ProgressionItem].self, forKey: .items)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(items, forKey: .items)
    }
    
    func updateGuids() {
        items.enumerated().forEach({ index, item in
            item.guid = "progressionItem-\(index)"
        })
    }
}
