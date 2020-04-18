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
    private let sessionsStore: Store<Sessions>
    private let sessionStore: Store<Session>
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
         sessionsStore: Store<Sessions>,
         sessionStore: Store<Session>) {
        self.contentModeService = contentModeService
        self.sessionsStore = sessionsStore
        self.sessionStore = sessionStore
        self.reload = true
        
        if let existingSession: Session = sessionStore.load(from: .session) {
            self.currentSession = existingSession
        } else {
            let newSession = Session()
            self.currentSession = newSession
            sessionStore.save(newSession, key: .session)
        }
        super.init()
        
        loadSessions()
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        sessionsStore.$change
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.loadSessions()
            }).store(in: &cancellables)
        sessionStore.$change
            .filter({ $0 != nil })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] change in
                guard let selfV = self else { return }
                let currentSession = selfV.currentSession
                
                if change?.change == .some(.removed) {
                    selfV.sessions.removeAll(where: { $0.id == currentSession.id })
                } else if let existingIndex = selfV.sessions.firstIndex(where: { $0.id == currentSession.id }),
                    let newValue = change?.value {
                    selfV.sessions[existingIndex] = newValue
                } else {
                    selfV.sessions.append(currentSession)
                }
                selfV.sessionsStore.save(selfV.sessions, key: .sessions)
            }).store(in: &cancellables)
    }
    
    func loadSessions() {
        self.sessions = sessionsStore.load(from: .sessions) ?? [Session]()
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
            sessionsStore.save(sessions, key: .sessions)
            currentSession = Session()
            sessionStore.save(currentSession, key: .session)
            contentModeService.contentMode = .theory(.editor(nil))
            return
        }
        
        currentSession = sessions[indexPath.row - 1]
        sessionStore.save(currentSession, key: .session)
        contentModeService.contentMode = .theory(.sessionDetail)
    }
    
    func add(_ session: Session) {
        currentSession = session
        sessionStore.save(currentSession, key: .session)
    }

}
