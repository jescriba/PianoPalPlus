//
//  ToolBarViewModel.swift
//  PianoPalPlus
//
//  Created by joshua on 1/30/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import UIKit
import Combine

class ToolBarViewModel: NSObject {
    @Published var leftButtons = [UIButton]()
    @Published var rightButtons = [UIButton]()
    @Published var reloadCollectionView: Bool = false
    @Published var selectedTitleIndex: Int = 0
    let toolbar: ToolBar
    private let contentModeService: ContentModeService
    
    init(toolbar: ToolBar = ToolBar(),
         contentModeService: ContentModeService = ContentModeService.shared) {
        self.toolbar = toolbar
        self.contentModeService = contentModeService
        super.init()
        setupToolbar()
        setupSubscriptions()
    }
    
    func selectTitle(at index: Int) {
        guard toolbar.titles.count > index && index >= 0 else {
            return
        }
        
        selectedTitleIndex = index
    }
    
    func setTitles(_ titles: [String]) {
        toolbar.titles = titles
    }
    
    func addButton(_ button: ToolBarButton) {
        toolbar.buttons.insert(button)
    }
    
    func addButton(_ button: ToolBarButton, replace: Bool) {
        toolbar.buttons.insert(button, replace: replace)
    }
    
    func replaceButton(_ button: ToolBarButton) {
        guard toolbar.buttons.array.contains(where: { $0.id == button.id }) else { return }
        addButton(button, replace: true)
    }
    
    func removeButton(_ button: ToolBarButton) {
        toolbar.buttons.remove(button)
    }
    
    func remove(buttonId: ToolBarId) {
        toolbar.remove(buttonId)
    }
    
    private func setupToolbar() {
        contentModeService.$contentMode
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] contentMode in
                guard let selfV = self else { return }
                selfV.toolbar.titles = [contentMode.title()]
            }).store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    private func setupSubscriptions() {
        toolbar.buttons.$observableArray
            .receive(on: DispatchQueue.main)
            .debounce(for: 0.1, scheduler: DispatchQueue.main)
            .sink(receiveValue: { buttons in
                self.leftButtons = buttons.filter({ $0.position == .left })
                    .sorted(by: { $0.priority < $1.priority })
                    .map({ $0.asUIButton() })
                self.rightButtons = buttons.filter({ $0.position == .right })
                    .sorted(by: { $0.priority < $1.priority })
                    .map({ $0.asUIButton() })
            }).store(in: &cancellables)
        toolbar.$titles
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] titles in
                self?.reloadCollectionView = true
            }).store(in: &cancellables)
    }
    
    func register(collectionView: UICollectionView) {
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "TitleCell")
        collectionView.dataSource = self
        collectionView.delegate = self
    }
}

extension ToolBarViewModel: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return toolbar.titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TitleCell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        let label = UILabel(frame: .zero)
        label.text = toolbar.titles[indexPath.row]
        label.textAlignment = .left
        cell.contentView.addFullBoundsSubview(label)
        let alpha = 1 - (cell.frame.minX - collectionView.contentOffset.x) / collectionView.frame.width
        label.alpha = alpha
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == toolbar.titles.count - 1 {
            return CGSize(width: collectionView.bounds.width,
                          height: collectionView.bounds.height)
        }
        return CGSize(width: collectionView.bounds.width / 2.5,
                      height: collectionView.bounds.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView else {
            return
        }
        
        let indexPath = closestIndexPath(for: collectionView)
        selectedTitleIndex = indexPath.row
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let collectionView = scrollView as? UICollectionView, decelerate == false else {
            return
        }
        
        let indexPath = closestIndexPath(for: collectionView)
        selectedTitleIndex = indexPath.row
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView else {
            return
        }
        
        collectionView.indexPathsForVisibleItems.forEach({ indexPath in
            guard let cell = collectionView.cellForItem(at: indexPath) else { return }
            let alpha = 1 - (cell.frame.minX - collectionView.contentOffset.x) / collectionView.frame.width
            cell.contentView.subviews.forEach({ label in
                label.alpha = alpha
            })
        })
    }
    
    func closestIndexPath(for collectionView: UICollectionView) -> IndexPath  {
        var newSelectionIndex: Int = 0
        var previousAlpha: CGFloat = 0
        collectionView.indexPathsForVisibleItems.forEach({ indexPath in
            guard let cell = collectionView.cellForItem(at: indexPath) else { return }
            let alpha = 1 - (cell.frame.minX - collectionView.contentOffset.x) / collectionView.frame.width
            if alpha > previousAlpha {
                newSelectionIndex = indexPath.row
                previousAlpha = alpha
            }
        })
        return IndexPath(row: newSelectionIndex, section: 0)
    }
    
}
