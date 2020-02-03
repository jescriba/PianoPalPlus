//
//  GameViewController.swift
//  PianoPalPlus
//
//  Created by joshua on 1/30/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import UIKit
import Combine

class Selection {
    var title: String?

    init(title: String) {
        self.title = title
    }
}

class GameViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private let contentModeService: ContentModeService
    // hack for now.. yes card view could have its own proper view + vm
    private let cardHeight: CGFloat = 150
    private let cardWidth: CGFloat = 400
    let cardView = UIView()
    let cardLabel = UILabel()
    private let selectionCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let selectionItems: [Selection] = [Selection(title: "A"), Selection(title: "Minor Second"), Selection(title: "Major Second"), Selection(title: "A"), Selection(title: "Minor Second"), Selection(title: "Major Second"), Selection(title: "A"), Selection(title: "Minor Second"), Selection(title: "Major Second")]
    
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
        setupCard()
        setupSelectionCollectionView()
        setupSubscriptions()
    }
    
    private var cancellables = Set<AnyCancellable>()
    private func setupSubscriptions() {
        contentModeService.$contentMode
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] contentMode in
                self?.cardLabel.text = contentMode.description()
            }).store(in: &cancellables)
    }
    
    private func setupCard() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .systemBackground
        cardView.layer.borderColor = UIColor.gray.cgColor
        cardView.layer.borderWidth = 3
        cardLabel.textAlignment = .center
        cardLabel.numberOfLines = 0
        cardLabel.text = "welcome to the game zone"
        cardView.addFullBoundsSubview(cardLabel)
        view.addSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.heightAnchor.constraint(equalToConstant: cardHeight),
            cardView.widthAnchor.constraint(equalToConstant: cardWidth),
        ])
        cardView.layer.shadowColor = UIColor.gray.cgColor
        cardView.layer.shadowRadius = 3
        cardView.layer.cornerRadius = 5
        view.layoutIfNeeded()
        // hack
        hideCardView()
    }
    
    private func showCardView() {
        UIView.animate(withDuration: 4, delay: 0, options: [.curveEaseIn], animations: {
            self.cardView.alpha = 1
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func hideCardView() {
        UIView.animate(withDuration: 4, delay: 0, options: [.curveEaseIn], animations: {
            self.cardView.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func setupSelectionCollectionView() {
        selectionCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "SelectionCell")
        selectionCollectionView.delegate = self
        selectionCollectionView.dataSource = self
        view.addFullBoundsSubview(selectionCollectionView)
        view.sendSubviewToBack(selectionCollectionView)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectionItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectionCell", for: indexPath)
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.borderWidth = 2
        cell.layer.cornerRadius = 5
        let label = UILabel()
        label.text = selectionItems[indexPath.row].title
        cell.addFullBoundsSubview(label)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 200)
    }

}
