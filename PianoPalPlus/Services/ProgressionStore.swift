//
//  ProgressionStore.swift
//  PianoPalPlus
//
//  Created by joshua on 3/18/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation

class ProgressionStore {
    static let shared = ProgressionStore()
    
    func save() {
        
    }
    
    func load() -> Progression {
        return Progression()
    }
}
