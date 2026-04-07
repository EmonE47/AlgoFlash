import SwiftUI
import UIKit

struct AuthView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                VStack(spacing: 6) {
                    Text("AlgoFlash")
                        .font(.title)
                        .fontWeight(.semibold)
                    Text("Sign in to continue")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 16) {
                    Picker("Auth mode", selection: $viewModel.mode) {
                        ForEach(AuthViewModel.Mode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    if viewModel.mode == .signUp {
                        TextField("Full name", text: $viewModel.fullName)
                            .textContentType(.name)
                            .textInputAutocapitalization(.words)
                            .padding(12)
                            .background(Color(.systemBackground))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.separator), lineWidth: 1))
                            .cornerRadius(8)
                    }

                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(12)
                        .background(Color(.systemBackground))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.separator), lineWidth: 1))
                        .cornerRadius(8)

                    SecureField("Password", text: $viewModel.password)
                        .textContentType(viewModel.mode == .login ? .password : .newPassword)
                        .padding(12)
                        .background(Color(.systemBackground))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.separator), lineWidth: 1))
                        .cornerRadius(8)

                    if viewModel.mode == .signUp {
                        SecureField("Confirm password", text: $viewModel.confirmPassword)
                            .textContentType(.newPassword)
                            .padding(12)
                            .background(Color(.systemBackground))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.separator), lineWidth: 1))
                            .cornerRadius(8)
                    }

                    Button {
                        Task {
                            await viewModel.submit()
                        }
                    } label: {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            }
                            Text(viewModel.mode == .login ? "Login" : "Create Account")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                    .disabled(viewModel.isLoading)

                    HStack {
                        Rectangle().frame(height: 1).foregroundStyle(Color(.separator))
                        Text("or")
                            .foregroundStyle(.secondary)
                        Rectangle().frame(height: 1).foregroundStyle(Color(.separator))
                    }

                    Button {
                        Task {
                            await viewModel.continueWithGoogle(
                                presentingViewController: currentPresentationController()
                            )
                        }
                    } label: {
                        HStack(spacing: 10) {
                            Text("G")
                                .font(.headline)
                            Text("Continue with Gmail")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(.primary)
                        .background(Color(.systemBackground))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.separator), lineWidth: 1))
                        .cornerRadius(8)
                    }
                    .disabled(viewModel.isLoading)

                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(20)
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.separator), lineWidth: 1))
            }
            .padding(.horizontal, 20)
        }
    }

    private func currentPresentationController() -> UIViewController? {
        let windowScenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let rootController = windowScenes
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })?
            .rootViewController

        return rootController?.topMostController() ?? rootController
    }
}

struct HomeView: View {
    @ObservedObject var viewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Text("Welcome")
                    .font(.title2)
                    .fontWeight(.semibold)

                if !viewModel.displayName.isEmpty {
                    Text(viewModel.displayName)
                        .font(.headline)
                }

                if !viewModel.userEmail.isEmpty {
                    Text(viewModel.userEmail)
                        .foregroundStyle(.secondary)
                }

                Button("Logout") {
                    viewModel.signOut()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(24)
            .navigationTitle("AlgoFlash")
        }
    }
}

private extension UIViewController {
    func topMostController() -> UIViewController {
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.topMostController() ?? navigationController
        }

        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.topMostController() ?? tabBarController
        }

        if let presentedController = presentedViewController {
            return presentedController.topMostController()
        }

        return self
    }
}
