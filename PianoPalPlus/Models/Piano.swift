//
//  PianoState.swift
//  PianoPalPlus
//
//  Created by joshua on 2/1/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import Combine

class Piano {
    @Published var noteLocked: Bool = false
    @Published var scrollLocked: Bool = true
    @Published var selectedNotes: ObservableUniqueArray<NoteOctave> = ObservableUniqueArray<NoteOctave>()
    @Published var sequencing: Bool = false
    @Published var playing: Bool = false
}
