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
    private var sessions = [Session]() {
        didSet {
            reload = true
        }
    }
    @Published var currentSession: Session
    @Published var reload: Bool = false
    @Published var highlightedIndexPath: IndexPath?
    
    private var cancellables = Set<AnyCancellable>()
    init(contentModeService: ContentModeService = .shared,
         store: Store = .shared) {
        self.contentModeService = contentModeService
        self.store = store
        self.reload = true
        
        var saveCurrentSession: Bool = false
        if let existingSession: Session = store.load(from: .session) {
            self.currentSession = existingSession
        } else {
            let newSession = Session()
            self.currentSession = newSession
            store.save(newSession, key: .session)
            saveCurrentSession = true
        }
        super.init()
        
        loadSessions(saveCurrent: saveCurrentSession)
    }
    
    func loadSessions(saveCurrent: Bool = false) {
        self.sessions = store.load(from: .sessions) ?? [Session]()
        if saveCurrent {
            self.sessions.append(self.currentSession)
            store.save(sessions, key: .sessions)
        }
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
            // save current session to list before creating a new one
            // refactor - will likely be performance issue once this grows + locking the save
            store.save(sessions, key: .sessions)
            currentSession = Session()
            store.save(currentSession, key: .session)
            sessions.append(currentSession)
            store.save(sessions, key: .sessions)
            contentModeService.contentMode = .theory(.progression(nil))
            return
        }
        
        currentSession = sessions[indexPath.row - 1]
        contentModeService.contentMode = .theory(.progression(nil))
    }
    
    func add(_ session: Session) {
        sessions.append(session)
        store.save(sessions, key: .sessions)
        currentSession = session
        store.save(currentSession, key: .session)
    }

}
