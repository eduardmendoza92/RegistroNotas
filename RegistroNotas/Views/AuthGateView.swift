import SwiftUI

struct AuthGateView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var gradesManager = GradesManager()

    var body: some View {
        Group {
            if let user = authManager.user {
                GradesView(gradesManager: gradesManager, teacherId: user.uid)
                    .onAppear {
                        gradesManager.startListening(teacherId: user.uid)
                    }
                    .onDisappear {
                        gradesManager.stopListening()
                    }
            } else {
                LoginView()
            }
        }
    }
}
