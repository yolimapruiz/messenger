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
