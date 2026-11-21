import SwiftUI
import FirebaseCore

@main
struct RegistroNotasApp: App {
    @StateObject private var authManager = AuthManager()

    init() {
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }

    var body: some Scene {
        WindowGroup {
            AuthGateView()
                .environmentObject(authManager)
        }
    }
}
