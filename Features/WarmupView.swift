import SwiftUI

struct WarmupView: View {
    @Environment(\.dismiss) private var dismiss
    
    var workout: Workout
    @State private var currentWarmupIndex: Int = 0
    @State private var isCompleted: Bool = false
    
    // Exercices d'échauffement générés automatiquement
    var warmupExercises: [(name: String, reps: Int, icon: String, description: String)] {
        generateWarmupPlan()
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if isCompleted {
                    completedView
                } else {
                    VStack(spacing: 30) {
                        // Barre de progression
                        ProgressView(value: Double(currentWarmupIndex), total: Double(warmupExercises.count))
                            .padding(.horizontal)
                        
                        Spacer()
                        
                        // Exercice d'échauffement actuel
                        let current = warmupExercises[currentWarmupIndex]
                        VStack(spacing: 20) {
                            Image(systemName: current.icon)
                                .font(.system(size: 80))
                                .foregroundStyle(.blue)
                                .padding()
                                .background(Circle().fill(Color.blue.opacity(0.1)))
                            
                            Text(current.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text(current.description)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            HStack(spacing: 40) {
                                VStack(alignment: .center) {
                                    Text("\(current.reps)")
                                        .font(.system(size: 48, weight: .bold))
                                        .foregroundStyle(.blue)
                                    Text("Répétitions")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding()
                            .background(Color.blue.opacity(0.05))
                            .cornerRadius(12)
                        }
                        
                        Spacer()
                        
                        // Boutons de contrôle
                        HStack(spacing: 15) {
                            if currentWarmupIndex > 0 {
                                Button(action: { currentWarmupIndex -= 1 }) {
                                    Label("Précédent", systemImage: "chevron.left")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                }
                            }
                            
                            Button(action: { nextWarmup() }) {
                                HStack {
                                    Text(currentWarmupIndex == warmupExercises.count - 1 ? "Terminer" : "Suivant")
                                    Image(systemName: currentWarmupIndex == warmupExercises.count - 1 ? "checkmark" : "chevron.right")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Échauffement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Passer") { dismiss() }
                }
            }
        }
    }
    
    var completedView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "flame.fill")
                .font(.system(size: 80))
                .foregroundStyle(.orange)
            
            Text("Échauffement Terminé !")
                .font(.title2)
                .bold()
            
            Text("Tu es prêt(e) pour la séance. Bonne chance ! 💪")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button("Démarrer la Séance") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.bottom, 50)
        }
    }
    
    private func nextWarmup() {
        if currentWarmupIndex < warmupExercises.count - 1 {
            currentWarmupIndex += 1
        } else {
            isCompleted = true
        }
    }
    
    private func generateWarmupPlan() -> [(name: String, reps: Int, icon: String, description: String)] {
        var plan: [(name: String, reps: Int, icon: String, description: String)] = []
        
        // Récupérer les types d'exercices de la séance
        let exerciseTypes = Set(workout.sets.map { $0.exercise.type })
        
        // Circulation générale
        plan.append((
            name: "Cardio Léger",
            reps: 30,
            icon: "figure.walk",
            description: "Mouvements de marche ou de jogging sur place pour augmenter la circulation"
        ))
        
        // Échauffement spécifique par type
        if exerciseTypes.contains(.push) || exerciseTypes.contains(.hybrid) {
            plan.append((
                name: "Rotations d'Épaules",
                reps: 15,
                icon: "figure.strengthtraining.traditional",
                description: "Prépare les articulations du haut du corps"
            ))
            plan.append((
                name: "Pompes Légères",
                reps: 10,
                icon: "hand.raised.fingers.spread",
                description: "Échauffement pour les exercices de poussée"
            ))
        }
        
        if exerciseTypes.contains(.pull) || exerciseTypes.contains(.hybrid) {
            plan.append((
                name: "Bras Croisés",
                reps: 15,
                icon: "arm.hand.open",
                description: "Étire l'arrière des épaules et le dos"
            ))
            plan.append((
                name: "Swings de Bras",
                reps: 20,
                icon: "arrow.up.and.down",
                description: "Prépare les articulations des bras"
            ))
        }
        
        if exerciseTypes.contains(.legs) {
            plan.append((
                name: "Flexions de Genoux",
                reps: 15,
                icon: "figure.walk",
                description: "Échauffement des jambes et hanches"
            ))
            plan.append((
                name: "Rotation Hanches",
                reps: 10,
                icon: "arrow.triangle.2.circlepath",
                description: "Prépare le bassin et les hanches"
            ))
        }
        
        if exerciseTypes.contains(.core) {
            plan.append((
                name: "Ceinture Abdominale",
                reps: 20,
                icon: "star.fill",
                description: "Activation de la ceinture abdominale"
            ))
        }
        
        // Étirement léger final
        plan.append((
            name: "Étirements Dynamiques",
            reps: 10,
            icon: "figure.stretching",
            description: "Prépare les muscles pour la charge"
        ))
        
        return plan.isEmpty ? [(
            name: "Cardio Léger",
            reps: 30,
            icon: "figure.walk",
            description: "Augmente la circulation générale"
        )] : plan
    }
}

#Preview {
    let exercise = Exercise(name: "Pompes", muscleGroup: "Pectoraux", type: .push)
    let set = WorkoutSet(reps: 10, exercise: exercise)
    let workout = Workout(name: "Test", sets: [set], scheduledAt: Date(), isTemplate: false)
    
    WarmupView(workout: workout)
}
