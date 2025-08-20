//
//  MessageRepository.swift
//  MKChat
//
//  Created by Sargis Mkhitaryan on 8/20/25.
//  Updated with timestamp-based pagination
//

import CoreData
import UIKit

protocol MessageRepositoryProtocol {
    func fetchMessages(limit: Int, offset: Int) async throws -> [Message]
    func fetchRecentMessages(limit: Int) async throws -> [Message]
    func fetchMessagesBefore(timestamp: Date, limit: Int) async throws -> [Message]
    func saveMessage(_ message: Message) async throws
    func saveMessages(_ messages: [Message]) async throws
    func deleteAllMessages() async throws
    func getTotalMessageCount() async throws -> Int
    func initializeDefaultDataIfNeeded() async throws
}

class MessageRepository: MessageRepositoryProtocol {
    
    private let coreDataStack: CoreDataStack
    
    init(coreDataStack: CoreDataStack = CoreDataStack.shared) {
        self.coreDataStack = coreDataStack
    }
    
    // MARK: - Fetch Recent Messages (Most Recent)
    func fetchRecentMessages(limit: Int) async throws -> [Message] {
        return try await withCheckedThrowingContinuation { continuation in
            let context = coreDataStack.newBackgroundContext()
            context.perform {
                do {
                    let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
                    request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)] // Newest first
                    request.fetchLimit = limit
                    
                    let entities = try context.fetch(request)
                    let messages = entities.map { $0.toMessage() }.reversed() // Reverse to get oldest to newest
                    continuation.resume(returning: Array(messages))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Fetch Messages Before Timestamp
    func fetchMessagesBefore(timestamp: Date, limit: Int) async throws -> [Message] {
        return try await withCheckedThrowingContinuation { continuation in
            let context = coreDataStack.newBackgroundContext()
            context.perform {
                do {
                    let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
                    request.predicate = NSPredicate(format: "timestamp < %@", timestamp as NSDate)
                    request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)] // Newest first
                    request.fetchLimit = limit
                    
                    let entities = try context.fetch(request)
                    let messages = entities.map { $0.toMessage() }.reversed() // Reverse to get oldest to newest
                    continuation.resume(returning: Array(messages))
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Fetch Messages with Pagination (Legacy - keep for compatibility)
    func fetchMessages(limit: Int, offset: Int) async throws -> [Message] {
        return try await withCheckedThrowingContinuation { continuation in
            let context = coreDataStack.newBackgroundContext()
            context.perform {
                do {
                    let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
                    request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
                    request.fetchLimit = limit
                    request.fetchOffset = offset
                    
                    let entities = try context.fetch(request)
                    let messages = entities.map { $0.toMessage() }
                    continuation.resume(returning: messages)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Save Single Message
    func saveMessage(_ message: Message) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let context = coreDataStack.newBackgroundContext()
            context.perform {
                do {
                    _ = MessageEntity.from(message: message, in: context)
                    try context.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Save Multiple Messages
    func saveMessages(_ messages: [Message]) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let context = coreDataStack.newBackgroundContext()
            context.perform {
                do {
                    for message in messages {
                        _ = MessageEntity.from(message: message, in: context)
                    }
                    try context.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Delete All Messages
    func deleteAllMessages() async throws {
        return try await withCheckedThrowingContinuation { continuation in
            let context = coreDataStack.newBackgroundContext()
            context.perform {
                do {
                    let request: NSFetchRequest<NSFetchRequestResult> = MessageEntity.fetchRequest()
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
                    try context.execute(deleteRequest)
                    try context.save()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Get Total Message Count
    func getTotalMessageCount() async throws -> Int {
        return try await withCheckedThrowingContinuation { continuation in
            let context = coreDataStack.newBackgroundContext()
            context.perform {
                do {
                    let request: NSFetchRequest<MessageEntity> = MessageEntity.fetchRequest()
                    let count = try context.count(for: request)
                    continuation.resume(returning: count)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - Initialize Default Data
    func initializeDefaultDataIfNeeded() async throws {
        let messageCount = try await getTotalMessageCount()
        
        if messageCount == 0 {
            let sampleMessages = generateSampleMessages()
            try await saveMessages(sampleMessages)
        }
    }
    
    // MARK: - Generate Sample Data
    private func generateSampleMessages() -> [Message] {
        let sampleTexts = [
            "Hello there! How are you doing today?",
            "Just finished an amazing workout 💪",
            "Check out this beautiful sunset I captured!",
            "What are your weekend plans?",
            "I'm thinking of trying that new restaurant downtown",
            "Thanks for the recommendation, it was fantastic!",
            "Did you catch the game last night?",
            "The weather is perfect for a walk in the park",
            "Can't believe it's already Friday!",
            "Hope you're having a great day",
            "This book I'm reading is absolutely captivating",
            "Coffee meeting at 3 PM?",
            "Just saw the funniest movie ever",
            "My garden is finally blooming!",
            "Traffic is crazy today",
            "Looking forward to the weekend",
            "This recipe turned out amazing",
            "Can you believe this view?",
            "Time flies when you're having fun",
            "Good morning! Ready for a productive day?"
        ]
        
        let imageURLs: [String] = [
            "https://images.pexels.com/photos/1323550/pexels-photo-1323550.jpeg",
            "https://images.pexels.com/photos/461940/pexels-photo-461940.jpeg",
            "https://images.pexels.com/photos/3183132/pexels-photo-3183132.jpeg"
        ]
        
        let userID = "1"
        let userDisplayName = "John Doe"
        var messages: [Message] = []
        
        // Generate 1000 sample messages with timestamps spread over time
        let baseDate = Date().addingTimeInterval(-1000 * 3600) // 1000 hours ago
        
        for i in 0..<1000 {
            let hasImage = i % 5 == 0 // Every 5th message has an image
            let text = sampleTexts[i % sampleTexts.count]
            let imageURLString = hasImage ? imageURLs[i % imageURLs.count] : nil
            let isFromCurrentUser = i % 3 != 0
            
            var message = Message(
                id: UUID().uuidString,
                text: text,
                imageURLString: imageURLString,
                timestamp: baseDate.addingTimeInterval(TimeInterval(i * 3600)), // Each message 1 hour apart
                isFromCurrentUser: isFromCurrentUser
            )
            
            if !isFromCurrentUser {
                message.userID = userID
                message.userDisplayName = userDisplayName
            }
            messages.append(message)
        }
        
        return messages // Already in chronological order (oldest to newest)
    }
}
