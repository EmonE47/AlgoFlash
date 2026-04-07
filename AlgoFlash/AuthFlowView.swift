//
//  AuthFlowView.swift
//  AlgoFlash
//
//

import SwiftUI

private enum AuthScreen {
    case entry
    case login
    case register
}

struct AuthFlowView: View {
    @StateObject private var authModel = AuthenticationViewModel()
    @State private var screen: AuthScreen = .entry
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    var body: some View {
        ZStack {
            AuthBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 28) {
                    header
                    activePanel
                    footerNote
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 28)
            }
        }
        .animation(.spring(response: 0.42, dampingFraction: 0.86), value: screen)
        .animation(.spring(response: 0.42, dampingFraction: 0.86), value: authModel.currentSession?.id)
        .task {
            authModel.loadSession()
        }
    }

    private var header: some View {
        AuthHeaderView(isSignedIn: authModel.currentSession != nil)
    }

    @ViewBuilder
    private var activePanel: some View {
        if let session = authModel.currentSession {
            SignedInPanel(session: session, onSignOut: signOut)
                .transition(panelTransition)
        } else {
            switch screen {
            case .entry:
                EntryPanel(
                    onLoginTap: { screen = .login },
                    onRegisterTap: { screen = .register }
                )
                .transition(panelTransition)

            case .login:
                LoginPanel(
                    email: $email,
                    password: $password,
                    isBusy: authModel.isBusy,
                    onLogin: login,
                    onGoogle: googleSignIn,
                    onSwap: { screen = .register },
                    onBack: { screen = .entry }
                )
                .transition(panelTransition)

            case .register:
                RegisterPanel(
                    fullName: $fullName,
                    email: $email,
                    password: $password,
                    confirmPassword: $confirmPassword,
                    isBusy: authModel.isBusy,
                    onRegister: register,
                    onGoogle: googleSignIn,
                    onSwap: { screen = .login },
                    onBack: { screen = .entry }
                )
                .transition(panelTransition)
            }
        }
    }

    private var footerNote: some View {
        ConnectionStatusCard(
            statusMessage: authModel.statusMessage,
            errorMessage: authModel.errorMessage,
            isFirebaseReady: authModel.isFirebaseReady,
            isBusy: authModel.isBusy
        )
    }

    private var panelTransition: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        )
    }

    private func login() {
        Task {
            await authModel.signIn(email: email, password: password)
            if authModel.currentSession != nil {
                clearSensitiveFields()
            }
        }
    }

    private func register() {
        Task {
            await authModel.register(
                fullName: fullName,
                email: email,
                password: password,
                confirmPassword: confirmPassword
            )

            if authModel.currentSession != nil {
                clearSensitiveFields()
            }
        }
    }

    private func googleSignIn() {
        Task {
            await authModel.signInWithGoogle()
            if authModel.currentSession != nil {
                clearSensitiveFields()
            }
        }
    }

    private func signOut() {
        authModel.signOut()
        screen = .entry
        clearAllFields()
    }

    private func clearSensitiveFields() {
        password = ""
        confirmPassword = ""
    }

    private func clearAllFields() {
        fullName = ""
        email = ""
        clearSensitiveFields()
    }
}

#Preview {
    AuthFlowView()
}
