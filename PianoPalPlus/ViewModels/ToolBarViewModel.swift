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
    let toolbar: ToolBar
    private let audioEngine: AudioEngine
    private let contentModeService: ContentModeService
    private let playImage = UIImage(systemName: "play")?.withRenderingMode(.alwaysTemplate)
    private let stopImage = UIImage(systemName: "stop")?.withRenderingMode(.alwaysTemplate)
    
    init(toolbar: ToolBar = ToolBar(),
         audioEngine: AudioEngine = AudioEngine.shared,
         contentModeService: ContentModeService = ContentModeService.shared) {
        self.toolbar = toolbar
        self.audioEngine = audioEngine
        self.contentModeService = contentModeService
        super.init()
        setupToolbar()
        setupSubscriptions()
    }
    
    func addButton(_ button: ToolBarButton) {
        toolbar.buttons.insert(button)
    }
    
    func removeButton(_ button: ToolBarButton) {
        toolbar.buttons.remove(button)
    }
    
    private func setupToolbar() {
        // Setup the toolbars per content mode. Notice gear menu button is added by the ContainerViewController
        contentModeService.$contentMode
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] contentMode in
                guard let selfV = self else { return }
                selfV.toolbar.titles = [contentMode.title(), "test", "test2", "tet3"]
                switch contentMode {
                case .freePlay:
                    break
                    //selfV.toolbar.buttons = [] // scroll button, note button on left
                case .earTraining(_), .theory(_):
                    break
                    // same buttons
                    //selfV.toolbar.buttons.append()
                    //selfV.toolbar.buttons = [] // piano button left, play button right
                }
            }).store(in: &cancellables)
        
        // toolbar states
        // free play two states:
        // 1) Notes unlocked
        // - scroll button left, note lock button (locked image) left
        // 2) Note Locked
        // - scroll button left, note lock button (unlocked image) left, sequencer button left, play button right
        
        // ear training two states:
        // 1) selector mode
        // - piano icon button left, play button right
        // 2) piano mode
        // - scroll button left, grid icon selector left, play button right
        
        // progression two states:
        
        // 1) selector mode
        // - piano icon button left, play button right
        // 2) piano mode
        // - scroll button left, grid icon selector left, play button right
    }
    
    private var cancellables = Set<AnyCancellable>()
    private func setupSubscriptions() {
        toolbar.buttons.$changedElements
            .combineLatest(toolbar.$buttons)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { (_, buttons) in
                self.leftButtons = buttons.array.filter({ $0.position == .left })
                    .sorted(by: { $0.priority < $1.priority })
                    .map({ $0.asUIButton() })
                self.rightButtons = buttons.array.filter({ $0.position == .right })
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
        label.textAlignment = .center
        cell.contentView.addFullBoundsSubview(label)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 1.5 * collectionView.bounds.width / 3,
                      height: collectionView.bounds.height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let collectionView = scrollView as? UICollectionView else {
            return
        }
        
        collectionView.visibleCells.forEach({ cell in
//            let collectionCenterX = collectionView.contentSize.width / 2
//            let convertedPoint = collectionView.convert(cell.center, from: cell)
//            let alpha = 1 - 0.8 * abs(convertedPoint.x - collectionCenterX) / collectionCenterX
            
            let alpha: CGFloat = 1
            cell.contentView.subviews.forEach({ label in
                label.alpha = alpha
            })
        })
    }
    
}
