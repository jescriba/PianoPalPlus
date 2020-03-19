//
//  ProgressionViewModel.swift
//  PianoPalPlus
//
//  Created by joshua on 2/20/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import UIKit
import Combine

class ProgressionViewModel: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private let contentModeService: ContentModeService
    private let audioEngine: AudioEngine
    private let store: ProgressionStore
    var progression: Progression
    @Published var reload: Bool = false
    @Published var highlightedIndexPath: IndexPath?
    
    private var cancellables = Set<AnyCancellable>()
    init(contentModeService: ContentModeService = .shared,
         audioEngine: AudioEngine = .shared,
         progression: Progression,
         store: ProgressionStore = .shared) {
        self.contentModeService = contentModeService
        self.audioEngine = audioEngine
        self.progression = progression
        self.store = store
        self.reload = true
        super.init()
        
        progression.$items
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.reload = true
                self?.store.save(progression)
            }).store(in: &cancellables)
        audioEngine.$playData
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] playableData in
                let guid = playableData?.guid
                self?.progression.currentItem = progression.items.first(where: { $0.guid == guid })
            }).store(in: &cancellables)
        progression.$currentItem
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] currentItem in
                guard let row = self?.progression.items.firstIndex(where: { $0.guid == currentItem?.guid })
                    else {
                        return
                }
                
                // annoying +1 for addition cell
                self?.highlightedIndexPath = IndexPath(row: row + 1, section: 0)
            }).store(in: &cancellables)
    }
    
    func register(collectionView: UICollectionView) {
        collectionView.register(CardViewCell.self, forCellWithReuseIdentifier: "CardViewCell")
        collectionView.delegate = self
        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.clipsToBounds = false
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return progression.items.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardViewCell", for: indexPath) as? CardViewCell else {
            return UICollectionViewCell()
        }
        if indexPath.row == 0 {
            let vm = CardViewModel()
            vm.image = UIImage(systemName: "plus")
            cell.viewModel = vm
            return cell
        }
        let vm = CardViewModel()
        let progressionItem = progression.items[indexPath.row - 1]
        progressionItem.guid = "progressionItem-\(indexPath.row - 1)"
        vm.title = progressionItem.title
        cell.viewModel = vm
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 5.0, height: 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row > 0 else {
            // Go to add theory item view
            contentModeService.contentMode = .theory(.editor(nil))
            return
        }
        
        // go to edit existing item
        let progressionItem = progression.items[indexPath.row - 1]
        contentModeService.contentMode = .theory(.editor(progressionItem))
    }

}

extension ProgressionViewModel: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard indexPath.row > 0 else { return [UIDragItem]() } // dont move the plus cell
        let provider = NSItemProvider()
        let dragItem = UIDragItem(itemProvider: provider)
        return [dragItem]
    }
}


extension ProgressionViewModel: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let dropItem = coordinator.items.first,
            let sourceIndexPath = dropItem.sourceIndexPath,
            let destinationIndexPath = coordinator.destinationIndexPath,
            destinationIndexPath.row > 0 else { return }
        collectionView.performBatchUpdates({
            let item = progression.items[sourceIndexPath.row - 1]
            progression.items.remove(at: sourceIndexPath.row - 1)
            progression.items.insert(item, at: destinationIndexPath.row - 1)
            collectionView.deleteItems(at: [sourceIndexPath])
            collectionView.insertItems(at: [destinationIndexPath])
            progression.updateGuids() // ensure guids update to latest state for editing
        }, completion: { _ in
            coordinator.drop(dropItem.dragItem,
                             toItemAt: destinationIndexPath)
        })
    }
    
}
