//
//  ChatViewController.swift
//  Messenger
//
//  Created by Yolima Pereira Ruiz on 20/08/23.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage
import AVFoundation
import AVKit
import CoreLocation

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

extension MessageKind {
    var messageKindString: String {
        switch self {
            
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}

class ChatViewController: MessagesViewController {
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    public var isNewConversation = false
    private let otherUserEmail: String
    public var conversationID: String?
    
    private var messages = [Message]()
    
    private var selfSender: Sender? {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
           
            print("no tengo email")
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        //print("tengo \(email)")
        return Sender(photoURL: "",
                      senderId: safeEmail ,
               displayName: "me")
    }

    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id) { [weak self] result in
            switch result {
                
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToBottom()
                    }
                    
                }
            case .failure(let error):
                print("failed to get messages: \(error)")
            }
        }
    }
    
    init(with email: String, id: String?) {
        self.conversationID = id
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        Swift.fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messageCellDelegate = self
        setupInputButton()
    }
    
    private func setupInputButton() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside { [weak self] __ in
            self?.presentInputAccionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    private func presentInputAccionSheet(){
        let actionSheet = UIAlertController(title: "Attach Media",
                                            message: "What would you like to attach?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoInputActionsheet()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Video", style: .default, handler: { [weak self] _ in
            self?.presentVideoInputActionsheet()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Audio", style: .default, handler: { [weak self] _ in
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Location", style: .default, handler: { [weak self] _ in
            self?.presentLocationPicker()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    private func presentLocationPicker() {
        let vc = LocationPickerViewController(coordinates: nil)
        vc.title = "Pick Location"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = {[weak self] selectedCoordinates in
            guard let strongSelf = self else {
                return
            }
            guard let messageId = strongSelf.createMessageId(),
                  let conversationId = strongSelf.conversationID,
                  let name = strongSelf.title,
                  let selfSender = strongSelf.selfSender else {
                return
            }
            
            let longitude:  Double = selectedCoordinates.longitude
            let latitude: Double = selectedCoordinates.latitude
            print("Las coordenadas son: long= \(longitude) | lat= \(latitude)")
            
            let location = Location(location: CLLocation(latitude: latitude, longitude: longitude),
                                 size: .zero)
            
            let message = Message(sender: selfSender,
                                  messageId: messageId,
                                  sentDate: Date(),
                                  kind: .location(location))
            
            DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message) { success in
                if success {
                    print("Sent location message")
                }
                else {
                    print("failed to send location message")
                }
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func presentPhotoInputActionsheet() {
        let actionSheet = UIAlertController(title: "Attach Photo",
                                            message: "Where would you like to attach a photo from?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true //will force the user to crop a square
            self?.present(picker, animated: true)
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true //will force the user to crop a square
            self?.present(picker, animated: true)
            
        }))
        
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    private func presentVideoInputActionsheet() {
        let actionSheet = UIAlertController(title: "Attach Video",
                                            message: "Where would you like to attach a video from?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.allowsEditing = true //will force the user to crop a square
            self?.present(picker, animated: true)
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Library", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .savedPhotosAlbum
            picker.delegate = self
            picker.allowsEditing = false //will force the user to crop a square
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            self?.present(picker, animated: true)
            
        }))
        
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        messageInputBar.inputTextView.becomeFirstResponder() // para que se despliege por defecto el teclado cuando carge la view
        if let conversationID = conversationID {
            listenForMessages(id: conversationID, shouldScrollToBottom: true)
        }
    }
    
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId = createMessageId() else {
            return
        }
    
        print("sending : \(text)")
     
        let message = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        //send message
        
        if isNewConversation {
            //create convo in database
            print("estoy creando la nueva conversacion")
            DatabaseManager.shared.createsNewConversation(with: otherUserEmail,
                                                          name: self.title ?? "User",
                                                          firstMessage: message) { [weak self] success in
                if success {
                    print("message sent")
                    self?.isNewConversation = false
                    let newConversationId = "conversation_\(message.messageId)"
                    self?.conversationID = newConversationId
                    self?.listenForMessages(id: newConversationId, shouldScrollToBottom: true)
                
                    DispatchQueue.main.async {
                        self?.messageInputBar.inputTextView.text = nil
                    }
                    
                }
                else {
                    print("failed to send")
                }
            }
        } else {
            guard let conversationID = conversationID,
                    let name = self.title else {
                print("no es una conversacion nueva")
                return
            }
            //append to existing conversation data
            DatabaseManager.shared.sendMessage(to: conversationID, otherUserEmail: otherUserEmail, name: name, newMessage: message) { success in
                if success {
                    print("message sent")
                }
                else {
                    print("failed to send")
                }
            }
        }
    }
    
    private func createMessageId () -> String? {
        //date, otherUserEmail, senderEmail
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let dateString = Self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        
        return newIdentifier
    }
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true)
        guard let messageId = createMessageId(),
        let conversationId = conversationID,
        let name = self.title,
        let selfSender = self.selfSender else {
            
            return
        }
        
        if let image = info[.editedImage] as? UIImage, let imageData = image.pngData() {
            let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "_") + ".png"
            //upload image
            StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName) { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                
                switch result {
                    
                case .success(let urlString):
                    //ready to send
                    print("Uploaded Message Photo: \(urlString)")
                    
                    guard let url = URL(string: urlString),
                          let placeholder = UIImage(systemName: "plus") else {
                        return
                    }
                            
                    
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)
                    
                    let message = Message(sender: selfSender,
                                          messageId: messageId,
                                          sentDate: Date(),
                                          kind: .photo(media))
                    
                    DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message) { success in
                        if success {
                            print("Sent photo message")
                        }
                        else {
                            print("failed to send photo message")
                        }
                    }
                    
                case .failure(let error):
                    print("message photo upload error: \(error)")
                }
            }
        }
        else if let videoUrl = info[.mediaURL] as? URL {
            let fileName = "video_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".mov"
           
            
            //upload video
           
            StorageManager.shared.uploadMessageVideo(with: videoUrl, fileName: fileName) { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                
                switch result {
                    
                case .success(let urlString):
                    //ready to send
                    print("Uploaded Message Video: \(urlString)")
                    
                    guard let url = URL(string: urlString),
                          let placeholder = UIImage(named: "video_placeholder") else {
                        print("no se creo el placeholder")
                        return
                    }
                            
                    print(" se creo el placeholder")
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)
                    
                    let message = Message(sender: selfSender,
                                          messageId: messageId,
                                          sentDate: Date(),
                                          kind: .video(media))
                    
                    DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message) { success in
                        if success {
                            print("Sent video message")
                        }
                        else {
                            print("failed to send video message")
                        }
                    }
                    break
                    
                case .failure(let error):
                    print("message video upload error: \(error)")
                }
            }
            
        }
        
       
        //send message
    }
}
extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> MessageKit.SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self sender is nil, email should be catched")
        
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        
        switch message.kind {
            
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            break
        }
    }
    
   
}

extension ChatViewController: MessageCellDelegate {
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let message = messages[indexPath.section]
        switch message.kind {
            
        case .location(let locationData):
            let coordinates = locationData.location.coordinate
            let vc = LocationPickerViewController(coordinates: coordinates)
            vc.title = "Location"
            
            self.navigationController?.pushViewController(vc, animated: true)
            
        default:
            break
        }
    }
        
        func didTapImage(in cell: MessageCollectionViewCell) {
            guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
                return
            }
            let message = messages[indexPath.section]
            switch message.kind {
                
            case .photo(let media):
                guard let imageUrl = media.url else {
                    return
                }
                
                let vc = PhotoViwerViewController(with: imageUrl)
                self.navigationController?.pushViewController(vc, animated: true)
                
            case .video(let media):
                guard let videoUrl = media.url else {
                    return
                }
                
                let vc = AVPlayerViewController()
                vc.player = AVPlayer(url: videoUrl)
                present(vc, animated: true)
                
                
            default:
                break
            }
        }
    }
