//
//  InputTextView.swift
//  MKChat
//
//  Created by Sargis Mkhitaryan on 8/20/25.
//

import UIKit

protocol InputTextViewDelegate: AnyObject {
    func inputTextView(_ inputTextView: InputTextView, didSendMessage text: String)
    func inputTextViewDidChange(_ inputTextView: InputTextView)
    func inputTextViewDidBeginEditing(_ inputTextView: InputTextView)
    func inputTextViewDidEndEditing(_ inputTextView: InputTextView)
}

class InputTextView: UIView {
    
    // MARK: - Properties
    weak var delegate: InputTextViewDelegate?
    
    private let containerView = UIView()
    private let textView = UITextView()
    private let sendButton = UIButton(type: .system)
    private let placeholderLabel = UILabel()
    
    var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    
    var maxHeight: CGFloat = 120
    var minHeight: CGFloat = 44
    
    private var textViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Computed Properties
    var text: String {
        get { return textView.text }
        set {
            textView.text = newValue
            updatePlaceholderVisibility()
            updateSendButtonState()
        }
    }
    
    var isEmpty: Bool {
        return textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupConstraints()
        setupActions()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .systemBackground
        
        // Container view styling
        containerView.backgroundColor = .systemGray6
        containerView.layer.cornerRadius = 22
        containerView.layer.borderWidth = 0.5
        containerView.layer.borderColor = UIColor.systemGray4.cgColor
        
        // Text view styling
        textView.backgroundColor = .clear
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .label
        textView.isScrollEnabled = false
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 8)
        textView.delegate = self
        textView.returnKeyType = .send
        textView.enablesReturnKeyAutomatically = true
        
        // Placeholder label styling
        placeholderLabel.text = placeholder
        placeholderLabel.font = UIFont.systemFont(ofSize: 16)
        placeholderLabel.textColor = .placeholderText
        placeholderLabel.numberOfLines = 0
        
        // Send button styling
        sendButton.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        sendButton.tintColor = .systemBlue
        sendButton.contentMode = .scaleAspectFit
        sendButton.isEnabled = false
        sendButton.alpha = 0.5
        
        // Add shadow to container
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: -1)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 1
        
        // Add subviews
        addSubview(containerView)
        containerView.addSubview(textView)
        containerView.addSubview(placeholderLabel)
        containerView.addSubview(sendButton)
    }
    
    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Container view constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        
        // Text view constraints
        textViewHeightConstraint = textView.heightAnchor.constraint(greaterThanOrEqualToConstant: minHeight - 24)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: containerView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            textViewHeightConstraint
        ])
        
        // Placeholder label constraints
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 12),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -8)
        ])
        
        // Send button constraints
        NSLayoutConstraint.activate([
            sendButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -8),
            sendButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
            sendButton.widthAnchor.constraint(equalToConstant: 28),
            sendButton.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    private func setupActions() {
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func sendButtonTapped() {
        guard !isEmpty else { return }
        
        let messageText = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Clear text and reset
        textView.text = ""
        updatePlaceholderVisibility()
        updateSendButtonState()
        updateTextViewHeight()
        
        delegate?.inputTextView(self, didSendMessage: messageText)
    }
    
    // MARK: - Private Methods
    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
    
    private func updateSendButtonState() {
        let hasText = !isEmpty
        sendButton.isEnabled = hasText
        
        UIView.animate(withDuration: 0.2) {
            self.sendButton.alpha = hasText ? 1.0 : 0.5
        }
    }
    
    private func updateTextViewHeight() {
        let fixedWidth = textView.frame.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        let newHeight = min(max(newSize.height, minHeight - 24), maxHeight - 24)
        textViewHeightConstraint.constant = newHeight
        
        textView.isScrollEnabled = newSize.height > maxHeight - 24
        
        UIView.animate(withDuration: 0.2) {
            self.superview?.layoutIfNeeded()
        }
        
        delegate?.inputTextViewDidChange(self)
    }
    
    // MARK: - Public Methods
    
    func clearText() {
        textView.text = ""
        updatePlaceholderVisibility()
        updateSendButtonState()
        updateTextViewHeight()
    }
}

// MARK: - UITextViewDelegate
extension InputTextView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderVisibility()
        updateSendButtonState()
        updateTextViewHeight()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.inputTextViewDidBeginEditing(self)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.inputTextViewDidEndEditing(self)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Handle return key press
        if text == "\n" {
            sendButtonTapped()
            return false
        }
        return true
    }
}
