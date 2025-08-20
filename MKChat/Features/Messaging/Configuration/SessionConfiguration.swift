//
//  SessionConfiguration.swift
//  MKChat
//
//  Created by Sargis Mkhitaryan on 8/20/25.
//

import UIKit

/// Defines the vertical layout flow of messages within a session.
///
/// - `topToBottom`: Messages are displayed in natural reading order,
///   where the first (oldest) message appears at the top and new messages
///   are appended below it.
/// - `bottomToTop`: Messages are displayed in reversed order,
///   where the most recent message appears at the bottom and the list
///   grows upward. This is commonly used in chat interfaces to keep the
///   latest message anchored near the keyboard input area.
enum MessageLayoutDirection {
    case topToBottom
    case bottomToTop
}

protocol SessionConfigurationProtocol {
    var backgroundColor: UIColor { get }
    var layoutDirection: MessageLayoutDirection { get }
    
    var transform: CGAffineTransform { get }
}

extension SessionConfigurationProtocol {
    var transform: CGAffineTransform {
        switch layoutDirection {
        case .bottomToTop: return CGAffineTransform(scaleX: 1, y: -1)
        case .topToBottom: return CGAffineTransform.identity
        }
    }
}

struct SessionConfiguration: SessionConfigurationProtocol {
    var backgroundColor: UIColor
    var layoutDirection: MessageLayoutDirection
    
    static let `default` = SessionConfiguration(
        backgroundColor: UIColor(named: "SessionBackgroundColor") ?? .white,
        layoutDirection: .bottomToTop
    )
}
