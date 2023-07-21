//
//  EditMessageView.swift
//  Circles
//
//  Created by Rylan Polster on 7/21/23.
//

import SwiftUI

struct EditMessageView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedUser: User
    @Binding var message: String
    
    var body: some View {
        VStack {
            Text("Enter Message")
                .font(.title)
            TextField("Message:", text: $message)
                .textFieldStyle(.roundedBorder)
            Button("Save") {
                FirebaseManager.updateUserInfo(user: selectedUser, message: message)
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal, 40.0)
    }
}

struct EditMessageView_Previews: PreviewProvider {
    static var previews: some View {
        EditMessageView(selectedUser: .constant(.choose), message: .constant("Tyler!"))
    }
}
