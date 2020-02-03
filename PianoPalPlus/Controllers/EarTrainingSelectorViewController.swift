//
//  EarTrainingViewController.swift
//  PianoPalPlus
//
//  Created by joshua on 1/26/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import UIKit

enum EarTrainingItem: String {
    case interval, melody, chordType, chordProgression, key
    
    func title() -> String {
        switch self {
        case .chordProgression:
            return "chord progression"
        case .chordType:
            return "chord type"
        default:
            return self.rawValue
        }
    }
    
    func description() -> String? {
        switch self {
        case .interval:
            return "listen and select the interval played. You can use the piano for reference."
        case .melody:
            return "match the melody"
        case .key:
            return "listen to the music and detect the key. You can use the piano for reference."
        default:
            return nil
        }
    }
}


class EarTrainingSelectorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var tableView: UITableView!
    private let items: [EarTrainingItem] = [.interval, .melody, .key]
    private let contentModeService: ContentModeService
    
    init(contentModeService: ContentModeService = ContentModeService.shared) {
        self.contentModeService = contentModeService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Ear Training"
        tableView = self.view.addTableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "EarTrainingItem")
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EarTrainingItem", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].title()
        cell.textLabel?.font = UIFont(name: "Arial", size: 40)
        cell.textLabel?.textAlignment = .center
        let bgView = UIView()
        bgView.backgroundColor = Colors.highlightedWhiteKey
        cell.selectedBackgroundView = bgView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        contentModeService.contentMode = .earTraining(items[indexPath.row])
        dismiss(animated: false, completion: nil)
    }
}
