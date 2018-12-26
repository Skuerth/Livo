//
//  ChatRoomPage.swift
//  Livo
//
//  Created by Skuerth on 2018/12/19.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import UIKit
import MessageKit
import Firebase
import MessageInputBar

enum ChatMessageConnetError: Error {
    case dbError
    case convertError
}

extension ChatMessageConnetError: CustomStringConvertible {

    var description: String {

        switch self {
        case .dbError: return "Connetion Error"
        case .convertError: return "Convert Error"
        }
    }
}

class ChatRoomPage: MessagesViewController {

    var userUID: String?
    var channelID: String?
    var chatChannelRef: DatabaseReference?
    var messages: [Message] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        self.fetchMessages()
    }

    func fetchMessages() {

        guard let channelID = self.channelID else { return }

        let chatChannelRef = Database.database().reference(withPath: "chatChannel").child(channelID)
        var newMessages: [Message] = []

        chatChannelRef.observe(.value) { dataSnapshot in

            for child in dataSnapshot.children {

                if let sanpshot = child as? DataSnapshot {

                    let messageID = sanpshot.key

                    guard
                        let value = sanpshot.value as? [String: Any],
                        let content = value["content"] as? String,
                        let userID = value["publish_userID"] as? String,
                        let name = value["publish_userName"] as? String,
                        let dateString = value["sentDate"] as? String,
                        let date = self.stringConvertToDate(dateString: dateString)
                    else {
                        return
                    }

                    let sender = Sender(id: userID, displayName: name)

                    let message = Message(sender: sender, messageId: messageID, sentDate: date, kind: .text(content))

                    newMessages.append(message)

                } else {

                }

                self.messages = newMessages
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
        }

    }

    // MARK: - Helpers
    func stringConvertToDate(dateString: String) -> Date? {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"

        let date = dateFormatter.date(from: dateString)

        return date
    }

    private func insertNewMessage(_ message: Message) {

//        guard !messages.contains(message) else {
//            return
//        }
        messages.append(message)
        messages.sort()

        let isLastMessage: Bool = messages.index(of: message) == (messages.count - 1)
        let shouldScrollToBottom: Bool = messagesCollectionView.isAtBottom && isLastMessage

        messagesCollectionView.reloadData()

        if shouldScrollToBottom {
            DispatchQueue.main.async {
                self.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }

}

extension ChatRoomPage: MessagesDataSource {

    func currentSender() -> Sender {

        guard
            let emailLoginUID = Auth.auth().currentUser?.uid,
            let name = Auth.auth().currentUser?.displayName
        else {

            return Sender(id: "", displayName: "")
        }

        return Sender(id: emailLoginUID, displayName: name)
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {

        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {

        return messages.count
    }

    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {

        let displayName = messages[indexPath.item].sender.displayName

        return NSAttributedString(string: displayName, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
}

// MARK: - MessagesLayoutDelegate

extension ChatRoomPage: UITextFieldDelegate {

}
// MARK: - MessagesLayoutDelegate
extension ChatRoomPage: MessagesLayoutDelegate {

    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {

        return .zero
    }

    func footerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {

        return CGSize(width: 0, height: 8)
    }

    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {

        return 0
    }

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {

        return 20
    }
}

// MARK: - MessagesDisplayDelegate

extension ChatRoomPage: MessagesDisplayDelegate {

    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {

        return isFromCurrentSender(message: message) ? .orange : .lightGray
    }

    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {

        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? MessageStyle.TailCorner.bottomRight : MessageStyle.TailCorner.bottomLeft

        return MessageStyle.bubbleTail(corner, MessageStyle.TailStyle.curved)
    }
}

extension ChatRoomPage: MessageInputBarDelegate {

    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {

        guard
            let channelID = self.channelID,
            let messageID = Database.database().reference(withPath: channelID).childByAutoId().key,
            let emailLoginUID = Auth.auth().currentUser?.uid,
            let name = Auth.auth().currentUser?.displayName
        else {
            return
        }

        let sender = Sender(id: emailLoginUID, displayName: name)

        var message = Message(sender: sender, messageId: messageID, sentDate: Date(), kind: MessageKind.text(text))

        let ref = Database.database().reference(withPath: "chatChannel").child(channelID).child(messageID)

        ref.setValue(message.toAnyObject())

//        self.insertNewMessage(message)

        inputBar.inputTextView.text = String()

        messagesCollectionView.scrollToBottom(animated: true)

        inputBar.inputTextView.resignFirstResponder()

    }
}
