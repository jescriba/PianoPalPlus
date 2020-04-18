//
//  TheoryItemView.swift
//  PianoPalPlus
//
//  Created by joshua on 3/14/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import UIKit
import Combine

class TheoryItemView: UIView {
    weak var viewModel: TheoryItemViewModel? {
        didSet {
            bindViewModel()
        }
    }
    var stackView = UIStackView(frame: .zero)
    var pickerView = UIPickerView(frame: .zero)
    var saveButton = UIButton(frame: .zero)
    var deleteButton = UIButton(frame: .zero)
    
    init(viewModel: TheoryItemViewModel) {
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
        
        // Add save/delete button plus default configuration
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.backgroundColor = .saveButton
        saveButton.setTitle("save", for: .normal)
        saveButton.layer.cornerRadius = 10
        deleteButton.backgroundColor = .deleteButton
        deleteButton.setTitle("delete", for: .normal)
        deleteButton.layer.cornerRadius = 10
        addSubview(saveButton)
        addSubview(deleteButton)
        
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(pickerView)
        addSubview(stackView)
        NSLayoutConstraint.activate([
            saveButton.widthAnchor.constraint(equalToConstant: 200),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
            saveButton.leftAnchor.constraint(equalTo: stackView.centerXAnchor, constant: 10),
            deleteButton.widthAnchor.constraint(equalToConstant: 200),
            deleteButton.heightAnchor.constraint(equalToConstant: 50),
            deleteButton.centerYAnchor.constraint(equalTo: saveButton.centerYAnchor),
            deleteButton.rightAnchor.constraint(equalTo: stackView.centerXAnchor, constant: -10)
        ])
        
        // Add picker view that drives item selection
        pickerView.backgroundColor = .cellBackground
        pickerView.layer.cornerRadius = 20
        NSLayoutConstraint.activate([
            self.stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            self.stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            self.stackView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            self.stackView.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -30)
        ])
    }
    
    private var cancellables = Set<AnyCancellable>()
    private func bindViewModel() {
        saveButton.addTarget(self, action: #selector(didSave), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(didDelete), for: .touchUpInside)
        pickerView.dataSource = viewModel
        pickerView.delegate = viewModel
        viewModel?.$pickerSelections
            .filter({ $0 != nil })
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] selectionsO in
                guard let selfV = self, let selections = selectionsO else { return }
                selections.forEach({ indexPath in
                    selfV.pickerView.selectRow(indexPath.row, inComponent: indexPath.section, animated: true)
                    selfV.viewModel?.pickerView(selfV.pickerView, didSelectRow: indexPath.row, inComponent: indexPath.section)
                })
            }).store(in: &cancellables)
    }
    
    @objc func didSave() {
        viewModel?.didSave()
    }
    
    @objc func didDelete() {
        viewModel?.didDelete()
    }
}
