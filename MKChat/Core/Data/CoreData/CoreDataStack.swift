//
//  CoreDataStack.swift
//  MKChat
//
//  Created by Sargis Mkhitaryan on 8/20/25.
//

import CoreData
import UIKit

class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    private init() {}
    
    // MARK: - Core Data Stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MKChatDataModel")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Core Data Saving
    func saveContext() {
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Background Context
    func newBackgroundContext() -> NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
}

// MARK: - MessageEntity Extensions
extension MessageEntity {
    
    // Convert to domain model
    func toMessage() -> Message {
        var message = Message(
            id: self.id ?? "",
            text: self.text ?? "",
            imageURLString: self.imageURLString,
            timestamp: self.timestamp ?? Date(),
            isFromCurrentUser: self.isFromCurrentUser
        )
        
        if let userID = self.userID, let userDisplayName = self.userDisplayName {
            message.userID = userID
            message.userDisplayName = userDisplayName
        }
        
        return message
    }
    
    // Create from domain model
    static func from(message: Message, in context: NSManagedObjectContext) -> MessageEntity {
        let entity = MessageEntity(context: context)
        entity.id = message.id
        entity.text = message.text
        entity.imageURLString = message.imageURLString
        entity.timestamp = message.timestamp
        entity.isFromCurrentUser = message.isFromCurrentUser
        entity.userID = message.userID
        entity.userDisplayName = message.userDisplayName
        return entity
    }
}
