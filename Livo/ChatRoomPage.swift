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

class ChatRoomPage: MessagesViewController {

    var userUID: String?
    var channelID: String?

    let rootRef = Database.database().reference(withPath: "chatChannel")

    var messages: [Message] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }

    // MARK: - Helpers
    private func insertNewMessage(_ message: Message) {

        guard !messages.contains(message) else {
            return
        }
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

    func createUUID() -> String {

        let id = UUID().uuidString
        return id
    }

}

extension ChatRoomPage: MessagesDataSource {

    func currentSender() -> Sender {
        return Sender(id: "uuuuuiiiid", displayName: "Phil Lu")
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {

        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {

        return messages.count
    }
}

//MARK: - MessagesLayoutDelegate
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
}

//MARK: - MessagesDisplayDelegate

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

        let uuidString = UUID().uuidString
        let date = Date()

        guard let id = userUID else { return }

        let sender = Sender(id: id, displayName: "Phil")


        let message = Message(sender: sender, messageId: uuidString, sentDate: date, kind: MessageKind.text(text))

        self.insertNewMessage(message)
    }
}
