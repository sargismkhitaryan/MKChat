//
//  MessagingViewModel.swift
//  MKChat
//
//  Created by Sargis Mkhitaryan on 8/20/25.
//  Updated with Core Data Persistence and Pagination - FIXED
//

import UIKit
import Combine

protocol MessagingViewModelProtocol: AnyObject {
    var messages: [Message] { get }
    var isLoading: Bool { get }
    var shouldScrollToBottom: Bool { get }
    var hasMoreMessages: Bool { get }
    var totalMessageCount: Int { get }
    var pageSize: Int { get set }
    
    var messagesPublisher: Published<[Message]>.Publisher { get }
    var isLoadingPublisher: Published<Bool>.Publisher { get }
    var shouldScrollToBottomPublisher: Published<Bool>.Publisher { get }
    var hasMoreMessagesPublisher: Published<Bool>.Publisher { get }
    
    func loadInitialMessages() async
    func loadMoreMessages() async
    func sendMessage(_ text: String) async
    func config(for message: Message) -> MessageConfigurationProtocol
}

class MessagingViewModel: MessagingViewModelProtocol {
    
    // MARK: - Published Properties
    @Published var messages: [Message] = []
    @Published var isLoading: Bool = false
    @Published var shouldScrollToBottom: Bool = false
    @Published var hasMoreMessages: Bool = true
    @Published private(set) var totalMessageCount: Int = 0
    
    // MARK: - Configuration
    var pageSize: Int = 20
    
    // MARK: - Publishers for Protocol Compliance
    var messagesPublisher: Published<[Message]>.Publisher { $messages }
    var isLoadingPublisher: Published<Bool>.Publisher { $isLoading }
    var shouldScrollToBottomPublisher: Published<Bool>.Publisher { $shouldScrollToBottom }
    var hasMoreMessagesPublisher: Published<Bool>.Publisher { $hasMoreMessages }
    
    // MARK: - Private Properties
    private let repository: MessageRepositoryProtocol
    private var oldestLoadedMessageTimestamp: Date?
    private var isInitialized: Bool = false
    
    // MARK: - Initialization
    init(repository: MessageRepositoryProtocol = MessageRepository()) {
        self.repository = repository
        Task {
            await initializeData()
        }
    }
    
    // MARK: - Public Methods
    @MainActor
    func loadInitialMessages() async {
        guard !isLoading else { return }
        
        isLoading = true
        messages.removeAll()
        oldestLoadedMessageTimestamp = nil
        
        do {
            // Update total count
            totalMessageCount = try await repository.getTotalMessageCount()
            
            // Load most recent messages (last pageSize messages)
            let fetchedMessages = try await repository.fetchRecentMessages(limit: pageSize)
            
            messages = fetchedMessages // Already in correct order (oldest to newest)
            
            // Track the oldest message we've loaded for pagination
            oldestLoadedMessageTimestamp = messages.first?.timestamp
            
            // Check if there are more messages to load
            hasMoreMessages = fetchedMessages.count == pageSize && totalMessageCount > pageSize
            
            // Trigger scroll to bottom for initial load
            shouldScrollToBottom = true
        } catch {
            print("Error loading initial messages: \(error)")
        }
        
        isLoading = false
    }
    
    @MainActor
    func loadMoreMessages() async {
        guard !isLoading && hasMoreMessages && oldestLoadedMessageTimestamp != nil else { return }
        
        isLoading = true
        
        do {
            // Load older messages before the oldest message we currently have
            let fetchedMessages = try await repository.fetchMessagesBefore(
                timestamp: oldestLoadedMessageTimestamp!,
                limit: pageSize
            )
            
            if !fetchedMessages.isEmpty {
                // Insert older messages at the beginning
                messages.insert(contentsOf: fetchedMessages, at: 0)
                
                // Update the oldest timestamp
                oldestLoadedMessageTimestamp = fetchedMessages.first?.timestamp
                
                // Check if there are more messages to load
                hasMoreMessages = fetchedMessages.count == pageSize
            } else {
                hasMoreMessages = false
            }
        } catch {
            print("Error loading more messages: \(error)")
        }
        
        isLoading = false
    }
    
    @MainActor
    func sendMessage(_ text: String) async {
        let newMessage = Message(
            id: UUID().uuidString,
            text: text,
            imageURLString: nil,
            timestamp: Date(),
            isFromCurrentUser: true
        )
        
        // Optimistically update UI - append to end (newest message)
        messages.append(newMessage)
        totalMessageCount += 1
        
        // Trigger scroll to bottom
        shouldScrollToBottom = true
        
        // Save to database
        do {
            try await repository.saveMessage(newMessage)
        } catch {
            // Remove from UI if save failed
            if let index = messages.firstIndex(where: { $0.id == newMessage.id }) {
                messages.remove(at: index)
                totalMessageCount -= 1
            }
            print("Error saving message: \(error)")
        }
    }
    
    func config(for message: Message) -> MessageConfigurationProtocol {
        return message.isFromCurrentUser ? MessageConfiguration.default : MessageConfiguration.incoming
    }
    
    // MARK: - Private Methods
    private func initializeData() async {
        guard !isInitialized else { return }
        
        do {
            try await repository.initializeDefaultDataIfNeeded()
            isInitialized = true
            
            await loadInitialMessages()
        } catch {
            print("Error initializing data: \(error)")
        }
    }
}

// MARK: - Pagination Configuration
extension MessagingViewModel {
    
    func updatePageSize(_ newPageSize: Int) {
        pageSize = max(1, newPageSize) // Ensure page size is at least 1
    }
    
    func refreshMessages() async {
        await loadInitialMessages()
    }
    
    var loadedMessageCount: Int {
        return messages.count
    }
    
    var canLoadMore: Bool {
        return hasMoreMessages && !isLoading
    }
}
