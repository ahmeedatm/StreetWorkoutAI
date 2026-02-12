import SwiftUI

struct CreateWorkoutSetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var workout: Workout
    
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @Query(filter: #Predicate<Workout> { $0.isTemplate == true }, sort: \Workout.name) private var templates: [Workout]
    
    @State private var selectedExercise: Exercise?
    @State private var reps: Int = 10
    @State private var weight: Double?
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            Form {
                Picker("Méthode", selection: $selectedTab) {
                    Text("Exercices").tag(0)
                    Text("Templates").tag(1)
                }
                .pickerStyle(.segmented)
                
                if selectedTab == 0 {
                    Section("Ajouter un exercice") {
                        Picker("Exercice", selection: $selectedExercise) {
                            ForEach(exercises) { exercise in
                                Text(exercise.name).tag(Optional(exercise))
                            }
                        }
                        
                        Stepper("Reps: \(reps)", value: $reps, in: 1...50)
                        
                        HStack {
                            Text("Poids (optionnel)")
                            Spacer()
                            TextField("kg", value: $weight, format: .number)
                                .keyboardType(.decimalPad)
                                .frame(width: 60)
                        }
                        
                        Button("Ajouter") {
                            if let selected = selectedExercise {
                                let newSet = WorkoutSet(reps: reps, weight: weight, exercise: selected, index: workout.sets.count)
                                workout.sets.append(newSet)
                                reps = 10
                                weight = nil
                            }
                        }
                        .disabled(selectedExercise == nil)
                    }
                } else {
                    Section("Copier depuis un template") {
                        ForEach(templates) { template in
                            Button {
                                copyFromTemplate(template)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(template.name ?? "Sans nom")
                                        .foregroundStyle(.primary)
                                    Text("\(template.sets.count) exercices")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Ajouter Exercices")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fait") { dismiss() }
                }
            }
        }
    }
    
    private func copyFromTemplate(_ template: Workout) {
        for (index, set) in template.sets.enumerated() {
            let copiedSet = WorkoutSet(reps: set.reps, weight: set.weight, rpe: set.rpe, exercise: set.exercise, index: index)
            workout.sets.append(copiedSet)
        }
        dismiss()
    }
}

#Preview {
    let exercise = Exercise(name: "Pompes", muscleGroup: "Pectoraux", type: .push)
    let set = WorkoutSet(reps: 10, exercise: exercise)
    let workout = Workout(name: "Test", sets: [set], scheduledAt: Date(), isTemplate: false)
    
    CreateWorkoutSetView(workout: workout)
}
