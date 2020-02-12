//
//  ToolBar.swift
//  PianoPalPlus
//
//  Created by joshua on 1/30/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import Combine

class ToolBar {
    @Published var scrollLocked: Bool = true
    @Published var noteLocked: Bool = false
    @Published var playActive: Bool = false
    @Published var sequenceActive: Bool = false
    @Published var pianoToggled: Bool = true
    @Published var contentMode: ContentMode?
}
