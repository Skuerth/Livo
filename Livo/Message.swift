//
//  Message.swift
//  ChatRoomTest
//
//  Created by Skuerth on 2018/12/18.
//  Copyright © 2018 Skuerth. All rights reserved.
//

import Foundation
import MessageKit
import Firebase

struct Message: MessageType {


    var sender: Sender
    var messageId: String
    var sentDate: Date
    var kind: MessageKind

    init(sender: Sender, messageId: String, sentDate: Date, kind: MessageKind) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = sentDate
        self.kind = kind
    }
}

extension Message: Comparable {

    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.sender.id == rhs.sender.id
    }

    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
}
