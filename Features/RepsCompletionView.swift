import SwiftUI

struct RepsCompletionView: View {
    @Environment(\.dismiss) private var dismiss
    
    var set: WorkoutSet
    var targetReps: Int
    var onSave: (Int, Int?) -> Void // repsCompleted, rpe
    
    @State private var repsCompleted: String = ""
    @State private var rpe: Int = 5
    @State private var notes: String = ""
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Résultat") {
                    HStack {
                        Text("Reps prévus")
                        Spacer()
                        Text("\(targetReps)")
                            .foregroundStyle(.secondary)
                    }
                    
                    TextField("Reps complétés", text: $repsCompleted)
                        .keyboardType(.numberPad)
                    
                    if !repsCompleted.isEmpty {
                        let completed = Int(repsCompleted) ?? 0
                        let percentage = (Double(completed) / Double(targetReps)) * 100
                        HStack {
                            Text("Réussite")
                            Spacer()
                            Text("\(Int(percentage))%")
                                .foregroundStyle(percentage >= 100 ? .green : percentage >= 80 ? .orange : .red)
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                Section("Perception de l'effort") {
                    HStack {
                        Text("RPE (1-10)")
                        Spacer()
                        HStack(spacing: 10) {
                            Stepper("", value: $rpe, in: 1...10)
                                .labelsHidden()
                            Text("\(rpe)")
                                .frame(width: 30)
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.blue)
                        Text("1 = facile, 10 = très difficile")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Section("Notes (optionnel)") {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
            }
            .navigationTitle(set.exercise.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") { 
                        saveCompletion()
                    }
                    .disabled(repsCompleted.isEmpty)
                }
            }
        }
    }
    
    private func saveCompletion() {
        guard let completed = Int(repsCompleted) else {
            showError = true
            return
        }
        
        set.repsCompleted = completed
        set.rpe = rpe
        set.notes = notes.isEmpty ? nil : notes
        set.isCompleted = true
        set.completedAt = Date()
        
        onSave(completed, rpe)
        dismiss()
    }
}

#Preview {
    let exercise = Exercise(name: "Pompes", muscleGroup: "Pectoraux", type: .push)
    let set = WorkoutSet(reps: 10, exercise: exercise)
    
    RepsCompletionView(set: set, targetReps: 10) { _, _ in }
}
