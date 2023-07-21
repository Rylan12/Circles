//
//  LoginView.swift
//  Circles
//
//  Created by Rylan Polster on 7/20/23.
//

import SwiftUI

enum User: String, CaseIterable, Identifiable, Codable {
    case choose, abbie, rylan
    var id: Self { self }
}

struct LoginView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedUser: User
    @Binding var message: String
    
    var body: some View {
        VStack {
            Text("What is your name?")
                .font(.title)
            Picker("User", selection: $selectedUser) {
                if (selectedUser == .choose) {
                    Text("Choose").tag(User.choose)
                }
                Text("Abbie").tag(User.abbie)
                Text("Rylan").tag(User.rylan)
            }
            Button("Login") {
                FirebaseManager.updateUserInfo(user: selectedUser, message: message)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedUser == .choose)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(selectedUser: .constant(.choose), message: .constant("Tyler!"))
    }
}
