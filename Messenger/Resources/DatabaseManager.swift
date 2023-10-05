//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Yolima Pereira Ruiz on 16/07/23.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    //esto es un singleton dice que para acceso de escritura y lectura mas sencillo
    
    static let shared = DatabaseManager() //esta es la instancia de la base de datos
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")  //esto se hace porque el child no puede tener . ni @
        safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
}

// MARK: - Account Management

extension DatabaseManager {
    
    public func userExists (with email: String, completion: @escaping ((Bool) -> Void)){
        //true if the user doesn't exist
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")  //esto se hace porque el child no puede tener . ni @
        safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { DataSnapshot in
            guard DataSnapshot.value as? String  != nil else {
               completion(false)
                return
            }
            completion(true)
        }
    }
    
    /// Inserts new user to database
    public func insertUser(with user: ChatAppUser, completion: @escaping(Bool) -> Void) {
        database.child(user.safeEmail).setValue(["first_Name": user.fisrtName,
                                                 "last_name": user.lastName]) { error, _ in
            guard error == nil else {
                print("failed to write to database")
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value) { snapshot, _ in
                if var userCollection = snapshot.value as? [[String: String]] {
                    //usamos if var en lugar de if let porque queremos que sea mutable
                    //append to user dictionary
                    let newElement = [
                        "name": user.fisrtName + " " + user.lastName,
                         "email": user.safeEmail
                    ]
                    userCollection.append( newElement)
                    
                    self.database.child("users").setValue(userCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        //se agrego un completion a funcion de insert user para que avise al usuario cuando se termine de hacer y pueda subir su foto
                        completion(true)
                    }
                }
                else {
                    //create that array
                    let newCollection: [[String: String]] = [
                        [
                        "name": user.fisrtName + " " + user.lastName,
                         "email": user.safeEmail
                        ]
                    ]
                    self.database.child("users").setValue(newCollection) { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        //se agrego un completion a funcion de insert user para que avise al usuario cuando se termine de hacer y pueda subir su foto
                        completion(true)
                    }
                }
            }
        }
    }
    
    public func getAllUsers(completion: @escaping(Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { snapshot, _ in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        
        }
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
}

// MARK: -Sending messages/ conversations
extension DatabaseManager {
    /*
     "abcdef" {
        "messages": [
            {
                "id": String,
                "type": text, video, photo
                "content": String,
                "date": Date(),
                "sender_email": String,
                "isRead": true/false,
            }
        ]
     }
     conversation => [
        [
            "conversation_id":"abcdef"
            "other_user_email":
            "latest_message": => {
                "date": Date()
                "latest_message": "message"
                "is_read": true/false
            }
        ],
        [
         "conversation_id": "ghijklmo"
         "other_user_email":
         "latest_message": => {
             "date": Date()
             "latest_message": "message"
             "is_read": true/false
         }
        ]
     ]
     */
    
    
    
    ///Creates a new conversation with target user email and first message sent
    public func createsNewConversation(with otherUserEmail: String,
                                       name: String,
                                       firstMessage: Message,
                                       completion: @escaping (Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        let ref = database.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("user not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
                
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationID = "conversation_ \(firstMessage.messageId)"
            
            let newConversationData = [
                "id": conversationID,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date":dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            let recipient_newConversationData = [
                "id": conversationID,
                "other_user_email": safeEmail, //our email(the sender)
                "name": "self",
                "latest_message": [
                    "date":dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            //update recepient conversation entry
            
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: {[weak self] snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    //append
                    conversations.append(recipient_newConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversations)
                }
                else {
                    //creation
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                }
            })
            
            
            //update current user conversation entry
            
            if var conversations = userNode["conversations"] as? [[String : Any]] {
                //conversation array exists for a current user
                //you should append
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name,
                                                     conversationID: conversationID,
                                                    firstMessage: firstMessage,
                                                    completion: completion)
                }
            }
            else {
                //conversation array
                //create new conversation
                userNode["conversations"] = [ newConversationData ]
             
                ref.setValue(userNode) { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name,
                                                     conversationID: conversationID,
                                                    firstMessage: firstMessage,
                                                    completion: completion)
                   
                }
            }
            
        }
        
    }
    
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping(Bool) -> Void) {
//        {  "id": String,
//            "type": text, video, photo
//            "content": String,
//            "date": Date(),
//            "sender_email": String,
//            "isRead": true/false
//        }
        
        var message = ""
        
        switch firstMessage.kind {
            
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        let collectionMessage: [String: Any] = [
        
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false,
            "name": name
        
        ]
        
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            
            ]
        
        ]
        database.child("\(conversationID)").setValue(value) { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            
            completion(true)
        }
    }
    
    ///Fetches and returns all conversations for the user with passed in email
    public func getAllConverations(for email: String, completion: @escaping(Result<[Conversation], Error>) -> Void) {
        database.child("\(email)/conversations").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversations: [Conversation] = value.compactMap { dictionary in
                //comprobar que tenga todas las keys
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latesMessage = dictionary["latest_message"] as? [String: Any],
                      let sent = latesMessage["date"] as? String,
                      let message = latesMessage["message"] as? String,
                      let isRead = latesMessage["is_read"] as? Bool else {
                    print("no consegui la conversation")
                    return nil
                }
                
                let latesMessageObject = LatesMessage(date: sent,
                                                      text: message,
                                                      isRead: isRead)
                
                return Conversation(id: conversationId,
                                    name: name,
                                    otherUserEmail: otherUserEmail,
                                    latesMessage: latesMessageObject)
            }
            
            completion(.success(conversations))
        }
    }
    
    ///Gets all messages for a given conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child("\(id)/messages").observe(.value) { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let messages: [Message] = value.compactMap { dictionary in
                //comprobar que tenga todas las keys
                guard  let name = dictionary["name"] as? String,
                       
                       let isRead = dictionary["is_read"] as? Bool,
                       let messageId = dictionary["id"] as? String,
                       let content = dictionary["content"] as? String,
                       let senderEmail = dictionary["sender_email"] as? String,
                       let type = dictionary["type"] as? String,
                       let dateString = dictionary["date"] as? String,
                       let date = ChatViewController.dateFormatter.date(from: dateString) else {
                    print("no consegui ningun mensaje")
                    return nil
                }
                
                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)
                
                return Message(sender: sender,
                               messageId: messageId,
                               sentDate: date,
                               kind: .text(content))
                
            }
            
            completion(.success(messages))
        }
        
    }
    
    ///Sends a message with target conversation and message
    public func sendMessage(to conversation: String, message: Message, completion: @escaping (Bool) -> Void) {
        
    }
    
}


struct ChatAppUser {
    let fisrtName: String
    let lastName: String
    let emailAddress: String
//    let profilePictureUrl: String
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")  //esto se hace porque el child no puede tener . ni @
        safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
}
