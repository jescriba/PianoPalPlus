//
//  NavigationViewController.swift
//  PianoPalPlus
//
//  Created by joshua on 1/26/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import UIKit

enum NavigationItem: String {
    case settings, earTraining, theory, identification
    
    func asTitle() -> String {
        switch self {
        case .settings:
            return rawValue
        case .earTraining:
            return "practice ear training"
        case .theory:
            return "study chords/scales"
        default:
            return rawValue
        }
    }
}

class NavigationTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView()
    private let items: [NavigationItem] = [.settings, .earTraining, .theory]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.indexPathsForSelectedRows?.forEach({ tableView.deselectRow(at: $0, animated: true) })
    }
    
    private func setup() {
        navigationController?.navigationBar.topItem?.title = "Configure"

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.showsVerticalScrollIndicator = false
        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            tableView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            tableView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            tableView.heightAnchor.constraint(equalTo: self.view.heightAnchor)
        ])
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "NavigationItem")
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NavigationItem", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].asTitle()
        cell.textLabel?.font = UIFont(name: "Arial", size: 40)
        cell.textLabel?.textAlignment = .center
        let bgView = UIView()
        bgView.backgroundColor = Colors.highlightedWhiteKey
        cell.selectedBackgroundView = bgView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch items[indexPath.row] {
        case .settings:
            navigationController?.pushViewController(SettingsViewController(), animated: true)
        case .earTraining:
            navigationController?.pushViewController(EarTrainingViewController(), animated: true)
        case .theory:
            navigationController?.pushViewController(MusicTheoryViewController(), animated: true)
        default:
            break
        }
    }
}

class NavigationViewController: UIViewController, UIGestureRecognizerDelegate {
    private let _navigationVC = UINavigationController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        addBlurView()
        
        addChild(_navigationVC)
        _navigationVC.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(_navigationVC.view)
        NSLayoutConstraint.activate([
            _navigationVC.view.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            _navigationVC.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            _navigationVC.view.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.75),
            _navigationVC.view.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.75)
        ])
        _navigationVC.setViewControllers([NavigationTableViewController()], animated: false)
    }
    
    func addBlurView() {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapDismiss(_:)))
        tapGesture.delegate = self
        blurView.addGestureRecognizer(tapGesture)
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return gestureRecognizer.view == touch.view
    }
    
    @objc func tapDismiss(_ recognizer: UITapGestureRecognizer) {
        self.dismiss(animated: false, completion: nil)
    }

}
