//
//  ToolBarView.swift
//  PianoPalPlus
//
//  Created by joshua on 1/20/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import UIKit
import Combine

class ToolBarView: UIView {
    weak var viewModel: ToolBarViewModel? {
        didSet {
            bindViewModel()
        }
    }
    private let titlesCollectionView = UICollectionView(frame: .zero,
                                                        collectionViewLayout: UICollectionViewFlowLayout())
    private var titlesWidth: CGFloat {
        return self.frame.width / 3.0
    }
    private let leftHStack = UIStackView()
    private let rightHStack = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.backgroundColor = UIColor.toolbar
        
        // setup titles collection view
        titlesCollectionView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(titlesCollectionView)
        NSLayoutConstraint.activate([
            titlesCollectionView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titlesCollectionView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            titlesCollectionView.heightAnchor.constraint(equalTo: self.heightAnchor),
            titlesCollectionView.widthAnchor.constraint(equalToConstant: titlesWidth)
        ])
        titlesCollectionView.backgroundColor = .toolbar
        titlesCollectionView.showsHorizontalScrollIndicator = false
        (titlesCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).scrollDirection = .horizontal
        
        // setup left horizontal stack
        leftHStack.translatesAutoresizingMaskIntoConstraints = false
        leftHStack.axis = .horizontal
        leftHStack.distribution = .fillEqually
        leftHStack.alignment = .center
        self.addSubview(leftHStack)
        NSLayoutConstraint.activate([
            leftHStack.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            leftHStack.rightAnchor.constraint(equalTo: self.titlesCollectionView.leftAnchor, constant: -10),
            leftHStack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            leftHStack.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -10)
        ])
        
        // setup right horizontal stack
        rightHStack.translatesAutoresizingMaskIntoConstraints = false
        rightHStack.axis = .horizontal
        rightHStack.distribution = .fillEqually
        rightHStack.alignment = .center
        self.addSubview(rightHStack)
        NSLayoutConstraint.activate([
            rightHStack.leftAnchor.constraint(equalTo: self.titlesCollectionView.rightAnchor, constant: 10),
            rightHStack.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            rightHStack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            rightHStack.heightAnchor.constraint(equalTo: self.heightAnchor, constant: -10)
        ])
    }
    
    private var cancellables = Set<AnyCancellable>()
    private func bindViewModel() {
        viewModel?.register(collectionView: titlesCollectionView)
        viewModel?.$leftButtons
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { buttons in
                self.leftHStack.arrangedSubviews.forEach({ $0.removeFromSuperview() })
                buttons.forEach({
                    self.leftHStack.addArrangedSubview($0)
                    $0.heightAnchor.constraint(equalTo: self.leftHStack.heightAnchor).isActive = true
                })
            }).store(in: &cancellables)
        viewModel?.$rightButtons
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { buttons in
                self.rightHStack.arrangedSubviews.forEach({ $0.removeFromSuperview() })
                buttons.forEach({
                    self.rightHStack.addArrangedSubview($0)
                    $0.heightAnchor.constraint(equalTo: self.rightHStack.heightAnchor).isActive = true
                })
            }).store(in: &cancellables)
        viewModel?.$reloadCollectionView
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { _ in
                self.titlesCollectionView.reloadData()
            }).store(in: &cancellables)
        viewModel?.$selectedTitleIndex
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { index in
                self.titlesCollectionView.scrollToItem(at: IndexPath(row: index, section: 0),
                                                       at: .left,
                                                       animated: true)
            }).store(in: &cancellables)
    }
}
