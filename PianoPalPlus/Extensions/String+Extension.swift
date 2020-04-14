//
//  String+Extension.swift
//  PianoPalPlus
//
//  Created by joshua on 4/13/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation

extension String {
    static func todaysDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
         
        let date = Date()
        return dateFormatter.string(from: date)
    }
}
