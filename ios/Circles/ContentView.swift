//
//  ContentView.swift
//  Circles
//
//  Created by Rylan Polster on 7/10/23.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("needsLogin") var needsLogin: Bool = true
    @AppStorage("user") var user: User = .choose
    @AppStorage("message") var message: String = "Tyler!"
    
    var body: some View {
        VStack {
            Spacer()
            Text("Hello, \(user.rawValue.capitalized)!")
                .font(.title)
            Button("Send Message") {
                FirebaseManager.sendMessage(user: user, message: message)
            }
            .buttonStyle(.borderedProminent)
            .padding(.bottom, 10.0)
            Text("Message:")
            TextField("Message", text: $message)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    FirebaseManager.updateUserInfo(user: user, message: message)
                }
                .submitLabel(.done)
            Spacer()
            Button("Logout") {
                needsLogin = true
            }
        }
        .padding(.horizontal, 40.0)
        .fullScreenCover(isPresented: $needsLogin) {
            LoginView(selectedUser: $user, message: $message)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
