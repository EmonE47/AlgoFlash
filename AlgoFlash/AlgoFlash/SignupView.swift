import SwiftUI

struct SignupView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.largeTitle)
                .bold()
                .padding(.bottom, 20)
            
            VStack(spacing: 15) {
                TextField("Full Name", text: $fullName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                TextField("Email", text: $email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button {
                viewModel.register(email: email, password: password, fullName: fullName)
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Sign Up")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .disabled(viewModel.isLoading)
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.gray)
                    Text("Log In")
                        .bold()
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(.top, 50)
    }
}