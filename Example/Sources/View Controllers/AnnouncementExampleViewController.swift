//
//  AnnouncementExampleViewController.swift
//  ChatExample
//
//  Created by Masanobu Sugawara on 2019/08/27.
//  Copyright © 2019 MessageKit. All rights reserved.
//

import MessageKit

class AnnouncementExampleViewController: MessagesViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private var conversationMessages: [ConversationMessage] = []
    
    private lazy var dateFormatter = DateFormatter()

    private let failedLabelWidth: CGFloat = 168
    private let deleteButtonWidth: CGFloat = 40
    private let retryButtonWidth: CGFloat = 40

    private let outgoingAvatarSize = CGSize(width: 20, height: 20)
    private let outgoingMessagePadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)

    override func viewDidLoad() {
        super.viewDidLoad()

        configureMessageCollectionView()
        conversationMessages = ConversationMessageMockFactory.getConversations()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        messagesCollectionView.reloadDataAndKeepOffset()
    }

    func configureMessageCollectionView() {

        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)

            layout.setMessageOutgoingAvatarSize(outgoingAvatarSize)
            layout.setMessageOutgoingAvatarPosition(.init(horizontal: .cellTrailing, vertical: .messageBottom))
            layout.setMessageOutgoingMessagePadding(outgoingMessagePadding)
        }

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
    }

    func shouldShowSenderInfo(for message: MessageType, at indexPath: IndexPath) -> Bool {
        guard conversationMessages.count > indexPath.row else { fatalError("message couldn't find") }
        let conversationMessage = conversationMessages[indexPath.row]
        if isFromCurrentSender(message: message) || conversationMessage.isAnnouncement {
            return false
        }
        guard indexPath.row > 0, conversationMessages.count > indexPath.row else { return true }

        return !isSameDateWithLastIndex(of: indexPath) || !isSameSenderWithLastIndex(of: indexPath)
    }

    private func shouldShowTopDateLabel(at indexPath: IndexPath) -> Bool {
        guard conversationMessages.count > indexPath.row else { fatalError("message couldn't find") }

        return !isSameDateWithLastIndex(of: indexPath)
    }

    private func isSameDateWithLastIndex(of indexPath: IndexPath) -> Bool {
        guard indexPath.row > 0, conversationMessages.count > indexPath.row else { return false }
        let currentMessage = conversationMessages[indexPath.row]
        let lastMessage = conversationMessages[indexPath.row - 1]

        let formatter = dateFormatter
        formatter.dateFormat = "MMdd"
        let mMddOfCurrent = formatter.string(from: Date(timeIntervalSince1970: currentMessage.createdTs))
        let mMddOfLast = formatter.string(from: Date(timeIntervalSince1970: lastMessage.createdTs))
        return mMddOfCurrent == mMddOfLast
    }

    private func isSameSenderWithLastIndex(of indexPath: IndexPath) -> Bool {
        guard indexPath.row > 0, conversationMessages.count > indexPath.row else { return false }
        let currentMessage = conversationMessages[indexPath.row]
        let lastMessage = conversationMessages[indexPath.row - 1]

        return currentMessage.sender.senderId == lastMessage.sender.senderId
    }

    private func isImageMessage(_ message: ConversationMessage) -> Bool {
        return message.image != nil
    }

    private func mediaItem(from message: ConversationMessage) -> MediaItemImpl {
        return MediaItemImpl(url: nil,
                             image: message.image,
                             placeholderImage: message.image!,
                             size: CGSize(width: 182, height: 182))
    }

    private func isfailedToSendMessage(at indexPath: IndexPath) -> Bool {
        let conversationMessage = conversationMessages[indexPath.row]
        return currentSender().senderId == conversationMessage.sender.senderId && conversationMessage.isFailed
    }

    func displayMessageSource(from message: ConversationMessage) -> MessageDisplaySource {
        let sender = message.sender
        let sentDate = Date(timeIntervalSince1970: message.createdTs)

        let kind: MessageKind
        if message.isAnnouncement || message.isWarning {
            kind = .announcement(message.text ?? "")
        } else if isImageMessage(message) {
            let media = mediaItem(from: message)
            kind = .photo(media)
        } else {
            kind = .text(message.text ?? "")
        }
        return MessageDisplaySource(sender: sender,
                                    messageId: message.sender.senderId,
                                    sentDate: sentDate,
                                    kind: kind)
    }
}

