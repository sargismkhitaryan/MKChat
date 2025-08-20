//
//  Message.swift
//  MKChat
//
//  Created by Sargis Mkhitaryan on 8/19/25.
//

import Foundation

struct Message {
    let id: String
    let text: String?
    let imageURLString: String?
    let timestamp: Date
    let isFromCurrentUser: Bool // Temp variable for quick demo
    var userID: String?
    var userDisplayName: String?
    
    init(id: String, text: String?, imageURLString: String? = nil, timestamp: Date = Date(), isFromCurrentUser: Bool = Bool.random()) {
        self.id = id
        self.text = text
        self.imageURLString = imageURLString
        self.timestamp = timestamp
        self.isFromCurrentUser = isFromCurrentUser
    }
}
