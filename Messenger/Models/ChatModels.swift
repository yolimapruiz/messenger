//
//  ChatModels.swift
//  Messenger
//
//  Created by Yolima Pereira Ruiz on 17/10/23.
//

import Foundation
import CoreLocation
import MessageKit

struct Message: MessageType {
    public var sender: MessageKit.SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

struct Sender: SenderType {
    public var photoURL: String
    public var senderId: String
    public var displayName: String
}

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

struct Location: LocationItem {
    var location: CLLocation
    
    var size: CGSize
}

