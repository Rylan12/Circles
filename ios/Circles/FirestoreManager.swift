//
//  FirestoreManager.swift
//  Circles
//
//  Created by Rylan Polster on 7/21/23.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseMessaging

class FirestoreManager {
    static var fcmToken: String?
    
    static func updateUserInfo(user: User, message: String) {
        guard let token = fcmToken else { return }
        let username = user.rawValue
        
        Firestore.firestore().collection("users").document(username).setData([
            "name": username,
            "token": token,
            "message": message
        ]) { err in
            if let err = err {
                print("Error writing to user document: \(err)")
            }
        }
    }
}
