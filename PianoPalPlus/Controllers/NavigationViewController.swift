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
    case settings, freeplay, earTraining, theory, identification
    
    func title() -> String {
        switch self {
        case .settings:
            return rawValue
        case .freeplay:
            return "free play"
        case .earTraining:
            return "practice ear training"
        case .theory:
            return "study chords/scales"
        default:
            return rawValue
        }
    }
}

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

class NavigationTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var tableView: UITableView!
    // todo add the theory mode
    private let items: [NavigationItem] = [.freeplay, .earTraining]
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
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.indexPathsForSelectedRows?.forEach({ tableView.deselectRow(at: $0, animated: true) })
    }
    
    private func setup() {
        navigationController?.navigationBar.topItem?.title = "Configure"
        navigationController?.navigationBar.tintColor = UIColor.text
        
        tableView = self.view.addTableView()
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
        cell.textLabel?.text = items[indexPath.row].title()
        cell.textLabel?.font = UIFont(name: "Arial", size: 40)
        cell.textLabel?.textAlignment = .center
        let bgView = UIView()
        bgView.backgroundColor = UIColor.selection
        cell.selectedBackgroundView = bgView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch items[indexPath.row] {
        case .settings:
            navigationController?.pushViewController(SettingsViewController(), animated: true)
        case .earTraining:
            navigationController?.pushViewController(EarTrainingSelectorViewController(contentModeService: contentModeService), animated: true)
        case .theory:
            navigationController?.pushViewController(MusicTheorySelectorViewController(), animated: true)
        case .freeplay:
            contentModeService.contentMode = .freePlay
            dismiss(animated: false, completion: nil)
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
