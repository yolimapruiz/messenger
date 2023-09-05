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
            
            //se agrego un completion a funcion de insert user para que avise al usuario cuando se termine de hacer y pueda subir su foto
            completion(true)
            
            
        }
    }
}

struct ChatAppUser {
    let fisrtName: String
    let lastName: String
    let emailAddress: String
//    let profilePictureUrl: String
    
    //create a computed property
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")  //esto se hace porque el child no puede tener . ni @
        safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    var profilePictureFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
}
