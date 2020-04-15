//
//  ObservableUniqueArray.swift
//  PianoPalPlus
//
//  Created by joshua on 2/13/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import Combine

struct ChangedElements<T: Hashable> {
    let values: [T]
    let change: ChangeType
}

enum ChangeType {
    case added, changed, removed
}

class ObservableUniqueArray<T:Hashable> {
    var array: [T] {
        return Array(_array)
    }
    private var _array = [T]()
    private var _dictionary = [T:Int]()
    @Published var changedElements: ChangedElements<T>?
    @Published var observableArray: [T] = [T]()
    
    func contains(_ element: T) -> Bool {
        return _dictionary[element] != nil
    }
    
    func insert(_ element: T) {
        guard _dictionary[element] == nil else { return }
        _dictionary[element] = 1 // o(1) appending at the expense of memory
        _array.append(element)
        observableArray = _array
        changedElements = ChangedElements(values: [element], change: .added)
    }
    
    func insert(_ element: T, replace: Bool) {
        guard replace else {
            insert(element)
            return
        }
        
        if _dictionary[element] != nil {
            guard let index = _array.firstIndex(of: element) else { return }
            _array.remove(at: index)
            _array.insert(element, at: index)
            changedElements = ChangedElements(values: [element], change: .changed)
        } else {
            _dictionary[element] = 1 // o(1) appending at the expense of memory
            _array.append(element)
            changedElements = ChangedElements(values: [element], change: .added)
        }
        observableArray = _array
    }
    
    func remove(_ element: T) {
        guard _dictionary[element] != nil else { return }
        _dictionary[element] = nil
        // slightly faster than removeAll(where:) since we know uniqueness
        for (index, value) in _array.enumerated() {
            if value == element {
                _array.remove(at: index)
                break
            }
        }
        changedElements = ChangedElements(values: [element], change: .removed)
        observableArray = _array
    }
    
    func removeAll() {
        changedElements = ChangedElements(values: array, change: .removed)
        _array.removeAll()
        _dictionary.removeAll()
        observableArray = _array
    }

}
