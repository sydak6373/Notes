//
//  UserDTO.swift
//  Notes
//
//  Created by JoyDev on 29.11.2023.
//

import Foundation

struct UserDTO {
    let login: String
    let password: String
    let email: String
    
    init(from model: UserDataModel) {
        self.login = model.login
        self.email = model.email
        self.password = model.password
    }
    
    init(from model: UserEntity) {
        self.login = model.login ?? ""
        self.email = model.email ?? ""
        self.password = model.password ?? ""
    }
}
