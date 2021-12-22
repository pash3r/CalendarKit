//
//  LessonEventView.swift
//  
//
//  Created by Pavel Tikhonov on 12/6/21.
//

import UIKit

class LessonEventView: UIView {
    
    let addressLabel: UILabel = {
        let result = UILabel()
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    let nameLabel: UILabel = {
        let result = UILabel()
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    let imageView: UIImageView = {
        let result = UIImageView()
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()
    
    let overlayView: UIView = {
        let result = UIView()
        result.translatesAutoresizingMaskIntoConstraints = false
        result.backgroundColor = .secondarySystemGroupedBackground
        result.alpha = 0.5
        return result
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSelf()
    }
    
    required init?(coder: NSCoder) {
        fatalError("\(#function) is not supported")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.layer.cornerRadius = imageView.frame.width / 2
    }
    
    private func configureSelf() {
        imageView.layer.masksToBounds = true
        [addressLabel, nameLabel, imageView, overlayView].forEach { self.addSubview($0) }
        
        let nameLabelBottomConstraint = nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomAnchor, constant: -Constants.bottomMargin)
        nameLabelBottomConstraint.priority = .init(999)
        
        NSLayoutConstraint.activate([
            addressLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: Constants.topMargin),
            addressLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.horizontalMargin),
            addressLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -Constants.horizontalMargin),
            
            imageView.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: Constants.imageTopMargin),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Constants.horizontalMargin),
            imageView.widthAnchor.constraint(equalToConstant: Constants.imageSideLength),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: Constants.betweenLabelsMargin),
            nameLabel.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: Constants.imageRightMargin),
            nameLabelBottomConstraint,
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -Constants.horizontalMargin),
            
            overlayView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            overlayView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            overlayView.widthAnchor.constraint(equalTo: self.widthAnchor),
            overlayView.heightAnchor.constraint(equalTo: self.heightAnchor)
        ])
    }
    
    private struct Constants {
        static let topMargin: CGFloat = 8
        static let horizontalMargin: CGFloat = 16
        static let bottomMargin: CGFloat = 13
        static let betweenLabelsMargin: CGFloat = 7
        static let imageTopMargin: CGFloat = 4
        static let imageSideLength: CGFloat = 20
        static let imageRightMargin: CGFloat = 8
    }
    
}

