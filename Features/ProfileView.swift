import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var context
    
    // On récupère TOUTES les séances (templates inclus, on filtrera après)
    @Query private var allWorkouts: [Workout]
    
    @State private var showDeleteAlert = false
    
    // --- CALCUL DES STATS ---
    
    // 1. Seulement les vraies séances terminées
    var completedWorkouts: [Workout] {
        allWorkouts.filter { !$0.isTemplate && $0.finishedAt != nil }
    }
    
    // 2. Calcul du volume total cumulé (Lifetime Volume)
    var totalLifetimeVolume: Double {
        completedWorkouts.reduce(0) { total, workout in
            total + workout.totalVolume
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // SECTION 1 : STATISTIQUES
                Section("Mes Statistiques") {
                    HStack {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundStyle(.green)
                        Text("Séances terminées")
                        Spacer()
                        Text("\(completedWorkouts.count)")
                            .bold()
                    }
                    
                    HStack {
                        Image(systemName: "dumbbell.fill")
                            .foregroundStyle(.blue)
                        Text("Volume total soulevé")
                        Spacer()
                        // Formatage compact (ex: 12.5K ou 12 500)
                        Text(totalLifetimeVolume.formatted(.number.notation(.compactName)))
                            .bold() + Text(" kg")
                    }
                }
                
                // SECTION 2 : GESTION DES DONNÉES
                Section("Zone de Danger") {
                    Button("Réinitialiser l'historique") {
                        showDeleteAlert = true
                    }
                    .foregroundStyle(.red)
                }
            }
            .navigationTitle("Profil")
            .alert("Êtes-vous sûr ?", isPresented: $showDeleteAlert) {
                Button("Annuler", role: .cancel) { }
                Button("Supprimer", role: .destructive) {
                    resetHistory()
                }
            } message: {
                Text("Cela supprimera toutes vos séances passées. Vos templates et exercices seront conservés.")
            }
        }
    }
    
    func resetHistory() {
        // On ne supprime QUE les séances terminées (pas les templates)
        for workout in completedWorkouts {
            context.delete(workout)
        }
        
        // Feedback haptique
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

#Preview {
    ProfileView()
}
