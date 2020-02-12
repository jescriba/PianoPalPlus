//
//  CardView.swift
//  PianoPalPlus
//
//  Created by joshua on 2/8/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import UIKit
import Combine

class CardView: UIView {
    private let cardLabel = UILabel()
    
    weak var viewModel: CardViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        cardLabel.textAlignment = .center
        cardLabel.numberOfLines = 0
        cardLabel.text = "welcome to the game zone"
        addFullBoundsSubview(cardLabel, horizontalSpacing: 5)
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 3
        layer.cornerRadius = 5
    }
    
    private var cancellables = Set<AnyCancellable>()
    private func bindViewModel() {
        viewModel?.$title
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] title in
                self?.cardLabel.text = title
            }).store(in: &cancellables)
    }

}
