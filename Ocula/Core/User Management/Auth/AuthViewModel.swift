//
//  AuthViewModel.swift
//  Ocula
//
//  Created by Tyson Miles on 2/10/2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine
import GoogleSignInSwift
import GoogleSignIn

@MainActor
final class AuthViewModel: ObservableObject {
    enum SuccessContext {
        case auth
        case resetPassword
    }

    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var resetEmail: String = ""

    @Published var isLoading: Bool = false
    @Published var showLoadingSheet: Bool = false
    @Published var loadingTitle: String = "Signing In..."

    @Published var showSuccessSheet: Bool = false
    @Published var successTitle: String = "Success"
    @Published var successMessage: String = ""
    @Published var successContext: SuccessContext = .auth

    @Published var errorMessage: String?
    @Published var showForgotPassword: Bool = false

    var isEmailValid: Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.contains("@") && trimmed.contains(".") && trimmed.count >= 5
    }

    var isPasswordValid: Bool {
        password.count >= 6
    }

    var isConfirmPasswordValid: Bool {
        !confirmPassword.isEmpty && confirmPassword == password
    }

    var canSubmitLogin: Bool {
        isEmailValid && isPasswordValid && !isLoading
    }

    var canSubmitSignUp: Bool {
        isEmailValid && isPasswordValid && isConfirmPasswordValid && !isLoading
    }

    var canSubmitReset: Bool {
        let trimmed = resetEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.contains("@") && trimmed.contains(".") && trimmed.count >= 5 && !isLoading
    }

    func clearErrors() {
        errorMessage = nil
    }

    func prefillResetEmail() {
        if resetEmail.isEmpty {
            resetEmail = email
        }
    }

    func signIn() async -> Bool {
        clearErrors()
        guard isEmailValid else {
            errorMessage = "Enter a valid email address."
            return false
        }
        guard isPasswordValid else {
            errorMessage = "Password must be at least 6 characters."
            return false
        }

        loadingTitle = "Signing In..."
        showLoadingSheet = true
        isLoading = true
        do {
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
            isLoading = false
            showLoadingSheet = false
            successTitle = "Signed In"
            successMessage = "Welcome back"
            successContext = .auth
            showSuccessSheet = true
            return true
        } catch {
            isLoading = false
            showLoadingSheet = false
            errorMessage = mapAuthError(error)
            return false
        }
    }

    func signUp() async -> Bool {
        clearErrors()
        guard isEmailValid else {
            errorMessage = "Enter a valid email address."
            return false
        }
        guard isPasswordValid else {
            errorMessage = "Password must be at least 6 characters"
            return false
        }
        guard isConfirmPasswordValid else {
            errorMessage = "Passwords do not match."
            return false
        }

        loadingTitle = "Creating Account..."
        showLoadingSheet = true
        isLoading = true
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = result.user.uid
            let name = deriveDisplayName(from: email)

            let user = AppUser(
                id: uid,
                email: email,
                displayName: name,
                createdAt: Date(),
                lastLogin: Date(),
                accountType: "standard",
                onboardingComplete: false,
                driverNickname: nil,
                vehicleNickname: nil,
                vehicleBrand: nil,
                vehicleColorHex: nil
            )

            try await Firestore.firestore()
                .collection("users")
                .document(uid)
                .setData(from: user, merge: true)

            isLoading = false
            showLoadingSheet = false
            successTitle = "Account Created"
            successMessage = "Welcome to Ocula"
            successContext = .auth
            showSuccessSheet = true
            return true
        } catch {
            isLoading = false
            showLoadingSheet = false
            errorMessage = mapAuthError(error)
            return false
        }
    }

    func sendPasswordReset() async -> Bool {
        clearErrors()
        guard canSubmitReset else {
            errorMessage = "Enter a valid email address."
            return false
        }

        loadingTitle = "Sending Reset Email..."
        isLoading = true
        do {
            try await Auth.auth().sendPasswordReset(withEmail: resetEmail)
            isLoading = false
            successTitle = "Reset Email Sent"
            successMessage = "Check your inbox for the reset link."
            successContext = .resetPassword
            showSuccessSheet = true
            return true
        } catch {
            isLoading = false
            errorMessage = mapAuthError(error)
            return false
        }
    }

    func signInWithGoogle() async -> Bool {
        clearErrors()
        loadingTitle = "Connecting..."
        showLoadingSheet = true
        isLoading = true

        let provider = OAuthProvider(providerID: "google.com")
        do {
            _ = try await signIn(with: provider)
            isLoading = false
            showLoadingSheet = false
            successTitle = "Signed In"
            successMessage = "Welcome to Ocula"
            successContext = .auth
            showSuccessSheet = true
            return true
        } catch {
            isLoading = false
            showLoadingSheet = false
            errorMessage = mapAuthError(error)
            return false
        }
    }

    private func signIn(with provider: OAuthProvider) async throws -> AuthDataResult {
        try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(with: provider, uiDelegate: nil) { result, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                if let result {
                    continuation.resume(returning: result)
                    return
                }
                continuation.resume(throwing: NSError(domain: "OculaAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to sign in."]))
            }
        }
    }

    private func deriveDisplayName(from email: String) -> String {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        if let name = trimmed.split(separator: "@").first {
            return name.isEmpty ? "Driver" : String(name)
        }
        return "Driver"
    }

    private func mapAuthError(_ error: Error) -> String {
        let nsError = error as NSError
        if let code = AuthErrorCode(rawValue: nsError.code) {
            switch code {
            case .wrongPassword:
                return "Incorrect password."
            case .userNotFound:
                return "No account found for that email."
            case .emailAlreadyInUse:
                return "This email is already in use."
            case .weakPassword:
                return "Choose a stronger password with at least 6 characters."
            case .invalidEmail:
                return "That email address is invalid."
            case .networkError:
                return "Network error. Check your connection and try again."
            case .tooManyRequests:
                return "Too many attempts. Try again in a few minutes."
            case .userDisabled:
                return "This account has been disabled."
            default:
                break
            }
        }
        return nsError.localizedDescription
    }
}
