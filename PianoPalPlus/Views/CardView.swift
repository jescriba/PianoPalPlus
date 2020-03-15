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
    private let cardImageView = UIImageView()
    private var cardImage: UIImage?
    
    weak var viewModel: CardViewModel? {
        didSet {
            bindViewModel()
        }
    }
    
    init(viewModel: CardViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setup()
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
        addFullBoundsSubview(cardImageView, horizontalMultiplier: 0.3, verticalMultiplier: 0.3)
        cardImageView.isHidden = true
        cardImageView.tintColor = .imageTint
        cardImageView.contentMode = .scaleAspectFit
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
        viewModel?.$image
            .subscribe(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] image in
                self?.cardImageView.image = image
                self?.cardImageView.isHidden = image == nil
            }).store(in: &cancellables)
    }
}

class CardViewCell: UICollectionViewCell {
    weak var viewModel: CardViewModel? {
        didSet {
            cardView.viewModel = viewModel
        }
    }
    private let cardView = CardView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addFullBoundsSubview(cardView)
        layer.shadowOpacity = 1
        layer.shadowRadius = 1
        layer.shadowColor = UIColor.shadow.cgColor
        backgroundColor = UIColor.cellBackground
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.masksToBounds = false
        layer.cornerRadius = 3
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
