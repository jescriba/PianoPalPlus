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

class ProgressionItem  {
    var guid: Int?
    var type: MusicTheoryItem
    var description: TheoryItemDescriptor
    var title: String {
        guard let firstNote = items.first?.note else {
            return type.rawValue
        }
        return "\(firstNote.simpleDescription()) \(description.asString())" + " \(type == .scale ? type.rawValue : "")"
    }
    var items: [NoteOctave]
    
    init(type: MusicTheoryItem, description: TheoryItemDescriptor, items: [NoteOctave]) {
        self.type = type
        self.items = items
        self.description = description
    }
}

class Progression {
    @Published var items: [ProgressionItem]
    
    init(items: [ProgressionItem] = [ProgressionItem]()) {
        self.items = items
    }
    
    func updateGuids() {
        items.enumerated().forEach({ index, item in
            item.guid = index
        })
    }
}
