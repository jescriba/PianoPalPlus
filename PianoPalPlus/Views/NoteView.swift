//
//  NoteButton.swift
//  pianotools
//
//  Created by Joshua Escribano on 6/13/16.
//  Copyright © 2016 Joshua Escribano. All rights reserved.
//

import UIKit
import Combine

extension UIView {
    func addFullBoundsSubview(_ view: UIView,
                              horizontalSpacing: CGFloat = 0,
                              verticalSpacing: CGFloat = 0) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: self.leftAnchor, constant: horizontalSpacing),
            view.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -horizontalSpacing),
            view.topAnchor.constraint(equalTo: self.topAnchor, constant: verticalSpacing),
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -verticalSpacing)
        ])
    }
    
    func addFullBoundsSubview(_ view: UIView,
                              horizontalMultiplier: CGFloat,
                              verticalMultiplier: CGFloat) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view)
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            view.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: verticalMultiplier),
            view.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: horizontalMultiplier)
        ])
    }
}

class NoteView: UIView {
    @Published var hasTouch: Bool = false
    var touches: Set<UITouch> = Set<UITouch>() {
        didSet {
            if touches.count > 0 {
                if oldValue.isEmpty {
                    hasTouch = true
                }
            } else {
                hasTouch = false
            }
        }
    }
    private var titleLabel = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    weak var viewModel: NoteViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.border.cgColor
        titleLabel.textAlignment = .center
        self.addFullBoundsSubview(titleLabel)
    }
    
    private var cancellables = Set<AnyCancellable>()
    private func bindViewModel() {
        viewModel?.$backgroundColor
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] color in
                self?.backgroundColor = color
            }).store(in: &cancellables)
        viewModel?.$borderColor
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] color in
                self?.layer.borderColor = color.cgColor
            }).store(in: &cancellables)
    }
    
    
}
