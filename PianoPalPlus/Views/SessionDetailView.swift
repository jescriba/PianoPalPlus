//
//  SessionDetailView.swift
//  PianoPalPlus
//
//  Created by joshua on 4/16/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import UIKit
import Combine

class SessionDetailView: UIView {
    private let horiztonalStackView = UIStackView(frame: .zero)
    private let viewButton = UIButton(frame: .zero)
    private let editButton = UIButton(frame: .zero)
    private let deleteButton = UIButton(frame: .zero)
    private let titleLabel = UILabel(frame: .zero)
    private let textField = UITextField(frame: .zero)
    private let editView = UIView(frame: .zero)
    private var viewModel: SessionDetailViewModel
 
    init(viewModel: SessionDetailViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        configureUI()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        backgroundColor = .background
        
        titleLabel.text = "blah blah"
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "Arial", size: 40)
        titleLabel.numberOfLines = 0
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20),
            titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20),
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            titleLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        editView.backgroundColor = .background
        addFullBoundsSubview(editView)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont(name: "Arial", size: 20)
        textField.textColor = .text
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .done
        textField.autocorrectionType = .no
        editView.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.widthAnchor.constraint(equalToConstant: 300),
            textField.heightAnchor.constraint(equalToConstant: 50),
            textField.centerXAnchor.constraint(equalTo: editView.centerXAnchor),
            textField.topAnchor.constraint(equalTo: editView.topAnchor, constant: 20)
        ])
        
        // Add delete/delete button plus default configuration
        editButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.backgroundColor = .editButton
        editButton.setTitle("rename", for: .normal)
        editButton.layer.cornerRadius = 10
        deleteButton.backgroundColor = .deleteButton
        deleteButton.setTitle("delete", for: .normal)
        deleteButton.layer.cornerRadius = 10
        viewButton.backgroundColor = .saveButton
        viewButton.setTitle("view", for: .normal)
        viewButton.layer.cornerRadius = 10
        
        horiztonalStackView.translatesAutoresizingMaskIntoConstraints = false
        horiztonalStackView.spacing = 20
        horiztonalStackView.axis = .horizontal
        horiztonalStackView.distribution = .fillEqually
        addSubview(horiztonalStackView)
        NSLayoutConstraint.activate([
            horiztonalStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            horiztonalStackView.widthAnchor.constraint(equalToConstant: 500),
            horiztonalStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
            horiztonalStackView.heightAnchor.constraint(equalToConstant: 50)
        ])
        horiztonalStackView.addArrangedSubview(deleteButton)
        horiztonalStackView.addArrangedSubview(editButton)
        horiztonalStackView.addArrangedSubview(viewButton)
    }
    
    private var cancellables = Set<AnyCancellable>()
    private func bindViewModel() {
        textField.delegate = viewModel
        deleteButton.actionHandler(for: .touchUpInside, { [weak self] in
            self?.viewModel.didDelete()
        })
        editButton.actionHandler(for: .touchUpInside, { [weak self] in
            self?.viewModel.didEdit()
        })
        viewButton.actionHandler(for: .touchUpInside, { [weak self] in
            self?.viewModel.didView()
        })
        viewModel.$session
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] sessionO in
                guard let session = sessionO else { return }
                self?.titleLabel.text = session.title
                self?.textField.placeholder = session.title
                self?.textField.text = session.title
            }).store(in: &cancellables)
        viewModel.$edit
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] isEditing in
                if isEditing {
                    self?.textField.becomeFirstResponder()
                    self?.editView.alpha = 1
                } else {
                    self?.textField.resignFirstResponder()
                    self?.editView.alpha = 0
                }
            }).store(in: &cancellables)
    }
}
