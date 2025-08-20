//
//  MessageEntity+CoreDataProperties.swift
//  MKChat
//
//  Created by Sargis Mkhitaryan on 8/20/25.
//
//

import Foundation
import CoreData


extension MessageEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MessageEntity> {
        return NSFetchRequest<MessageEntity>(entityName: "MessageEntity")
    }

    @NSManaged public var id: String?
    @NSManaged public var imageURLString: String?
    @NSManaged public var isFromCurrentUser: Bool
    @NSManaged public var text: String?
    @NSManaged public var timestamp: Date?
    @NSManaged public var userDisplayName: String?
    @NSManaged public var userID: String?

}

extension MessageEntity : Identifiable {

}
