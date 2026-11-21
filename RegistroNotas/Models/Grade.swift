import Foundation
import FirebaseFirestore

struct Grade: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var studentName: String
    var carnet: String
    var grade: Double
    var teacherId: String
    var createdAt: Date

    var isApproved: Bool {
        grade >= 6
    }
}
