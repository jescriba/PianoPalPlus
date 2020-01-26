//
//  ToolBarView.swift
//  PianoPalPlus
//
//  Created by joshua on 1/20/20.
//  Copyright © 2020 joshua. All rights reserved.
//

import Foundation
import UIKit

protocol ToolBarDelegate: NSObject {
    func scrollLockDidChange()
}

class ToolBarView: UIView {
    weak var delegate: ToolBarDelegate?
    var isScrollLocked: Bool = false {
        didSet {
            scrollLockButton.imageView?.tintColor = isScrollLocked ? Colors.scrollLockSelected : Colors.scrollLockUnselected
        }
    }
    private var scrollLockButton: UIButton!
    private let scrollImage = UIImage(systemName: "arrow.right.arrow.left")?.withRenderingMode(.alwaysTemplate)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.backgroundColor = .purple
        scrollLockButton = UIButton()
        scrollLockButton.setImage(scrollImage, for: .normal)
        scrollLockButton.addTarget(self, action: #selector(scrollLockTapped), for: .touchUpInside)
        scrollLockButton.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(scrollLockButton)
        NSLayoutConstraint.activate([
            scrollLockButton.widthAnchor.constraint(equalToConstant: 50),
            scrollLockButton.heightAnchor.constraint(equalToConstant: 50),
            scrollLockButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            scrollLockButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        isScrollLocked = { self.isScrollLocked }()
    }
    
    @objc func scrollLockTapped() {
        delegate?.scrollLockDidChange()
    }
}
