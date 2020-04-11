//
//  UIButton+Extension.swift
//  PianoPalPlus
//
//  Created by joshua on 4/10/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import UIKit

// lifted from: https://stackoverflow.com/questions/25919472/adding-a-closure-as-target-to-a-uibutton

class ClosureSleeve {
    let closure: ()->()

    init (_ closure: @escaping ()->()) {
        self.closure = closure
    }

    @objc func invoke () {
        closure()
    }
}

extension UIControl {
    func actionHandler(for controlEvents: UIControl.Event, _ closure: @escaping ()->()) {
        let sleeve = ClosureSleeve(closure)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
        objc_setAssociatedObject(self, String(ObjectIdentifier(self).hashValue) + String(controlEvents.rawValue), sleeve,
                             objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}
