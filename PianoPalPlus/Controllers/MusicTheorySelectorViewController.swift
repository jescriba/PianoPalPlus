//
//  MusicTheorySelectorViewController.swift
//  PianoPalPlus
//
//  Created by joshua on 1/26/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import UIKit

enum MusicTheoryItem: String {
    case chord, scale
}

class MusicTheorySelectorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var tableView: UITableView!
    private let items: [MusicTheoryItem] = [.chord, .scale]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.background
        title = "Music Theory"
        tableView = self.view.addTableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MusicTheoryItem")
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicTheoryItem", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].rawValue
        cell.textLabel?.font = UIFont(name: "Arial", size: 40)
        cell.textLabel?.textAlignment = .center
        let bgView = UIView()
        bgView.backgroundColor = UIColor(named: "sele")
        cell.selectedBackgroundView = bgView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
