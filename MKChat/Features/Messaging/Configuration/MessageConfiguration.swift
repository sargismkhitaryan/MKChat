//
//  MessageConfiguration.swift
//  MKChat
//
//  Created by Sargis Mkhitaryan on 8/19/25.
//

import UIKit

protocol MessageConfigurationProtocol {
    var backgroundColor: Color { get }
    var textColor: Color { get }
    var cornerRadius: CGFloat { get }
    var textSize: CGFloat { get }
    var maxWidth: CGFloat { get }
    var imageHeight: CGFloat { get }
}

struct MessageConfiguration: MessageConfigurationProtocol {
    let backgroundColor: Color
    
    /// The radius of the corners for message bubbles.
    /// This value determines how rounded the corners of the message bubble appear.
    let cornerRadius: CGFloat
    let textSize: CGFloat
    let textColor: Color
    
    /// Instead of using fixed sizes for `maxWidth`, and `imageHeight`,
    /// these could be calculated dynamically based on screen size or aspect ratio.
    let maxWidth: CGFloat
    let imageHeight: CGFloat
    
    static let `default` = MessageConfiguration(
        backgroundColor: Color(named: "MessageSendBackgroundColor"),
        cornerRadius: 16,
        textSize: 16,
        textColor: Color(named: "MessageTextColor"),
        maxWidth: 306,
        imageHeight: 250
    )

    static let incoming = MessageConfiguration(
        backgroundColor: Color(named: "MessageReceiveBackgroundColor"),
        cornerRadius: 16,
        textSize: 16,
        textColor: Color(named: "MessageTextColor"),
        maxWidth: 306,
        imageHeight: 250
    )
}
