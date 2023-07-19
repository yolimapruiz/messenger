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
        
        database.child(email).observeSingleEvent(of: .value) { DataSnapshot in
            guard DataSnapshot.value as? String  != nil else {
               completion(false)
                return
            }
            completion(true)
        }
    }
    
    /// Inserts ne user to database
    public func insertUser(with user: ChatAppUser) {
        database.child(user.emailAddress).setValue(["first_Name": user.fisrtName, "last_name": user.lastName])
    }
}

struct ChatAppUser {
    let fisrtName: String
    let lastName: String
    let emailAddress: String
//    let profilePictureUrl: String
}
