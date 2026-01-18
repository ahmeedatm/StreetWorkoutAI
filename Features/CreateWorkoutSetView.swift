import SwiftUI
import SwiftData

struct CreateWorkoutSetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    // On récupère le catalogue
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    
    // On reçoit le workout parent (juste en lecture pour l'ajout, ou Bindable si besoin)
    var workout: Workout
    
    // États locaux du formulaire
    @State private var reps: Int = 10
    @State private var weight: Double?
    @State private var selectedExercise: Exercise?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Détails de la série") {
                    Picker("Exercice", selection: $selectedExercise) {
                        Text("Choisir...").tag(nil as Exercise?)
                        ForEach(exercises) { exo in
                            Text(exo.name).tag(exo as Exercise?)
                        }
                    }
                    
                    Stepper("Répétitions : \(reps)", value: $reps, in: 1...100)
                    
                    HStack {
                        Text("Poids (kg)")
                        Spacer()
                        TextField("0", value: $weight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
                
                Section {
                    Button("Ajouter la série") {
                        addSet()
                    }
                    .bold()
                    .disabled(selectedExercise == nil)
                }
            }
            .navigationTitle("Nouvelle Série")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
            }
            .onAppear {
                // Présélectionner le premier exercice si dispo
                if selectedExercise == nil {
                    selectedExercise = exercises.first
                }
            }
        }
    }
    
    func addSet() {
        guard let exercise = selectedExercise else { return }
        
        let newSet = WorkoutSet(reps: reps, weight: weight, exercise: exercise)
        
        // C'est ici qu'on lie au parent
        workout.sets.append(newSet)
        
        // On ferme la fenêtre
        dismiss()
    }
}
