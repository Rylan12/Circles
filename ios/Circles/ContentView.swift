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
    @State private var showEditMessageView: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            Text("Hello, \(user.rawValue.capitalized)!")
                .font(.title)
            Button("Send Message") {

            }
            .buttonStyle(.borderedProminent)
            Button("Edit Message") {
                showEditMessageView = true
            }
            Spacer()
            Button("Logout") {
                needsLogin = true
            }
        }
        .padding()
        .fullScreenCover(isPresented: $needsLogin) {
            LoginView(selectedUser: $user, message: $message)
        }
        .fullScreenCover(isPresented: $showEditMessageView) {
            EditMessageView(selectedUser: $user, message: $message)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
