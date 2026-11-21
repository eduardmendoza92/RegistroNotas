import Foundation
import FirebaseFirestore
import Combine

@MainActor
final class GradesManager: ObservableObject {
    @Published var grades: [Grade] = []
    @Published var errorMessage: String?

    private var listener: ListenerRegistration?
    private let database = Firestore.firestore()

    func startListening(teacherId: String) {
        stopListening()
        listener = database.collection("grades")
            .whereField("teacherId", isEqualTo: teacherId)
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }
                if let error {
                    Task { @MainActor in
                        self.errorMessage = error.localizedDescription
                    }
                    return
                }
                let grades = snapshot?.documents.compactMap {
                    try? $0.data(as: Grade.self)
                } ?? []
                Task { @MainActor in
                    self.grades = grades
                    self.errorMessage = nil
                }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
        grades = []
    }

    func addGrade(name: String, carnet: String, grade: Double, teacherId: String) async {
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanCarnet = carnet.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanName.isEmpty, !cleanCarnet.isEmpty else {
            errorMessage = "Completa el nombre y el carnet."
            return
        }

        let item = Grade(
            studentName: cleanName,
            carnet: cleanCarnet,
            grade: grade,
            teacherId: teacherId,
            createdAt: Date()
        )

        do {
            try database.collection("grades").addDocument(from: item)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addBonus(to grade: Grade) async {
        guard let id = grade.id else { return }
        do {
            try await database.collection("grades").document(id).updateData([
                "grade": grade.grade + 1
            ])
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteGrade(_ grade: Grade) async {
        guard let id = grade.id else { return }
        do {
            try await database.collection("grades").document(id).delete()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
