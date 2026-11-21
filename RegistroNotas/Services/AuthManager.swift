import Foundation
import FirebaseAuth
import Combine

@MainActor
final class AuthManager: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var authListener: AuthStateDidChangeListenerHandle?

    init() {
        user = Auth.auth().currentUser
        authListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.user = user
            }
        }
    }

    deinit {
        if let authListener {
            Auth.auth().removeStateDidChangeListener(authListener)
        }
    }

    func signIn(email: String, password: String) async {
        await authenticate {
            try await Auth.auth().signIn(withEmail: email, password: password)
        }
    }

    func signUp(email: String, password: String) async {
        await authenticate {
            try await Auth.auth().createUser(withEmail: email, password: password)
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func authenticate(_ operation: @escaping () async throws -> AuthDataResult) async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            _ = try await operation()
        } catch {
            errorMessage = AuthErrorMapper.message(for: error)
        }
        isLoading = false
    }
}

enum AuthErrorMapper {
    static func message(for error: Error) -> String {
        let nsError = error as NSError
        if let code = AuthErrorCode(rawValue: nsError.code) {
            switch code {
            case .invalidEmail:
                return "El correo electrónico no tiene un formato válido."
            case .emailAlreadyInUse:
                return "Este correo ya está registrado."
            case .weakPassword:
                return "La contraseña debe tener al menos 6 caracteres."
            case .wrongPassword, .invalidCredential:
                return "Correo o contraseña incorrectos."
            case .userNotFound:
                return "No existe una cuenta con este correo."
            case .networkError:
                return "No hay conexión con el servidor."
            default:
                break
            }
        }
        return error.localizedDescription
    }
}
