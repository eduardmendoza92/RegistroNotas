import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var isRegistering = false

    var body: some View {
        ZStack {
            Color(red: 0.93, green: 0.96, blue: 1).ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: 88, height: 88)
                            .shadow(color: .black.opacity(0.08), radius: 10)
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(.blue)
                    }
                    Text("CONEXIÓN\nDOCENTE - ETPS4")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 14) {
                    TextField("Correo Institucional", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                    SecureField("Contraseña Docente", text: $password)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.15))
                )

                if let errorMessage = authManager.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Button {
                    Task {
                        if isRegistering {
                            await authManager.signUp(email: email, password: password)
                        } else {
                            await authManager.signIn(email: email, password: password)
                        }
                    }
                } label: {
                    if authManager.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text(isRegistering ? "CREAR CUENTA" : "INGRESAR SISTEMA")
                    }
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(red: 0.24, green: 0.49, blue: 0.78))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .disabled(email.isEmpty || password.isEmpty || authManager.isLoading)
                .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1)

                Button {
                    withAnimation {
                        isRegistering.toggle()
                        authManager.errorMessage = nil
                    }
                } label: {
                    Text(isRegistering
                         ? "¿Ya tienes cuenta? Inicia sesión"
                         : "¿No tienes cuenta? Regístrate aquí")
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                }

                Spacer()
            }
            .padding(.horizontal, 28)
        }
    }
}
