//
//  AuthView.swift
//  Ocula
//
//  Created by Tyson Miles on 1/2/2026.
//


struct AuthView: View {

    @State private var showSignup = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Ocula One")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("AI-powered driving intelligence")
                .foregroundStyle(.secondary)

            if showSignup {
                SignupView()
            } else {
                LoginView()
            }

            Button(showSignup ? "Already have an account?" : "Create an account") {
                showSignup.toggle()
            }
        }
        .padding()
    }
}
