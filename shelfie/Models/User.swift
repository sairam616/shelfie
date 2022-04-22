//
//  User.swift
//  shelfie
//
//  Created by SaiRam Avala on 2022-04-21.
//

import Foundation
import Firebase

struct User {

    let uid: String //id
    let email: String //email
    
    init(authData: Firebase.User) {

        uid = authData.uid
        email = authData.email!
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
}
