//
//  SessionsViewModel.swift
//  PianoPalPlus
//
//  Created by joshua on 4/13/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import UIKit
import Combine

class SessionsViewModel: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private let contentModeService: ContentModeService
    private let store: Store
    private var sessions = [Session]()
    var currentSession: Session
    @Published var reload: Bool = false
    @Published var highlightedIndexPath: IndexPath?
    
    private var cancellables = Set<AnyCancellable>()
    init(contentModeService: ContentModeService = .shared,
         progression: Progression,
         store: Store = .shared) {
        self.contentModeService = contentModeService
        self.store = store
        self.reload = true
        self.currentSession = Session(id: UUID().uuidString,
                                      title: String.todaysDate(),
                                      progression: progression)
        super.init()
        
        loadSessions()
    }
    
    func loadSessions() {
        self.sessions = store.load(from: .sessions) ?? [Session]()
        sessions.append(currentSession)
        store.save(sessions, key: .sessions)
    }
    
    func register(collectionView: UICollectionView) {
        collectionView.register(CardViewCell.self, forCellWithReuseIdentifier: "SessionCell")
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.clipsToBounds = false
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sessions.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SessionCell", for: indexPath) as? CardViewCell else {
            return UICollectionViewCell()
        }
        if indexPath.row == 0 {
            let vm = CardViewModel()
            vm.image = UIImage(systemName: "plus")
            cell.viewModel = vm
            return cell
        }
        let vm = CardViewModel()
        let session = sessions[indexPath.row - 1]
        vm.title = session.title
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
            // create a new progression from scratch
            currentSession.progression.items.removeAll()
            currentSession.progression.currentItem = nil
            currentSession.id = UUID().uuidString
            currentSession.title = String.todaysDate()
            store.save(sessions, key: .sessions)
            contentModeService.contentMode = .theory(.progression(nil))
            return
        }
        
        let session = sessions[indexPath.row - 1]
        contentModeService.contentMode = .theory(.progression(session))
    }
    
    func add(_ session: Session) {
        sessions.append(session)
        store.save(sessions, key: .sessions)
    }

}
