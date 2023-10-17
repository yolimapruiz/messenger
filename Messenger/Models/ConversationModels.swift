//
//  ConversationModels.swift
//  Messenger
//
//  Created by Yolima Pereira Ruiz on 17/10/23.
//

import Foundation

struct Conversation {
    let id: String
    let name:String
    let otherUserEmail: String?
    let latesMessage: LatesMessage
}

struct LatesMessage {
    let date: String
    let text: String
    let isRead: Bool
}
