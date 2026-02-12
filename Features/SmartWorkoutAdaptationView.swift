import SwiftUI

struct SmartWorkoutAdaptationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var lastWorkout: Workout
    var recommendation: WorkoutRecommendation
    @State private var selectedStrategy: AdaptationStrategy = .moderate
    @State private var selectedSuggestions: Set<String> = []
    @State private var createdWorkout: Workout?
    @State private var showCreatedAlert = false
    
    var allSuggestions: [String] {
        recommendation.suggestedChanges.map { $0.reason }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Stratégie d'adaptation") {
                    Picker("Niveau de progression", selection: $selectedStrategy) {
                        Text("Conservative (petit pas)").tag(AdaptationStrategy.conservative)
                        Text("Modéré (équilibré)").tag(AdaptationStrategy.moderate)
                        Text("Agressif (défis)").tag(AdaptationStrategy.aggressive)
                    }
                    
                    Text(strategyDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Section("Appliquer les changements") {
                    ForEach(recommendation.suggestedChanges, id: \.reason) { suggestion in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(suggestion.exercise.name)
                                    .font(.headline)
                                Text(suggestion.reason)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: selectedSuggestions.contains(suggestion.reason) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selectedSuggestions.contains(suggestion.reason) ? .blue : .gray)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedSuggestions.contains(suggestion.reason) {
                                selectedSuggestions.remove(suggestion.reason)
                            } else {
                                selectedSuggestions.insert(suggestion.reason)
                            }
                        }
                    }
                }
                
                Section {
                    Button("Créer une Nouvelle Séance Adaptée") {
                        createAdaptedWorkout()
                    }
                    .disabled(selectedSuggestions.isEmpty)
                }
            }
            .navigationTitle("Adapter la Séance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
            }
            .alert("Séance créée!", isPresented: $showCreatedAlert) {
                Button("OK") { dismiss() }
            } message: {
                Text("Une nouvelle séance adaptée a été créée et programmée dans 2 jours.")
            }
        }
    }
    
    var strategyDescription: String {
        switch selectedStrategy {
        case .conservative:
            return "Changements minimes et progressifs pour un développement stable."
        case .moderate:
            return "Équilibre entre progression et récupération."
        case .aggressive:
            return "Défis importants pour un progrès rapide."
        }
    }
    
    private func createAdaptedWorkout() {
        // Filtrer les suggestions sélectionnées
        let selectedChanges = recommendation.suggestedChanges.filter { suggestion in
            selectedSuggestions.contains(suggestion.reason)
        }
        
        // Adapter les sets
        let adaptedSets = lastWorkout.sets.map { set -> WorkoutSet in
            if let suggestion = selectedChanges.first(where: { $0.exercise.id == set.exercise.id }) {
                return WorkoutSet(
                    reps: suggestion.newReps ?? set.reps,
                    weight: suggestion.newWeight ?? set.weight,
                    rpe: set.rpe,
                    exercise: set.exercise,
                    index: set.index
                )
            }
            return set
        }
        
        // Créer la nouvelle séance programmée dans 2 jours
        let scheduledDate = Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date()
        let adaptedWorkout = Workout(
            name: "\(lastWorkout.name ?? "Séance") - Adaptée",
            sets: adaptedSets,
            scheduledAt: scheduledDate,
            isTemplate: false
        )
        
        context.insert(adaptedWorkout)
        createdWorkout = adaptedWorkout
        showCreatedAlert = true
    }
}

#Preview {
    let exercise = Exercise(name: "Pompes", muscleGroup: "Pectoraux", type: .push)
    let set = WorkoutSet(reps: 10, exercise: exercise)
    let workout = Workout(name: "Test", sets: [set], scheduledAt: Date(), isTemplate: false)
    
    let suggestion = ExerciseSuggestion(
        exercise: exercise,
        changeType: .increase,
        newReps: 12,
        reason: "Bonne progression !"
    )
    
    let recommendation = WorkoutRecommendation(
        workoutId: workout,
        suggestedChanges: [suggestion],
        overallProgress: 95,
        timestamp: Date()
    )
    
    SmartWorkoutAdaptationView(lastWorkout: workout, recommendation: recommendation)
}
