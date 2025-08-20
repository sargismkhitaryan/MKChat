//
//  MessageCollectionViewCell.swift
//  MKChat
//
//  Created by Sargis Mkhitaryan on 8/19/25.
//

import UIKit

class MessageCollectionViewCell: UICollectionViewCell {
    static let identifier = "MessageCollectionViewCell"
    
    private let messageView = MessageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    private func setupCell() {
        messageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(messageView)
        
        NSLayoutConstraint.activate([
            messageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            messageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            messageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 0),
            messageView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: 0)
        ])
    }
    
    func configure(with message: Message, configuration: MessageConfigurationProtocol) {
        messageView.configure(with: message, configuration: configuration)
        
        // Align message based on sender
        if message.isFromCurrentUser {
            messageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true
        } else {
            messageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        messageView.removeFromSuperview()
        messageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(messageView)
        setupCell()
    }
}
