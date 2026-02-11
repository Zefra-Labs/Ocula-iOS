//
//  AuthView.swift
//  Ocula
//
//  Created by Tyson Miles on 1/2/2026.
//

import SwiftUI


struct AuthView: View {
    enum Mode {
        case landing
        case login
        case signUp
    }

    @EnvironmentObject var session: SessionManager
    @StateObject private var viewModel = AuthViewModel()
    @State private var mode: Mode = .landing
    @State private var animateIcon = false

    var body: some View {
        ZStack {
            AppTheme.Colors.background
                .ignoresSafeArea()

            GeometryReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        switch mode {
                        case .landing:
                            AuthLandingView(
                                onLogin: { setMode(.login) },
                                onSignUp: { setMode(.signUp) },
                                onGoogle: handleGoogleSignIn
                            )
                            .transition(.move(edge: .leading).combined(with: .opacity))

                        case .login:
                            LoginView(
                                viewModel: viewModel,
                                onBack: { setMode(.landing) },
                                onForgotPassword: {
                                    viewModel.prefillResetEmail()
                                    viewModel.showForgotPassword = true
                                },
                                onSwitchToSignUp: { setMode(.signUp) }
                            )
                            .transition(.move(edge: .trailing).combined(with: .opacity))

                        case .signUp:
                            SignUpView(
                                viewModel: viewModel,
                                onBack: { setMode(.landing) },
                                onSwitchToLogin: { setMode(.login) }
                            )
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                    .frame(minHeight: proxy.size.height, alignment: .top)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.vertical, AppTheme.Spacing.lg)
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.88), value: mode)
        .sheet(isPresented: $viewModel.showForgotPassword) {
            ForgotPasswordView(viewModel: viewModel)
                .presentationDetents([.height(300)])
        }
        .oculaAlertSheet(
            isPresented: $viewModel.showLoadingSheet,
            icon: "circle.dotted",
            iconTint: AppTheme.Colors.accent,
            title: viewModel.loadingTitle,
            message: "",
            showsIconRing: false,
            iconModifier: { image in
                AnyView(image.symbolRenderingMode(.hierarchical))
            },
            iconAnimator: { image, _ in
                if #available(iOS 17.0, *) {
                    return AnyView(
                        image.symbolEffect(.rotate.byLayer, options: .repeat(.continuous))
                    )
                } else {
                    return AnyView(image)
                }
            },
            iconAnimationActive: true
        )
        .oculaAlertSheet(
            isPresented: $viewModel.showSuccessSheet,
            icon: "checkmark",
            iconTint: .green,
            title: viewModel.successTitle,
            message: viewModel.successMessage,
            showsIconRing: false,
            iconAnimationActive: animateIcon,
            autoDismissAfter: 1.8,
            onAutoDismiss: {
                if viewModel.successContext == .auth {
                    session.shouldDeferMainView = false
                }
                viewModel.showSuccessSheet = false
            }
        )
        .oculaAlertSheet(
            isPresented: $session.showSignOutSuccess,
            icon: "checkmark",
            iconTint: .green,
            title: "Success",
            message: "",
            showsIconRing: false,
            iconAnimationActive: animateIcon,
            autoDismissAfter: 1.5
        )
        .onChange(of: viewModel.showSuccessSheet) { newValue in
            if newValue {
                animateIcon = true
            }
        }
    }

    private func setMode(_ newMode: Mode) {
        viewModel.clearErrors()
        viewModel.confirmPassword = ""
        withAnimation(.spring(response: 0.5, dampingFraction: 0.88)) {
            mode = newMode
        }
    }

    private func handleGoogleSignIn() {
        session.shouldDeferMainView = true
        Task {
            let success = await viewModel.signInWithGoogle()
            if !success {
                session.shouldDeferMainView = false
            }
        }
    }
}

private struct AuthLandingView: View {
    let onLogin: () -> Void
    let onSignUp: () -> Void
    let onGoogle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome to")
                        .font(AppTheme.Fonts.semibold(20))
                        .foregroundStyle(AppTheme.Colors.secondary)

                    Text("Ocula by Zefra")
                        .font(AppTheme.Fonts.bold(36))
                        .foregroundStyle(AppTheme.Colors.primary)
                    
                }
                .padding(.top, AppTheme.Spacing.authButton)


            }

            Text("Your intelligent driving companion.")
                .font(AppTheme.Fonts.regular(16))
                .foregroundStyle(AppTheme.Colors.secondary)

            Spacer(minLength: 24)

            VStack(alignment: .leading, spacing: 12) {
                AuthPrimaryGhostButton(title: "Log In", action: onLogin)
                AuthGhostButton(title: "Sign Up", action: onSignUp)

                AuthDivider()
                    .padding(.vertical, 6)

                Button(action: onGoogle) {
                    HStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "globe")
                            .frame(width: 22, height: 22)
                        Text("Continue with Google")
                            .font(AppTheme.Fonts.semibold(15))
                        Spacer()
                    }
                    .foregroundStyle(AppTheme.Colors.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .padding(.horizontal, 16)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.Radius.xlg, style: .continuous)
                            .stroke(AppTheme.Colors.secondary.opacity(0.35), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.bottom, AppTheme.Spacing.xxl)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    AuthView()
        .environmentObject(SessionManager())
}
