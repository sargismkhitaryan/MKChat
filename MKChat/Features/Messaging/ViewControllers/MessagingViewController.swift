//
//  MessagingViewController.swift
//  MKChat
//
//  Created by Sargis Mkhitaryan on 8/19/25.
//  Refactored to MVVM Architecture
//

import UIKit
import Combine

class MessagingViewController: UIViewController {
    
    // MARK: - MVVM Properties
    private var viewModel: MessagingViewModelProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Properties
    var sessionConfig: SessionConfigurationProtocol = SessionConfiguration.default
    private var collectionView: UICollectionView!
    private var inputTextView: InputTextView!
    private var inputTextViewBottomConstraint: NSLayoutConstraint!
    
    // MARK: - Initialization
    init(viewModel: MessagingViewModelProtocol = MessagingViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = MessagingViewModel()
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
        bindViewModel()
        
        // Load initial messages asynchronously
        Task {
            await viewModel.loadInitialMessages()
        }
    }
    
    // MARK: - MVVM Binding
    private func bindViewModel() {
        // Bind messages changes
        viewModel.messagesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
        
        // Bind loading state
        viewModel.isLoadingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                // You can show/hide loading indicator here if needed
                // self?.showLoadingIndicator(isLoading)
            }
            .store(in: &cancellables)
        
        // Bind scroll to bottom trigger
        viewModel.shouldScrollToBottomPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shouldScroll in
                if shouldScroll {
                    self?.scrollToBottom()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = sessionConfig.backgroundColor
        title = "Messages"
        
        setupCollectionView()
        setupInputTextView()
        setupConstraints()
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(MessageCollectionViewCell.self, forCellWithReuseIdentifier: MessageCollectionViewCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.keyboardDismissMode = .interactive
        
        collectionView.transform = sessionConfig.transform
        collectionView.contentInsetAdjustmentBehavior = .automatic
    }
    
    private func setupInputTextView() {
        inputTextView = InputTextView()
        inputTextView.delegate = self
        inputTextView.placeholder = "Write a message..."
        inputTextView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        view.addSubview(collectionView)
        view.addSubview(inputTextView)
        
        inputTextViewBottomConstraint = inputTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            // Collection view constraints
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: inputTextView.topAnchor),
            
            // Input text view constraints
            inputTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputTextViewBottomConstraint
        ])
    }
    
    // MARK: - Keyboard Handling
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        inputTextViewBottomConstraint.constant = -keyboardHeight
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        inputTextViewBottomConstraint.constant = 0
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Scrolling
    private func scrollToBottom() {
        guard viewModel.messages.count > 0 else { return }
        self.collectionView.setContentOffset(.zero, animated: true)
    }
    
    // MARK: - Cleanup
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - InputTextViewDelegate
extension MessagingViewController: InputTextViewDelegate {
    func inputTextView(_ inputTextView: InputTextView, didSendMessage text: String) {
        Task {
            await viewModel.sendMessage(text)
        }
    }
    
    func inputTextViewDidChange(_ inputTextView: InputTextView) {
        // Handle input text view height changes if needed
        // You can add typing indicators here
    }
    
    func inputTextViewDidBeginEditing(_ inputTextView: InputTextView) {
        scrollToBottom()
    }
    
    func inputTextViewDidEndEditing(_ inputTextView: InputTextView) {
        // Handle end editing if needed
    }
}

// MARK: - Collection View Data Source & Delegate
extension MessagingViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MessageCollectionViewCell.identifier, for: indexPath) as! MessageCollectionViewCell
        
        let messageIndex = viewModel.messages.count - 1 - indexPath.item
        let message = viewModel.messages[messageIndex]
        let config = viewModel.config(for: message)
        
        cell.configure(with: message, configuration: config)
        cell.contentView.transform = sessionConfig.transform
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let messageIndex = viewModel.messages.count - 1 - indexPath.item
        let message = viewModel.messages[messageIndex]
        
        // Calculate estimated height based on content
        let config = viewModel.config(for: message)
        var maxWidth: CGFloat = config.maxWidth
        if message.imageURLString != nil {
            maxWidth = min(maxWidth, config.imageHeight)
        }
        let padding: CGFloat = 24 // Left/right padding in text container
        let textVerticalPadding: CGFloat = 16 // Top/bottom padding in text container (8 + 8)
        let containerPadding: CGFloat = 4 // Stack view padding (2 top + 2 bottom)
        
        // Calculate text height
        let textHeight = message.text?.boundingRect(
            with: CGSize(width: maxWidth - padding, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: UIFont.systemFont(ofSize: config.textSize)],
            context: nil
        ).height ?? 0
        
        // Add image height if present
        let imageHeight: CGFloat = message.imageURLString != nil ? config.imageHeight : 0
        
        // Total height calculation
        let totalTextHeight = textHeight + textVerticalPadding
        let totalHeight = totalTextHeight + imageHeight + containerPadding
        
        return CGSize(width: width, height: max(totalHeight, 60)) // Minimum height of 60
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        // CHAT-STYLE: Load more when scrolled to top (which loads older messages)
        // Since the view is rotated, "top" is when offsetY is near contentHeight - height
        if offsetY > contentHeight - height - 100 {
            Task {
                await viewModel.loadMoreMessages()
            }
        }
    }
}
