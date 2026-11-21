import SwiftUI

struct GradesView: View {
    @ObservedObject var gradesManager: GradesManager
    @EnvironmentObject var authManager: AuthManager
    let teacherId: String

    @State private var studentName = ""
    @State private var carnet = ""
    @State private var gradeText = ""

    private var parsedGrade: Double? {
        guard let value = Double(gradeText.replacingOccurrences(of: ",", with: ".")) else {
            return nil
        }
        return value >= 0 && value <= 10 ? value : nil
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                entryForm

                if let errorMessage = gradesManager.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                        .padding(.top, 6)
                }

                if gradesManager.grades.isEmpty {
                    EmptyGradesView()
                } else {
                    gradesList
                }
            }
            .background(Color(red: 0.94, green: 0.97, blue: 1))
            .navigationTitle("Registro de Notas (ETPS4)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cerrar Sesión") {
                        authManager.signOut()
                        gradesManager.stopListening()
                    }
                    .font(.caption)
                }
            }
        }
    }

    private var entryForm: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ingresar Estudiante/Carnet/Nota")
                .font(.caption.bold())

            HStack(spacing: 8) {
                TextField("Nombre", text: $studentName)
                TextField("Carnet", text: $carnet)
                    .frame(width: 130)
                TextField("Nota", text: $gradeText)
                    .keyboardType(.decimalPad)
                    .frame(width: 110)
            }
            .textFieldStyle(.roundedBorder)

            HStack {
                Spacer()
                Button {
                    guard let grade = parsedGrade else {
                        gradesManager.errorMessage = "La nota debe estar entre 0 y 10."
                        return
                    }
                    Task {
                        await gradesManager.addGrade(
                            name: studentName,
                            carnet: carnet,
                            grade: grade,
                            teacherId: teacherId
                        )
                        if gradesManager.errorMessage == nil {
                            studentName = ""
                            carnet = ""
                            gradeText = ""
                        }
                    }
                } label: {
                    Label("Agregar", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .disabled(parsedGrade == nil)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
    }

    private var gradesList: some View {
        List {
            ForEach(gradesManager.grades) { grade in
                GradeRowView(grade: grade)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Task { await gradesManager.addBonus(to: grade) }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("ELIMINAR", role: .destructive) {
                            Task { await gradesManager.deleteGrade(grade) }
                        }
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}

struct EmptyGradesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.white)
                    .frame(width: 120, height: 100)
                    .shadow(color: .black.opacity(0.08), radius: 8)
                Image(systemName: "book.closed")
                    .font(.system(size: 52))
                    .foregroundStyle(.secondary)
            }
            Text("¡Aún no hay calificaciones inscritas!")
                .font(.headline)
                .multilineTextAlignment(.center)
            Text("Ingresa tu primer estudiante y nota arriba.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding()
    }
}

struct GradeRowView: View {
    let grade: Grade

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(grade.studentName)
                    .font(.headline)
                Text(grade.carnet)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            HStack(spacing: 6) {
                Text(String(format: "%.1f", grade.grade))
                    .font(.title2.bold())
                Image(systemName: grade.isApproved
                      ? "checkmark.circle.fill"
                      : "exclamationmark.triangle.fill")
                    .foregroundStyle(grade.isApproved ? .green : .red)
            }
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}
