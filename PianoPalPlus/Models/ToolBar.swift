//
//  ToolBar.swift
//  PianoPalPlus
//
//  Created by joshua on 1/30/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import Combine
import UIKit

class ToolBar {
    @Published var titles = [String]()
    @Published var buttons = ObservableUniqueArray<ToolBarButton>()
    
    init(titles: [String] = ["Piano Pal"], buttons: [ToolBarButton] = [ToolBarButton]()) {
        self.titles = titles
        buttons.forEach({ self.buttons.insert($0) })
    }
    
    func insert(_ button: ToolBarButton) {
        buttons.insert(button)
    }
    
    func insert(_ button: ToolBarButton, replace: Bool) {
        buttons.insert(button, replace: replace)
    }
    
    func remove(_ button: ToolBarButton) {
        buttons.remove(button)
    }
    
    func remove(_ id: ToolBarId) {
        guard let button = buttons.array.first(where: { $0.id == id }) else { return }
        buttons.remove(button)
    }
}

enum ToolBarPosition {
    case left, right
}

class ToolBarButton: Hashable {
    static func == (lhs: ToolBarButton, rhs: ToolBarButton) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
    
    var id: ToolBarId
    var priority: Int // used for ordering position
    var active: Bool = false
    var position: ToolBarPosition
    var image: UIImage?
    var activeImage: UIImage?
    var color: UIColor = .imageTint
    var activeColor: UIColor = .imageSelectedTint
    var action: (() -> Void)
    
    init(id: ToolBarId,
         priority: Int,
         active: Bool = false,
         position: ToolBarPosition,
         image: UIImage? = nil,
         activeImage: UIImage? = nil,
         color: UIColor = .imageTint,
         activeColor: UIColor = .imageSelectedTint,
         action: @escaping (() -> Void)) {
        self.id = id
        self.priority = priority
        self.active = active
        self.position = position
        self.image = image
        if let i = image, activeImage == nil {
            self.activeImage = i
        } else {
            self.activeImage = activeImage
        }
        self.color = color
        self.activeColor = activeColor
        self.action = action
    }
    
    func asUIButton() -> UIButton {
        let btn = UIButton(frame: .zero)
        btn.translatesAutoresizingMaskIntoConstraints = false
        let currentImage = active ? activeImage : image
        let currentColor = active ? activeColor : color
        let templateImage = currentImage?.withRenderingMode(.alwaysTemplate)
        btn.setImage(templateImage?.withTintColor(currentColor), for: .normal)
        btn.tintColor = currentColor
        btn.tag = id.rawValue
        btn.actionHandler(for: .touchUpInside, { [weak self] in
            guard let selfV = self else { return }
            selfV.active = !selfV.active
            if selfV.active {
                let templateImage = selfV.activeImage?.withRenderingMode(.alwaysTemplate)
                btn.setImage(templateImage?.withTintColor(selfV.activeColor), for: .normal)
                btn.tintColor = selfV.activeColor
            } else {
                let templateImage = selfV.image?.withRenderingMode(.alwaysTemplate)
                btn.setImage(templateImage?.withTintColor(selfV.color), for: .normal)
                btn.tintColor = selfV.color
            }
            selfV.action()
        })
        return btn
    }
}

enum ToolBarId: Int {
    case settings
    case noteLock
    case sequenceLock
    case scrollLock
    case noteLockPlay
    case earTrainingPlay
    case progressionPlay
    case pianoToggle
    case sessionsToggle
    case shareProgression
}
