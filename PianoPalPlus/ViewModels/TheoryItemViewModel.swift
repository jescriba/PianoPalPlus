//
//  TheoryItemViewModel.swift
//  PianoPalPlus
//
//  Created by joshua on 3/14/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import UIKit

class TheoryItemViewModel: NSObject {
    private var contentModeService: ContentModeService
    private var progression: Progression
    private var progressionItem: ProgressionItem?
    private var itemType: MusicTheoryItem?
    @Published var pickerSelections: [IndexPath]?
    private var isEditing: Bool = false
    
    enum ComponentType: String {
        case item, root, quality, alterations
        
        func options(constraint: Any? = nil) -> [Stringable] {
            switch self {
            case .item:
                return MusicTheoryItem.all
            case .root:
                return Notes.all
            case .quality:
                if let theoryItem = constraint as? MusicTheoryItem {
                    return theoryItem.descriptors()
                }
                return ChordType.all
            default:
                return ["-"]
            }
        }
        
        static var all: [ComponentType] { return [.item, .root, .quality, .alterations] }
    }
    
    init(contentModeService: ContentModeService = .shared, progression: Progression) {
        self.contentModeService = contentModeService
        self.progression = progression
    }
    
    func edit(item: ProgressionItem?) {
        // distinguish between editing an existing item and creating a new one altogether
        setSelectionsFor(item: item)
        if let existingItem = item {
            isEditing = true
            progressionItem = existingItem
        } else {
            isEditing = false
            progressionItem = nil
        }
    }
    
    private func setSelectionsFor(item itemO: ProgressionItem?) {
        var tempSelections = [IndexPath]()

        guard let item = itemO else {
            (0..<ComponentType.all.count).forEach({ component in
                tempSelections.append(IndexPath(row: 0, section: component))
            })
            pickerSelections = tempSelections
            return
        }
        
        // Populate picker selections based on ProgressionItem values
        (0..<ComponentType.all.count).forEach({ component in
            let options = ComponentType.all[component].options()
            guard let option = options.first else { return }
            var selectedIndexO: Int?
            switch option {
            case is MusicTheoryItem:
                selectedIndexO = options.firstIndex(where: { $0.asString() == item.type.asString() })
            case is Note:
                selectedIndexO = options.firstIndex(where: { $0.asString() == item.root.note.asString() })
            case is TheoryItemDescriptor:
                selectedIndexO = options.firstIndex(where: { $0.asString() == item.description.asString() })
            default:
                return
            }
            guard let selectedIndex = selectedIndexO else { return }
            tempSelections.append(IndexPath(row: selectedIndex + 1, section: component))
        })
        pickerSelections = tempSelections
    }
    
    @objc func didSave() {
        contentModeService.contentMode = .theory(.progression)
        guard let item = progressionItem else { return }
        if isEditing {
            guard let index = progression.items.firstIndex(where: { $0.guid == item.guid }) else { return }
            progression.items[index] = item
        } else {
            progression.items.insert(item, at: 0)
        }
    }
    
    @objc func didDelete() {
        contentModeService.contentMode = .theory(.progression)
        guard let guid = progressionItem?.guid else {
            return
        }
        progression.items.removeAll(where: { $0.guid == guid })
    }
    
}

extension TheoryItemViewModel: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return ComponentType.all.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // update selection state overall
        var selections = [IndexPath]()
        (0..<pickerView.numberOfComponents).forEach { selections.append(IndexPath(row: pickerView.selectedRow(inComponent: $0), section: $0)) }
        var theoryItemType: MusicTheoryItem!
        var theoryItemDescriptor: TheoryItemDescriptor!
        var rootNoteOctaveO: NoteOctave?
        for selection in selections {
            guard selection.row > 0 else { continue }
            let options = ComponentType.all[selection.section].options(constraint: theoryItemType)
            guard options.count > selection.row - 1 else { continue }
            let option = options[selection.row - 1]
            switch option {
            case is MusicTheoryItem:
                theoryItemType = option as? MusicTheoryItem
                self.itemType = theoryItemType
                pickerView.reloadComponent(2)
            case is Note:
                rootNoteOctaveO = NoteOctave(note: option as! Note, octave: 3)
            case is TheoryItemDescriptor:
                theoryItemDescriptor = option as? TheoryItemDescriptor
            default:
                break
            }
        }
        guard let itemType = theoryItemType,
            let descriptor = theoryItemDescriptor,
            let rootNoteOctave = rootNoteOctaveO else {
                return
        }
        let cachedGuid = progressionItem?.guid ?? ""
        progressionItem = ProgressionItem(type: itemType, description: descriptor, root: rootNoteOctave)
        progressionItem?.guid = "\(cachedGuid)"
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // +1 offset for header 'title'
        let componentType = ComponentType.all[component]
        return componentType.options(constraint: itemType).count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let componentType = ComponentType.all[component]
        if row == 0 {
            return componentType.rawValue
        }
        // -1 offset for static header
        return componentType.options(constraint: itemType)[row - 1].asString()
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
}
