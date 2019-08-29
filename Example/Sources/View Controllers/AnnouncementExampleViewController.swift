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

    var conversationMessages: [ConversationMessage] = []

    private var _dateFormatter: DateFormatter?
    var dateFormatter: DateFormatter {
        guard let formatter = _dateFormatter else {
            _dateFormatter = DateFormatter()
            return _dateFormatter!
        }
        return formatter
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initializeUI()
        conversationMessages = ConversationMessageMockFactory.getConversations()
    }

    private func initializeUI() {
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

    func displayMessageSource(from message: ConversationMessage) -> MessageDisplaySource {
        let sender = message.sender
        let sentDate = Date(timeIntervalSince1970: message.createdTs)

        let kind: MessageKind
        if message.isAnnouncement {
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
        return User.me()
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
}

extension AnnouncementExampleViewController: MessagesLayoutDelegate {
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

    // MARK: - All Messages
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        guard conversationMessages.count > indexPath.row else { fatalError("message couldn't find") }

        switch message.kind {
        case .announcement:
            return .black
        default:
            return isFromCurrentSender(message: message) ? .white : .black
        }
    }

    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        guard conversationMessages.count > indexPath.row else { fatalError("message couldn't find") }

        switch message.kind {
        case .announcement:
            return .lightGray
        case .photo:
            return .clear
        default:
            return isFromCurrentSender(message: message) ? UIColor.green : UIColor.lightGray
        }
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        guard conversationMessages.count > indexPath.row else { fatalError("message couldn't find") }
        let conversationMessage = conversationMessages[indexPath.row]
        if conversationMessage.isAnnouncement {
            return .announcement
        } else {
            return  isFromCurrentSender(message: message) ? .rightBubble : .leftBubble
        }
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard !isFromCurrentSender(message: message) else { return }

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

    func didSelectMessage(at indexPath: IndexPath, message: MessageType) {
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

extension AnnouncementExampleViewController: MessageCellDelegate {
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else { return }
        print("didTapMessage \(message.messageId)")
    }

    func didSelectURL(_ url: URL) {
        print("url selected")
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
        let me = User.me()
        let other = User.other()
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
            ConversationMessage(sender: other,
                                text: "Last announcement",
                                image: nil,
                                createdTs: Date().timeIntervalSince1970,
                                isAnnouncement: true)
        ]
    }
}

struct ConversationMessage {
    var sender: User
    var text: String?
    var image: UIImage?
    var createdTs: TimeInterval
    var isAnnouncement: Bool = false

    init(sender: User, text: String? = nil, image: UIImage? = nil,
         createdTs: TimeInterval, isAnnouncement: Bool = false) {
        self.sender = sender
        self.text = text
        self.image = image
        self.createdTs = createdTs
        self.isAnnouncement = isAnnouncement
    }
}

struct MediaItemImpl: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

struct User: SenderType {
    var senderId: String
    var displayName: String

    static func me() -> User {
        return User(senderId: "me", displayName: "my user")
    }

    static func other() -> User {
        return User(senderId: "other", displayName: "other user")
    }
}

struct MessageDisplaySource: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}
