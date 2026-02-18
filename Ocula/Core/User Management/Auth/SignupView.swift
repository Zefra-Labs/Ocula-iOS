//
//  SignupView.swift
//  Ocula
//
//  Created by Tyson Miles on 1/2/2026.
//

import SwiftUI

struct SignUpView: View {
    enum Step {
        case email
        case password
        case confirm
    }

    @EnvironmentObject var session: SessionManager
    @ObservedObject var viewModel: AuthViewModel

    let onBack: () -> Void
    let onSwitchToLogin: () -> Void

    @State private var step: Step = .email
    @State private var showEmailValidation = false
    @State private var showPasswordValidation = false
    @State private var showConfirmValidation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                AuthBackButton(action: handleBack)
                    .padding(.bottom, AppTheme.Spacing.sm)
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Create An")
                            .font(AppTheme.Fonts.semibold(20))
                            .foregroundStyle(AppTheme.Colors.secondary)

                        Text("Account")
                            .font(AppTheme.Fonts.bold(36))
                            .foregroundStyle(AppTheme.Colors.primary)
                    }

                }
            }

            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                VStack(alignment: .leading, spacing: 16) {
                    if step == .email {
                        AuthTextField(
                            title: "Email",
                            placeholder: "you@ocula.com",
                            text: $viewModel.email,
                            keyboardType: .emailAddress,
                            textContentType: .emailAddress,
                            autocapitalization: .never,
                            error: emailError
                        )
                        .onChange(of: viewModel.email) { _ in
                            showEmailValidation = true
                            viewModel.clearErrors()
                        }
                    } else if step == .password {
                        AuthSecureField(
                            title: "Password",
                            placeholder: "Create a password",
                            text: $viewModel.password,
                            textContentType: .newPassword,
                            error: passwordError
                        )
                        .onChange(of: viewModel.password) { _ in
                            showPasswordValidation = true
                            viewModel.clearErrors()
                        }

                        PasswordRequirementsView(password: viewModel.password)
                    } else {
                        AuthSecureField(
                            title: "Confirm password",
                            placeholder: "Re-enter password",
                            text: $viewModel.confirmPassword,
                            textContentType: .newPassword,
                            error: confirmPasswordError
                        )
                        .onChange(of: viewModel.confirmPassword) { _ in
                            showConfirmValidation = true
                            viewModel.clearErrors()
                        }
                    }

                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if step == .email {
                AuthPrimaryButton(
                    title: "Continue",
                    isLoading: viewModel.isLoading,
                    isDisabled: !viewModel.isEmailValid,
                    action: handleContinue
                )
            } else if step == .password {
                AuthPrimaryButton(
                    title: "Continue",
                    isLoading: viewModel.isLoading,
                    isDisabled: !viewModel.isPasswordValid,
                    action: handlePasswordContinue
                )
            } else {
                AuthPrimaryButton(
                    title: "Create Account",
                    isLoading: viewModel.isLoading,
                    isDisabled: !viewModel.canSubmitSignUp,
                    action: handleSignUp
                )
            }

            Button(action: onSwitchToLogin) {
                Text("Already have an account? Log in")
                    .font(AppTheme.Fonts.semibold(13))
                    .foregroundStyle(AppTheme.Colors.secondary)
            }
            .buttonStyle(.plain)
            Rectangle()
                .fill(AppTheme.Colors.secondary.opacity(0.25))
                .frame(height: 1)
            TermsConditionsLinkConsent()
        }
        .padding(.bottom, AppTheme.Spacing.xxl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .disabled(viewModel.isLoading)
        .preferredColorScheme(.dark)
    }

    private var emailError: String? {
        if showEmailValidation && !viewModel.isEmailValid {
            return "Enter a valid email address."
        }
        return nil
    }

    private var passwordError: String? {
        if showPasswordValidation && !viewModel.isPasswordValid {
            return "Use at least 6 characters."
        }
        return nil
    }

    private var confirmPasswordError: String? {
        if showConfirmValidation && !viewModel.isConfirmPasswordValid {
            return "Passwords do not match."
        }
        return nil
    }

    private var currentStepIndex: Int {
        switch step {
        case .email: return 1
        case .password: return 2
        case .confirm: return 3
        }
    }

    private var stepProgress: CGFloat {
        CGFloat(currentStepIndex) / 3.0
    }

    private func handleBack() {
        if step == .email {
            onBack()
        } else if step == .password {
            step = .email
            showPasswordValidation = false
            showConfirmValidation = false
        } else {
            step = .password
            showConfirmValidation = false
        }
    }

    private func handleContinue() {
        showEmailValidation = true
        guard viewModel.isEmailValid else { return }
        viewModel.clearErrors()
        withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
            step = .password
        }
    }

    private func handlePasswordContinue() {
        showPasswordValidation = true
        guard viewModel.isPasswordValid else { return }
        viewModel.clearErrors()
        withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
            step = .confirm
        }
    }

    private func handleSignUp() {
        showConfirmValidation = true
        guard viewModel.canSubmitSignUp else { return }
        session.shouldDeferMainView = true
        Task {
            let success = await viewModel.signUp()
            if !success {
                session.shouldDeferMainView = false
            }
        }
    }
}
