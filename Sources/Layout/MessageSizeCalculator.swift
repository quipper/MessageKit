/*
 MIT License

 Copyright (c) 2017-2019 MessageKit

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation

open class MessageSizeCalculator: CellSizeCalculator {

    public init(layout: MessagesCollectionViewFlowLayout? = nil) {
        super.init()
        
        self.layout = layout
    }

    public var incomingAvatarSize = CGSize(width: 40, height: 40)
    public var outgoingAvatarSize = CGSize.zero

    public var incomingAvatarPosition = AvatarPosition(vertical: .messageLabelTop)
    public var outgoingAvatarPosition = AvatarPosition(vertical: .messageLabelTop)

    public var avatarLeadingTrailingPadding: CGFloat = 0

    public var incomingMessagePadding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 30)
    public var outgoingMessagePadding = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 8)

    public var incomingCellTopLabelAlignment = LabelAlignment(textAlignment: .center, textInsets: .zero)
    public var outgoingCellTopLabelAlignment = LabelAlignment(textAlignment: .center, textInsets: .zero)
    
    public var incomingCellBottomLabelAlignment = LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(left: 46))
    public var outgoingCellBottomLabelAlignment = LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(right: 46))

    public var incomingMessageTopLabelAlignment = LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 46, bottom: 8, right: 0))
    public var outgoingMessageTopLabelAlignment = LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 46))

    public var incomingMessageBottomLabelAlignment = LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(left: 46))
    public var outgoingMessageBottomLabelAlignment = LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(right: 46))

    public var incomingAccessoryViewSize = CGSize.zero
    public var outgoingAccessoryViewSize = CGSize.zero

    public var incomingAccessoryViewPadding = HorizontalEdgeInsets.zero
    public var outgoingAccessoryViewPadding = HorizontalEdgeInsets.zero
    
    public var incomingAccessoryViewPosition: AccessoryPosition = .messageCenter
    public var outgoingAccessoryViewPosition: AccessoryPosition = .messageCenter

    public var incomingTimeLabelAlignment = LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(left: 8))
    public var outgoingTimeLabelAlignment = LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(right: 8))

    open override func configure(attributes: UICollectionViewLayoutAttributes) {
        guard let attributes = attributes as? MessagesCollectionViewLayoutAttributes else { return }

        let dataSource = messagesLayout.messagesDataSource
        let indexPath = attributes.indexPath
        let message = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)

        attributes.avatarSize = avatarSize(for: message)
        attributes.avatarPosition = avatarPosition(for: message)
        attributes.avatarLeadingTrailingPadding = avatarLeadingTrailingPadding

        attributes.messageContainerPadding = messageContainerPadding(for: message)
        attributes.messageContainerSize = messageContainerSize(for: message)
        attributes.cellTopLabelSize = cellTopLabelSize(for: message, at: indexPath)
        attributes.cellBottomLabelSize = cellBottomLabelSize(for: message, at: indexPath)
        attributes.cellBottomLabelAlignment = cellBottomLabelAlignment(for: message)
        attributes.messageTopLabelSize = messageTopLabelSize(for: message, at: indexPath)
        attributes.messageTopLabelAlignment = messageTopLabelAlignment(for: message)

        attributes.messageBottomLabelAlignment = messageBottomLabelAlignment(for: message)
        attributes.messageBottomLabelSize = messageBottomLabelSize(for: message, at: indexPath)

        attributes.cellBottomViewSize = cellBottomViewSize(for: message, at: indexPath)

        attributes.accessoryViewSize = accessoryViewSize(for: message)
        attributes.accessoryViewPadding = accessoryViewPadding(for: message)
        attributes.accessoryViewPosition = accessoryViewPosition(for: message)

        attributes.timeLabelAlignment = timeLabelAlignment(for: message)
        attributes.timeLabelSize = timeLabelSize(for: message, at: indexPath)
    }

    open override func sizeForItem(at indexPath: IndexPath) -> CGSize {
        let dataSource = messagesLayout.messagesDataSource
        let message = dataSource.messageForItem(at: indexPath, in: messagesLayout.messagesCollectionView)
        let itemHeight = cellContentHeight(for: message, at: indexPath)
        return CGSize(width: messagesLayout.itemWidth, height: itemHeight)
    }

    open func cellContentHeight(for message: MessageType, at indexPath: IndexPath) -> CGFloat {

        let messageContainerHeight = messageContainerSize(for: message).height
        let cellBottomLabelHeight = cellBottomLabelSize(for: message, at: indexPath).height
        let messageBottomLabelHeight = messageBottomLabelSize(for: message, at: indexPath).height
        let cellTopLabelHeight = cellTopLabelSize(for: message, at: indexPath).height
        let messageTopLabelHeight = messageTopLabelSize(for: message, at: indexPath).height
        let messageVerticalPadding = messageContainerPadding(for: message).vertical
        let cellBottomViewHeight = cellBottomViewSize(for: message, at: indexPath).height
        let avatarHeight = avatarSize(for: message).height
        let avatarVerticalPosition = avatarPosition(for: message).vertical
        let accessoryViewHeight = accessoryViewSize(for: message).height

        switch avatarVerticalPosition {
        case .messageCenter:
            let totalLabelHeight: CGFloat = cellTopLabelHeight + messageTopLabelHeight
                + messageContainerHeight + messageVerticalPadding + messageBottomLabelHeight + cellBottomLabelHeight
            let cellHeight = max(avatarHeight, totalLabelHeight)
            return max(cellHeight, accessoryViewHeight) + cellBottomViewHeight
        case .messageBottom:
            var cellHeight: CGFloat = 0
            cellHeight += messageBottomLabelHeight
            cellHeight += cellBottomLabelHeight
            let labelsHeight = messageContainerHeight + messageVerticalPadding + cellTopLabelHeight + messageTopLabelHeight
            cellHeight += max(labelsHeight, avatarHeight)
            return max(cellHeight, accessoryViewHeight) + cellBottomViewHeight
        case .messageTop:
            var cellHeight: CGFloat = 0
            cellHeight += cellTopLabelHeight
            cellHeight += messageTopLabelHeight
            let labelsHeight = messageContainerHeight + messageVerticalPadding + messageBottomLabelHeight + cellBottomLabelHeight
            cellHeight += max(labelsHeight, avatarHeight)
            return max(cellHeight, accessoryViewHeight) + cellBottomViewHeight
        case .messageLabelTop:
            var cellHeight: CGFloat = 0
            cellHeight += cellTopLabelHeight
            let messageLabelsHeight = messageContainerHeight + messageBottomLabelHeight + messageVerticalPadding
                + messageTopLabelHeight + cellBottomLabelHeight
            cellHeight += max(messageLabelsHeight, avatarHeight)
            return max(cellHeight, accessoryViewHeight) + cellBottomViewHeight
        case .cellTop, .cellBottom, .none:
            let totalLabelHeight: CGFloat = cellTopLabelHeight + messageTopLabelHeight
                + messageContainerHeight + messageVerticalPadding + messageBottomLabelHeight
                + cellBottomLabelHeight
            let cellHeight = max(avatarHeight, totalLabelHeight)
            return max(cellHeight, accessoryViewHeight) + cellBottomViewHeight
        }
    }

    // MARK: - Avatar

    open func avatarPosition(for message: MessageType) -> AvatarPosition {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        var position = isFromCurrentSender ? outgoingAvatarPosition : incomingAvatarPosition

        switch position.horizontal {
        case .cellTrailing, .cellLeading, .none:
            break
        case .natural:
            position.horizontal = isFromCurrentSender ? .cellTrailing : .cellLeading
        }
        return position
    }

    open func avatarSize(for message: MessageType) -> CGSize {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingAvatarSize : incomingAvatarSize
    }

    // MARK: - Top cell Label

    open func cellTopLabelSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
        let layoutDelegate = messagesLayout.messagesLayoutDelegate
        let collectionView = messagesLayout.messagesCollectionView
        let height = layoutDelegate.cellTopLabelHeight(for: message, at: indexPath, in: collectionView)
        return CGSize(width: messagesLayout.itemWidth, height: height)
    }

    open func cellTopLabelAlignment(for message: MessageType) -> LabelAlignment {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingCellTopLabelAlignment : incomingCellTopLabelAlignment
    }
    
    // MARK: - Top message Label
    
    open func messageTopLabelSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
        let layoutDelegate = messagesLayout.messagesLayoutDelegate
        let collectionView = messagesLayout.messagesCollectionView
        let height = layoutDelegate.messageTopLabelHeight(for: message, at: indexPath, in: collectionView)
        return CGSize(width: messagesLayout.itemWidth, height: height)
    }
    
    open func messageTopLabelAlignment(for message: MessageType) -> LabelAlignment {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingMessageTopLabelAlignment : incomingMessageTopLabelAlignment
    }
    
    // MARK: - Bottom cell Label
    
    open func cellBottomLabelSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
        let layoutDelegate = messagesLayout.messagesLayoutDelegate
        let collectionView = messagesLayout.messagesCollectionView
        let height = layoutDelegate.cellBottomLabelHeight(for: message, at: indexPath, in: collectionView)
        return CGSize(width: messagesLayout.itemWidth, height: height)
    }
    
    open func cellBottomLabelAlignment(for message: MessageType) -> LabelAlignment {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingCellBottomLabelAlignment : incomingCellBottomLabelAlignment
    }

    // MARK: - Bottom Message Label

    open func messageBottomLabelSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
        let layoutDelegate = messagesLayout.messagesLayoutDelegate
        let collectionView = messagesLayout.messagesCollectionView
        let height = layoutDelegate.messageBottomLabelHeight(for: message, at: indexPath, in: collectionView)
        return CGSize(width: messagesLayout.itemWidth, height: height)
    }

    open func messageBottomLabelAlignment(for message: MessageType) -> LabelAlignment {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingMessageBottomLabelAlignment : incomingMessageBottomLabelAlignment
    }

    // MARK: - Cell Bottom View

    public func cellBottomViewSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
        let layoutDelegate = messagesLayout.messagesLayoutDelegate
        let collectionView = messagesLayout.messagesCollectionView
        let height = layoutDelegate.cellBottomViewHeight(for: message, at: indexPath, in: collectionView)
        return CGSize(width: messagesLayout.itemWidth, height: height)
    }

    // MARK: - Accessory View

    public func accessoryViewSize(for message: MessageType) -> CGSize {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingAccessoryViewSize : incomingAccessoryViewSize
    }

    public func accessoryViewPadding(for message: MessageType) -> HorizontalEdgeInsets {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingAccessoryViewPadding : incomingAccessoryViewPadding
    }
    
    public func accessoryViewPosition(for message: MessageType) -> AccessoryPosition {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingAccessoryViewPosition : incomingAccessoryViewPosition
    }

    // MARK: - Time Label

    open func timeLabelSize(for message: MessageType, at indexPath: IndexPath) -> CGSize {
        let layoutDelegate = messagesLayout.messagesLayoutDelegate
        let collectionView = messagesLayout.messagesCollectionView
        let dataSource = messagesLayout.messagesDataSource
        let height = layoutDelegate.timeLabelHeight(for: message, at: indexPath, in: collectionView)
        let width: CGFloat
        if let text = dataSource.timeLabelAttributedText(for: message, at: indexPath) {
            let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
            let insetWidth = isFromCurrentSender ? outgoingTimeLabelAlignment.textInsets.horizontal : incomingTimeLabelAlignment.textInsets.horizontal
            width = labelSize(for: text, considering: messagesLayout.itemWidth).width + insetWidth
        } else {
            width = messagesLayout.itemWidth
        }
        return CGSize(width: width, height: height)
    }

    open func timeLabelAlignment(for message: MessageType) -> LabelAlignment {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingTimeLabelAlignment : incomingTimeLabelAlignment
    }

    // MARK: - MessageContainer

    open func messageContainerPadding(for message: MessageType) -> UIEdgeInsets {
        let dataSource = messagesLayout.messagesDataSource
        let isFromCurrentSender = dataSource.isFromCurrentSender(message: message)
        return isFromCurrentSender ? outgoingMessagePadding : incomingMessagePadding
    }

    open func messageContainerSize(for message: MessageType) -> CGSize {
        // Returns .zero by default
        return .zero
    }

    open func messageContainerMaxWidth(for message: MessageType) -> CGFloat {
        let avatarWidth = avatarSize(for: message).width
        let messagePadding = messageContainerPadding(for: message)
        let accessoryWidth = accessoryViewSize(for: message).width
        let accessoryPadding = accessoryViewPadding(for: message)
        return messagesLayout.itemWidth - avatarWidth - messagePadding.horizontal - accessoryWidth - accessoryPadding.horizontal - avatarLeadingTrailingPadding
    }

    // MARK: - Helpers

    public var messagesLayout: MessagesCollectionViewFlowLayout {
        guard let layout = layout as? MessagesCollectionViewFlowLayout else {
            fatalError("Layout object is missing or is not a MessagesCollectionViewFlowLayout")
        }
        return layout
    }

    internal func labelSize(for attributedText: NSAttributedString, considering maxWidth: CGFloat) -> CGSize {
        let containerSize = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let boundingRect = CGRect(origin: .zero, size: containerSize)
        let textStorage = NSTextStorage(attributedString: attributedText)
        let textContainer = NSTextContainer(size: containerSize)
        textContainer.lineFragmentPadding = 0

        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        layoutManager.glyphRange(forBoundingRect: boundingRect, in: textContainer)
        textStorage.addLayoutManager(layoutManager)
        let rect = layoutManager.usedRect(for: textContainer)

        return rect.integral.size
    }
}

fileprivate extension UIEdgeInsets {
    init(top: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0) {
        self.init(top: top, left: left, bottom: bottom, right: right)
    }
}