extension AnnouncementExampleViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return User.me
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        guard conversationMessages.count > indexPath.row else { fatalError("message couldn't find") }
        let m = conversationMessages[indexPath.row]
        return displayMessageSource(from: m)
    }

    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        guard shouldShowSenderInfo(for: message, at: indexPath) else { return nil }

        let conversationMessage = conversationMessages[indexPath.row]
        return NSAttributedString(string: conversationMessage.sender.displayName,
                                  attributes: [.foregroundColor: UIColor.gray,
                                               .font: UIFont.systemFont(ofSize: 12.0)])
    }

    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        guard shouldShowTopDateLabel(at: indexPath) else { return nil }

        let conversationMessage = conversationMessages[indexPath.row]
        let date = Date(timeIntervalSince1970: conversationMessage.createdTs)
        let formatter = dateFormatter
        formatter.dateFormat = "yyyy/MM/dd"
        return NSAttributedString(string: formatter.string(from: date), attributes: [.foregroundColor: UIColor.gray, .font: UIFont.boldSystemFont(ofSize: 14.0)])
    }

    func timeLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        guard conversationMessages.count > indexPath.row else { fatalError("message couldn't find") }

        let conversationMessage = conversationMessages[indexPath.row]
        let date = Date(timeIntervalSince1970: conversationMessage.createdTs)
        let formatter = dateFormatter
        formatter.dateFormat = "HH:mm"
        return NSAttributedString(string: formatter.string(from: date), attributes: [.foregroundColor: UIColor.gray, .font: UIFont.systemFont(ofSize: 11.0)])
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return 1
    }

    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        return conversationMessages.count
    }
}

extension AnnouncementExampleViewController: MessagesDisplayDelegate {

    @objc func didTapDelete(sender: UIButton) {
        print("didTapDelete index: \(sender.tag)")
    }

    @objc func didTapRetry(sender: UIButton) {
        print("didTapRetry index: \(sender.tag)")
    }

    func configureCellBottomView(_ cellBottomView: UIView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        cellBottomView.subviews.forEach { $0.removeFromSuperview() }
        guard isfailedToSendMessage(at: indexPath) else {
            return
        }

        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13.0)
        label.text = "failed to send the message"
        label.textColor = .lightGray

        let deleteButton = UIButton()
        deleteButton.setAttributedTitle(NSAttributedString(string: "delete", attributes: [.font: UIFont.systemFont(ofSize: 13.0), .foregroundColor: UIColor.purple]), for: .normal)
        deleteButton.addTarget(self, action: #selector(didTapDelete(sender:)), for: .touchUpInside)
        deleteButton.tag = indexPath.row

        let retryButton = UIButton()
        retryButton.setAttributedTitle(NSAttributedString(string: "retry", attributes: [.font: UIFont.systemFont(ofSize: 13.0), .foregroundColor: UIColor.blue]), for: .normal)
        retryButton.addTarget(self, action: #selector(didTapRetry(sender:)), for: .touchUpInside)
        retryButton.tag = indexPath.row

        cellBottomView.addSubview(label)
        cellBottomView.addSubview(deleteButton)
        cellBottomView.addSubview(retryButton)

        let maxX = cellBottomView.frame.maxX - outgoingMessagePadding.right - outgoingAvatarSize.width
        let height = cellBottomView.bounds.height

        label.frame = CGRect(x: maxX - (failedLabelWidth + retryButtonWidth + deleteButtonWidth), y: 0, width: failedLabelWidth, height: height)
        deleteButton.frame = CGRect(x: maxX - (deleteButtonWidth + retryButtonWidth), y: 0, width: deleteButtonWidth, height: height)
        retryButton.frame = CGRect(x: maxX - retryButtonWidth, y: 0, width: retryButtonWidth, height: height)
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard !isFromCurrentSender(message: message) else {
            avatarView.backgroundColor = .black
            avatarView.layer.cornerRadius = 0
            return
        }

        guard conversationMessages.count > indexPath.row else { fatalError("message couldn't find") }
        let conversationMessage = conversationMessages[indexPath.row]
        guard shouldShowSenderInfo(for: message, at: indexPath), !conversationMessage.isAnnouncement else {
            avatarView.isHidden = true
            return
        }
        avatarView.isHidden = false

        let avatar = Avatar(image: nil, initials: "S")
        avatarView.set(avatar: avatar)
    }

    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        return [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
            NSAttributedString.Key.underlineColor: UIColor.white
        ]
    }

    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url]
    }

}

extension AnnouncementExampleViewController: MessagesLayoutDelegate {
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        guard shouldShowTopDateLabel(at: indexPath) else { return 0 }

