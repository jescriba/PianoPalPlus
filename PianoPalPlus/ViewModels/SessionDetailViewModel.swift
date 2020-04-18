//
//  SessionDetailViewModel.swift
//  PianoPalPlus
//
//  Created by joshua on 4/16/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import UIKit
import Combine

class SessionDetailViewModel: NSObject, UITextFieldDelegate {
    @Published var session: Session?
    @Published var edit: Bool = false
    private let sessionsStore: Store<Sessions>
    private let sessionStore: Store<Session>
    private let contentModeService: ContentModeService
    
    private var cancellables = Set<AnyCancellable>()
    init(sessionsStore: Store<Sessions>,
         sessionStore: Store<Session>,
         contentModeService: ContentModeService = .shared) {
        self.sessionsStore = sessionsStore
        self.sessionStore = sessionStore
        self.contentModeService = contentModeService
        self.session = sessionStore.load(from: .session)
        super.init()
        
        contentModeService.$contentMode
            .filter({ $0 != .theory(.sessionDetail) })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] _ in
                self?.edit = false
            }).store(in: &cancellables)
        sessionStore.$change
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] change in
                guard let newValue = change?.value else { return }
                self?.session = newValue
            }).store(in: &cancellables)
    }
    
    
    func didDelete() {
        // refactor into the store
        DispatchQueue.global().async {
            guard var sessions: Sessions = self.sessionsStore.load(from: .sessions), let session = self.session else {
                return
            }
            sessions.removeAll(where: { $0.id == session.id })
            self.sessionsStore.save(sessions, key: .sessions)
        }
        contentModeService.contentMode = .theory(.library(nil))
    }
    
    func didEdit() {
        edit = true
    }
    
    func didView() {
        contentModeService.contentMode = .theory(.progression(nil))
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        edit = false
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        guard var updatedSession = self.session else { return }
        updatedSession.title = textField.text ?? session?.title ?? "-"
        self.session = updatedSession
        sessionStore.save(updatedSession, key: .session)
    }
    
}
