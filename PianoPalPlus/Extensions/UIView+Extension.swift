//
//  UIView+Extension.swift
//  PianoPalPlus
//
//  Created by joshua on 3/6/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func addTableView() -> UITableView {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsVerticalScrollIndicator = false
        self.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            tableView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            tableView.widthAnchor.constraint(equalTo: self.widthAnchor),
            tableView.heightAnchor.constraint(equalTo: self.heightAnchor)
        ])
        return tableView
    }
}
