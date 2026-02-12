import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var context
    
    // On récupère TOUTES les séances (templates inclus, on filtrera après)
    @Query private var allWorkouts: [Workout]
    @Query private var allExercises: [Exercise]
    
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
    
    // 3. Exercice le plus exécuté
    var mostFrequentExercise: Exercise? {
        var exerciseCount: [Exercise: Int] = [:]
        for workout in completedWorkouts {
            for set in workout.sets {
                exerciseCount[set.exercise, default: 0] += 1
            }
        }
        return exerciseCount.max { $0.value < $1.value }?.key
    }
    
    // 4. Taux de complétion des séances prévues
    var completionRate: Double {
        let scheduled = allWorkouts.filter { !$0.isTemplate && $0.scheduledAt <= Date.now }.count
        guard scheduled > 0 else { return 0 }
        return Double(completedWorkouts.count) / Double(scheduled) * 100
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    // SECTION 1 : EN-TÊTE PROFIL
                    VStack(spacing: 15) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.blue)
                        
                        Text("Profil d'Entraînement")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Suivi de tes performances et progression")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    
                    // SECTION 2 : STATISTIQUES PRINCIPALES
                    VStack(spacing: 12) {
                        Text("Mes Statistiques")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        StatCard(
                            icon: "checkmark.seal.fill",
                            color: .green,
                            label: "Séances Complétées",
                            value: "\(completedWorkouts.count)",
                            subtitle: "séances"
                        )
                        
                        StatCard(
                            icon: "dumbbell.fill",
                            color: .blue,
                            label: "Volume Soulevé",
                            value: String(format: "%.0f", totalLifetimeVolume),
                            subtitle: "kg"
                        )
                        
                        StatCard(
                            icon: "chart.bar.fill",
                            color: .orange,
                            label: "Taux de Complétion",
                            value: String(format: "%.0f", completionRate),
                            subtitle: "%"
                        )
                        
                        StatCard(
                            icon: "flame.fill",
                            color: .red,
                            label: "Exercices Pratiqués",
                            value: "\(allExercises.count)",
                            subtitle: "au total"
                        )
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .padding()
                    
                    // SECTION 3 : EXERCICE PRÉFÉRÉ
                    if let mostFrequent = mostFrequentExercise {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Exercice Préféré")
                                .font(.headline)
                            
                            HStack(spacing: 15) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.yellow)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(mostFrequent.name)
                                        .font(.headline)
                                    Text(mostFrequent.muscleGroup)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    
                                    HStack(spacing: 10) {
                                        Label("Max: \(mostFrequent.personalRecordReps ?? 0) reps", systemImage: "arrow.up")
                                            .font(.caption2)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color.yellow.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding()
                    }
                    
                    // SECTION 4 : ACTIONS
                    VStack(spacing: 12) {
                        NavigationLink(destination: ProgressChartDetailView(exercise: allExercises.first ?? Exercise(name: "N/A", muscleGroup: "N/A", type: .push))) {
                            HStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .foregroundStyle(.blue)
                                Text("Voir la Progression Détaillée")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundStyle(.gray)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        .foregroundStyle(.primary)
                    }
                    .padding()
                    
                    // SECTION 5 : GESTION DES DONNÉES
                    VStack(spacing: 12) {
                        Text("Zone de Danger")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Réinitialiser l'historique")
                                Spacer()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .foregroundStyle(.red)
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    
                    Spacer(minLength: 20)
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

struct StatCard: View {
    let icon: String
    let color: Color
    let label: String
    let value: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 4) {
                    Text(value)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: Workout.self, inMemory: true)
}
