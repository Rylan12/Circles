//
//  FirebaseManager.swift
//  Circles
//
//  Created by Rylan Polster on 7/21/23.
//

import FirebaseCore
import FirebaseFirestore
import FirebaseFunctions
import FirebaseMessaging

class MessageSendHelper: ObservableObject {
    @Published var sending: Bool = false
    @Published var failure: Bool = false
    @Published var failureMessage: String = ""
}

class FirebaseManager {
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
    
    static func sendMessage(user: User, message: String, messageSendHelper: MessageSendHelper) {
        let username = user.rawValue
        
        lazy var functions = Functions.functions()
        
        messageSendHelper.sending = true
        messageSendHelper.failure = false
        
        functions.httpsCallable("sendMessage").call(["username": username]) { result, error in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    let details = error.userInfo[FunctionsErrorDetailsKey]
                    print("Message send failure (\(String(describing: code))): \(message)\n\(String(describing: details))")
                    messageSendHelper.sending = false
                    messageSendHelper.failureMessage = message
                    messageSendHelper.failure = true
                }
            }
            if let data = result?.data as? [String: Any], let success = data["success"] as? Bool {
                print("Message send succeeded: \(success)")
                messageSendHelper.sending = false
            }
        }
    }
}
