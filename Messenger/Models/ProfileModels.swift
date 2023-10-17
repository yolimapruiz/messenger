//
//  ProfileModels.swift
//  Messenger
//
//  Created by Yolima Pereira Ruiz on 17/10/23.
//

import Foundation
enum ProfileViewModelType {
    case info, logout
    
}

struct ProfileViewModel {
    let viewModelType: ProfileViewModelType
    let title: String
    let handler: (() -> Void)?
}
