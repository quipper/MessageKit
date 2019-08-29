//
//  AnnounceMessageSizeCalculator.swift
//  QLearn
//
//  Created by M_Sugawara on 2019/08/07.
//  Copyright © 2019 Quipper Ltd. All rights reserved.
//

import Foundation

open class AnnouncementMessageSizeCalculator: MessageSizeCalculator {
    
    public var messageLabelFont = UIFont.preferredFont(forTextStyle: .body)
    
    public let messageLabelInsets = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
    public let messageContainerInsets = UIEdgeInsets(top: 0, left: 16 * 2, bottom: 0, right: 16 * 2)
    
    public var timeLabelAlignment = LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(right: 8))
    
    // AnnoucementMessage doesn't need avatar
    public let avatarPosition = AvatarPosition(horizontal: .none, vertical: .none)
    public let avatarSize: CGSize = .zero
    
    open override func configure(attributes: UICollectionViewLayoutAttributes) {
        super.configure(attributes: attributes)
        guard let attributes = attributes as? MessagesCollectionViewLayoutAttributes else { return }
        
        let dataSource = messagesLayout.messagesDataSource
        let indexPath = attributes.indexPath
        let message = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)
        
        attributes.avatarPosition = avatarPosition
        attributes.avatarSize = avatarSize
        
        attributes.messageLabelInsets = messageLabelInsets
        attributes.messageLabelFont = messageLabelFont
        
        switch message.kind {
        case .attributedText(let text):
            guard !text.string.isEmpty else { return }
            guard let font = text.attribute(.font, at: 0, effectiveRange: nil) as? UIFont else { return }
            attributes.messageLabelFont = font
        default:
            break
        }
    }
    
    open override func cellContentHeight(for message: MessageType, at indexPath: IndexPath) -> CGFloat {
        let timeLabelHeight = timeLabelSize(for: message, at: indexPath).height
        return super.cellContentHeight(for: message, at: indexPath) + timeLabelHeight
    }
    
    open override func messageContainerMaxWidth(for message: MessageType) -> CGFloat {
        return messagesLayout.itemWidth - messageContainerInsets.horizontal
    }
    
    open override func messageContainerSize(for message: MessageType) -> CGSize {
        let maxWidth = messageContainerMaxWidth(for: message)
        
        var messageContainerSize: CGSize
        let attributedText: NSAttributedString
        
        switch message.kind {
        case .announcement(let text):
            attributedText = NSAttributedString(string: text, attributes: [.font: messageLabelFont])
        default:
            fatalError("messageContainerSize received unhandled MessageDataType: \(message.kind)")
        }
        
        let sizeOfLabel = labelSize(for: attributedText, considering: maxWidth)
        messageContainerSize = CGSize(width: maxWidth, height: sizeOfLabel.height)
        
        let messageInsets = messageLabelInsets
        messageContainerSize.width += messageInsets.horizontal
        messageContainerSize.height += messageInsets.vertical
        
        return messageContainerSize
    }
    
    // MARK: - Avatar
    
    open override func avatarSize(for message: MessageType) -> CGSize {
        return .zero
    }
    
    open override func avatarPosition(for message: MessageType) -> AvatarPosition {
        return avatarPosition
    }
    
}

fileprivate extension UIEdgeInsets {
    init(top: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0) {
        self.init(top: top, left: left, bottom: bottom, right: right)
    }
}
