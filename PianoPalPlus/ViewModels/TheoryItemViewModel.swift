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
    var progression: Progression
    var progressionItem: ProgressionItem?
    
    enum ComponentTypes: String {
        case item, root, quality, alterations
        
        func options() -> [Stringable] {
            switch self {
            case .item:
                return MusicTheoryItem.all
            case .root:
                return Notes.all
            case .quality:
                return ChordType.all
            default:
                return ["-"]
            }
        }
        
        static var all: [ComponentTypes] { return [.item, .root, .quality, .alterations] }
    }
    
    init(contentModeService: ContentModeService = .shared, progression: Progression) {
        self.contentModeService = contentModeService
        self.progression = progression
    }
    
    @objc func didSave() {
        contentModeService.contentMode = .theory(.progression)
        guard let item = progressionItem else { return }
        progression.items.insert(item, at: 0)
        
    }
    
    @objc func didDelete() {
        contentModeService.contentMode = .theory(.progression)
    }
    
}

extension TheoryItemViewModel: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return ComponentTypes.all.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // update selection state overall
        var selections = [IndexPath]()
        (0..<pickerView.numberOfComponents).forEach { selections.append(IndexPath(row: pickerView.selectedRow(inComponent: $0), section: $0)) }
        var theoryItemType: MusicTheoryItem!
        var theoryItemDescriptor: TheoryItemDescriptor!
        var noteOctaves = [NoteOctave]()
        for selection in selections {
            guard selection.row > 0 else { continue }
            let option = ComponentTypes.all[selection.section].options()[selection.row - 1]
            switch option {
            case is MusicTheoryItem:
                theoryItemType = option as? MusicTheoryItem
            case is Note:
                noteOctaves.append(NoteOctave(note: option as! Note, octave: 3))
            case is TheoryItemDescriptor:
                theoryItemDescriptor = option as? TheoryItemDescriptor
            default:
                break
            }
        }
        guard let itemType = theoryItemType, let descriptor = theoryItemDescriptor else { return }
        progressionItem = ProgressionItem(type: itemType, description: descriptor, items: noteOctaves)
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // +1 offset for header 'title'
        return ComponentTypes.all[component].options().count + 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return ComponentTypes.all[component].rawValue
        }
        // -1 offset for static header
        return ComponentTypes.all[component].options()[row - 1].asString()
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
}
