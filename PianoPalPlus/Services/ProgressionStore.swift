//
//  ProgressionStore.swift
//  PianoPalPlus
//
//  Created by joshua on 3/18/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation

enum StoreKeys: String {
    case progression
}

class ProgressionStore {
    static let shared = ProgressionStore()
    
    func save(_ progression: Progression) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(progression),
            let jsonString = String(data: data, encoding: .utf8)  else {
                return
        }
        
        UserDefaults.standard.set(jsonString, forKey: StoreKeys.progression.rawValue)
    }
    
    func load() -> Progression? {
        guard let jsonString = UserDefaults.standard.string(forKey: StoreKeys.progression.rawValue),
            let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        return try? decoder.decode(Progression.self, from: jsonData)
    }
}
