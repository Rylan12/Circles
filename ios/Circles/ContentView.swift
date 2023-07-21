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
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, \(user.rawValue.capitalized)!")
            Toggle(isOn: $needsLogin) {
                Text("Test")
            }
            Button("Clear Saved Information") {
                if let bundleID = Bundle.main.bundleIdentifier {
                    UserDefaults.standard.removePersistentDomain(forName: bundleID)
                }
            }
        }
        .padding()
        .fullScreenCover(isPresented: $needsLogin) {
            LoginView(selectedUser: $user)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
