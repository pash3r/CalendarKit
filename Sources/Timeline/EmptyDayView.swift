//
//  EmptyDayView.swift
//  
//
//  Created by Pavel Tikhonov on 12/6/21.
//

import UIKit

class EmptyDayView: UIView {
    
    var style: EmptyDayViewStyle = .init() {
        didSet {
            apply(style: style)
        }
    }
    
    private let titleLabel: UILabel = {
        let result = UILabel()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.numberOfLines = 0
        result.textAlignment = .center
        return result
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureSelf()
        apply(style: style)
    }
    
    required init?(coder: NSCoder) {
        fatalError("\(#function) is not supported")
    }
    
    private func configureSelf() {
        titleLabel.text = "У вас выходной в этот день.\nХорошего отдыха!"
        
        addSubview(titleLabel)
        
        let horizontalMargin: CGFloat = 24
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: horizontalMargin),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -horizontalMargin),
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
    
    private func apply(style: EmptyDayViewStyle) {
        titleLabel.font = style.textFont
        titleLabel.textColor = style.textColor
        titleLabel.backgroundColor = style.backgroundColor
        self.backgroundColor = style.backgroundColor
    }
    
}

