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

class GameViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private let contentModeService: ContentModeService
    private let gameEngine: GameEngine
    private let selectionCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private let cardHeight: CGFloat = 150
    private let cardWidth: CGFloat = 400
    private let cardView = CardView()
    private let cardBackgroundView = UIView()
    private let cardViewModel = CardViewModel()
    
    init(contentModeService: ContentModeService = ContentModeService.shared,
         gameEngine: GameEngine = GameEngine.shared) {
        self.contentModeService = contentModeService
        self.gameEngine = gameEngine
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupSubscriptions()
        setupSelectionCollectionView()
        setupCardView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showCardView()
    }
    
    private var cancellables = Set<AnyCancellable>()
    private func setupSubscriptions() {
        contentModeService.$contentMode
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] contentMode in
                self?.cardViewModel.title = contentMode.description() ?? ""
                self?.showCardView()
            }).store(in: &cancellables)
        gameEngine.$selectionItems
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.selectionCollectionView.reloadData()
            }).store(in: &cancellables)
    }
    
    private func setupCardView() {
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .systemBackground
        cardView.layer.borderColor = UIColor.gray.cgColor
        cardView.layer.borderWidth = 3
        cardView.layer.cornerRadius = 10
        cardView.viewModel = cardViewModel
        view.addSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.heightAnchor.constraint(equalToConstant: cardHeight),
            cardView.widthAnchor.constraint(equalToConstant: cardWidth),
        ])
        cardBackgroundView.backgroundColor = .clear
        cardBackgroundView.alpha = 0.8
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        effectView.backgroundColor = .clear
        cardBackgroundView.addFullBoundsSubview(effectView)
        cardView.alpha = 0
    }
    
    private func showCardView() {
        view.addFullBoundsSubview(cardBackgroundView)
        view.layoutIfNeeded()
        view.bringSubviewToFront(cardView)
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: {
            self.cardView.alpha = 1
            self.view.layoutIfNeeded()
        }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: { [weak self] in
                self?.hideCardView()
            })
        })
    }

    private func hideCardView() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: {
            self.cardView.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.cardBackgroundView.removeFromSuperview()
        })
    }
    
    private func setupSelectionCollectionView() {
        selectionCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "SelectionCell")
        selectionCollectionView.delegate = self
        selectionCollectionView.dataSource = self
        selectionCollectionView.backgroundColor = .clear
        selectionCollectionView.showsVerticalScrollIndicator = false
        view.addFullBoundsSubview(selectionCollectionView, horizontalSpacing: 50, verticalSpacing: 10)
        view.sendSubviewToBack(selectionCollectionView)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameEngine.selectionItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SelectionCell", for: indexPath)
        cell.subviews.forEach({ $0.removeFromSuperview() }) // hack clean up reused cell 
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.layer.borderWidth = 2
        cell.layer.cornerRadius = 5
        let label = UILabel()
        label.numberOfLines = 0
        label.text = gameEngine.selectionItems[indexPath.row].title
        label.textAlignment = .center
        cell.addFullBoundsSubview(label)
        let bgView = UIView()
        bgView.backgroundColor = Colors.highlightedWhiteKey
        bgView.layer.cornerRadius = 5
        cell.selectedBackgroundView = bgView
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = 2 * collectionView.frame.size.width / CGFloat(gameEngine.selectionItems.count)
        return CGSize(width: width, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        gameEngine.submit(index: indexPath.row, completion: { [weak self] (isCorrect, correctAnswer)  in
            if isCorrect {
                self?.cardViewModel.title = "Correct!!"
            } else {
                var incorrectString = "Incorrect :("
                if let answerString = correctAnswer?.title {
                    incorrectString += "\n" + "correct answer is: \(answerString)"
                }
                self?.cardViewModel.title = incorrectString
            }
            self?.showCardView()
            self?.gameEngine.next()
        })
    }
    
    func togglePlayActive() {
        gameEngine.togglePlayState()
    }
}