        return 40
    }

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        guard shouldShowSenderInfo(for: message, at: indexPath) else { return 0 }

        return 24
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }

    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }

    func timeLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }

    func cellBottomViewHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        guard isfailedToSendMessage(at: indexPath) else {
            return 0
        }
        return 24
    }

    // MARK: - All Messages
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        guard conversationMessages.count > indexPath.row else { fatalError("message couldn't find") }
        let conversationMessage = conversationMessages[indexPath.row]

        if conversationMessage.isWarning {
            return .red
        } else if conversationMessage.isAnnouncement {
            return .black
        } else {
            return isFromCurrentSender(message: message) ? .white : .black
        }
    }

    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        guard conversationMessages.count > indexPath.row else { fatalError("message couldn't find") }
        let conversationMessage = conversationMessages[indexPath.row]

        if conversationMessage.isWarning {
            return .white
        } else if conversationMessage.isAnnouncement {
            return .lightGray
        } else if isImageMessage(conversationMessage) {
            return .clear
        } else {
            return isFromCurrentSender(message: message) ? UIColor.green : UIColor.lightGray
        }
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        guard conversationMessages.count > indexPath.row else { fatalError("message couldn't find") }
        let conversationMessage = conversationMessages[indexPath.row]
        if conversationMessage.isWarning {
            return .warning(color: UIColor.red)
        } else if conversationMessage.isAnnouncement {
            return .announcement
        } else {
            return  isFromCurrentSender(message: message) ? .rightBubble : .leftBubble
        }
    }
}

extension AnnouncementExampleViewController: MessageCellDelegate {
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else { return }
        didSelectMessage(at: indexPath, message: message)
    }

    func didSelectURL(_ url: URL) {
        print("url selected: \(url.absoluteString)")
    }

    private func didSelectMessage(at indexPath: IndexPath, message: MessageType) {
        switch message.kind {
        case .text:
            break
        case .photo(let media):
            print("selected photo: \(media.size)")
        case .announcement:
            break
        case .attributedText:
            break
        case .custom:
            break
        default:
            break
        }
    }
}

extension UICollectionViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}

extension UICollectionView {
    func registerCell<T: UICollectionViewCell>(_ cellType: T.Type) {
        register(cellType, forCellWithReuseIdentifier: cellType.identifier)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(with cellType: T.Type, for indexPath: IndexPath) -> T {
        // swiftlint:disable force_cast
        return dequeueReusableCell(withReuseIdentifier: cellType.identifier, for: indexPath) as! T
    }
}

enum ConversationMessageMockFactory {
    static func getConversations() -> [ConversationMessage] {
        let me = User.me
        let other = User.other
        return [
            ConversationMessage(sender: other,
                                text: "First announcement",
                                image: nil,
                                createdTs: Date().timeIntervalSince1970,
                                isAnnouncement: true),
            ConversationMessage(sender: me,
                                text: "Please send a picture",
                                createdTs: Date().timeIntervalSince1970),
            ConversationMessage(sender: other,
                                text: "Here you are",
                                createdTs: Date().timeIntervalSince1970),
            ConversationMessage(sender: other,
                                image: UIImage(named: "img1"),
                                createdTs: Date().timeIntervalSince1970),
            ConversationMessage(sender: me,
                                text: "Thanks",
                                createdTs: Date().timeIntervalSince1970,
                                isFailed: true),
            ConversationMessage(sender: other,
                                text: "Last announcement",
                                image: nil,
                                createdTs: Date().timeIntervalSince1970,
                                isAnnouncement: true),
            ConversationMessage(sender: other,
                                text: "WARNING",
                                image: nil,
                                createdTs: Date().timeIntervalSince1970,
                                isWarning: true)
        ]
    }
}

struct ConversationMessage {
    let sender: User
    let text: String?
    let image: UIImage?
    let createdTs: TimeInterval
    let isAnnouncement: Bool
    let isWarning: Bool
    let isFailed: Bool

    init(sender: User, text: String? = nil, image: UIImage? = nil,
         createdTs: TimeInterval, isAnnouncement: Bool = false, isWarning: Bool = false,
         isFailed: Bool = false) {
        self.sender = sender
        self.text = text
        self.image = image
        self.createdTs = createdTs
        self.isAnnouncement = isAnnouncement
        self.isWarning = isWarning
        self.isFailed = isFailed
    }
}

struct MediaItemImpl: MediaItem {
    let url: URL?
    let image: UIImage?
    let placeholderImage: UIImage
    let size: CGSize
}

struct User: SenderType {
    let senderId: String
    let displayName: String

    static let me = User(senderId: "me", displayName: "my user")
    static let other = User(senderId: "other", displayName: "other user")
}

struct MessageDisplaySource: MessageType {
    let sender: SenderType
    let messageId: String
    let sentDate: Date
    let kind: MessageKind
}
