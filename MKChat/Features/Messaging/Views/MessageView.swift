//
//  MessageView.swift
//  MKChat
//
//  Created by Sargis Mkhitaryan on 8/19/25.
//

import UIKit
import SDWebImage

class MessageView: UIView {
    private let containerView = UIView()
    private let textLabel = UILabel()
    private let imageView = UIImageView()
    private let stackView = UIStackView()
    private let userAvatarImageView = UIImageView()
    private let messageContentView = UIView()
    private let avatarWidth: CGFloat = 40
    
    // Store constraints to deactivate them when needed
    private var imageHeightConstraint: NSLayoutConstraint?
    private var imageWidthConstraint: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // User avatar setup
        userAvatarImageView.translatesAutoresizingMaskIntoConstraints = false
        userAvatarImageView.contentMode = .scaleAspectFill
        userAvatarImageView.clipsToBounds = true
        userAvatarImageView.layer.cornerRadius = avatarWidth / 2.0
        userAvatarImageView.backgroundColor = UIColor.systemGray5
        addSubview(userAvatarImageView)
        
        // Message content view setup
        messageContentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(messageContentView)
        
        // Container setup
        containerView.translatesAutoresizingMaskIntoConstraints = false
        messageContentView.addSubview(containerView)
        
        // Stack view setup
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(stackView)

        // Image view setup
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        
        // Text label setup
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
        
        let textLabelContainer = UIView()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabelContainer.addSubview(textLabel)

        NSLayoutConstraint.activate([
            textLabel.leadingAnchor.constraint(equalTo: textLabelContainer.leadingAnchor, constant: 12),
            textLabel.trailingAnchor.constraint(equalTo: textLabelContainer.trailingAnchor, constant: -12),
            textLabel.topAnchor.constraint(equalTo: textLabelContainer.topAnchor, constant: 8),
            textLabel.bottomAnchor.constraint(equalTo: textLabelContainer.bottomAnchor, constant: -8)
        ])

        stackView.addArrangedSubview(textLabelContainer)
        stackView.addArrangedSubview(imageView)
        
        // TODO: Move all fixed paddings, margins, sizes
        // (avatar size, text insets, container padding, image radius, etc.)
        // into MessageConfiguration to avoid hardcoding values here.
        NSLayoutConstraint.activate([
            // User avatar constraints
            userAvatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            userAvatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            userAvatarImageView.widthAnchor.constraint(equalToConstant: avatarWidth),
            userAvatarImageView.heightAnchor.constraint(equalToConstant: avatarWidth),
            
            // Message content view constraints
            messageContentView.leadingAnchor.constraint(equalTo: userAvatarImageView.trailingAnchor, constant: 8),
            messageContentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            messageContentView.topAnchor.constraint(equalTo: topAnchor),
            messageContentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Container constraints (within message content view)
            containerView.topAnchor.constraint(equalTo: messageContentView.topAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: messageContentView.bottomAnchor, constant: 0),
            containerView.leadingAnchor.constraint(equalTo: messageContentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: messageContentView.trailingAnchor),
            
            // Stack view constraints
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 2),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -2),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 2),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -2),
            
        ])
        
        stackView.clipsToBounds = true
    }
    
    func configure(with message: Message, configuration: MessageConfigurationProtocol) {
        // Configure container appearance
        containerView.backgroundColor = UIColor(configuration.backgroundColor)
        containerView.layer.cornerRadius = configuration.cornerRadius
        stackView.layer.cornerRadius = configuration.cornerRadius
        
        // Configure text
        textLabel.text = message.text
        textLabel.font = UIFont.systemFont(ofSize: configuration.textSize)
        textLabel.textColor = UIColor(configuration.textColor)
        
        // Configure user avatar
        configureUserAvatar(for: message)
        
        // Remove previous image constraints
        imageHeightConstraint?.isActive = false
        imageWidthConstraint?.isActive = false
        
        // Configure image
        imageView.image = nil
        if let imageName = message.imageURLString, let url = URL(string: imageName) {
            imageView.sd_setImage(with: url)
            imageView.isHidden = false
            
            // Create new constraints with lower priority to avoid conflicts
            imageHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: configuration.imageHeight)
            imageWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: configuration.imageHeight)
            
            // Set priority to avoid conflicts with cell height constraints
            imageHeightConstraint?.priority = UILayoutPriority(999)
            imageWidthConstraint?.priority = UILayoutPriority(999)
            
            imageHeightConstraint?.isActive = true
            imageWidthConstraint?.isActive = true
        } else {
            imageView.isHidden = true
        }
        
        // Set max width constraint (adjusted for avatar space)
        let adjustedMaxWidth = configuration.maxWidth
        let maxWidthConstraint = containerView.widthAnchor.constraint(lessThanOrEqualToConstant: adjustedMaxWidth)
        maxWidthConstraint.priority = UILayoutPriority(999)
        maxWidthConstraint.isActive = true
    }
    
    private func configureUserAvatar(for message: Message) {
        userAvatarImageView.isHidden = message.isFromCurrentUser
        userAvatarImageView.image = UIImage(named: "icon_avatar") // Temp. fixed image
    }
}
