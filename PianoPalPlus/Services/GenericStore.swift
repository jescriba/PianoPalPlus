//
//  GenericStore.swift
//  PianoPalPlus
//
//  Created by joshua on 3/29/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation

enum StoreKey: String {
    case progression
}

class Store {
    static let shared = Store()
    
    func save<T: Codable>(_ item: T, key: StoreKey) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(item),
            let jsonString = String(data: data, encoding: .utf8)  else {
                return
        }
        
        UserDefaults.standard.set(jsonString, forKey: key.rawValue)
    }
    
    func load<T: Codable>(from key: StoreKey) -> T? {
        guard let jsonString = UserDefaults.standard.string(forKey: key.rawValue),
            let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: jsonData)
    }
}
