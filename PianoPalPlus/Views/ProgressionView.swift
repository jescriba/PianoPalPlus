//
//  ProgressionView.swift
//  PianoPalPlus
//
//  Created by joshua on 3/8/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import UIKit
import Combine

class ProgressionView: UIView {
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    weak var viewModel: ProgressionViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    init(viewModel: ProgressionViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        configureUI()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }
    
    private func configureUI() {
        backgroundColor = .background
        collectionView.backgroundColor = .clear
        collectionView.dragInteractionEnabled = true
        collectionView.clipsToBounds = true
        clipsToBounds = true
        addFullBoundsSubview(collectionView, horizontalSpacing: 50, verticalSpacing: 10)
    }
    
    private var cancellables = Set<AnyCancellable>()
    private func bindViewModel() {
        viewModel?.$reload
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.collectionView.reloadData()
            }).store(in: &cancellables)
        if let vm = viewModel {
            collectionView.delegate = vm
            collectionView.dataSource = vm
            collectionView.dragDelegate = vm
            vm.register(collectionView: collectionView)
        }
        viewModel?.$highlightedIndexPath
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] indexPathO in
                guard let indexPath = indexPathO,
                    let item = self?.collectionView.cellForItem(at: indexPath) else {
                        return
                }
                self?.collectionView.visibleCells.forEach({ cell in
                    if cell != item {
                        cell.backgroundColor = .cellBackground
                    } else {
                        cell.backgroundColor = .selection
                    }
                })
            }).store(in: &cancellables)
    }
}
