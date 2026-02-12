import SwiftUI

struct WorkoutRecommendationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    var workout: Workout
    var recommendation: WorkoutRecommendation
    @State private var showAdaptationView = false
    @State private var acceptedSuggestions: Set<UUID> = []
    @State private var showAppliedMessage = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // En-tête avec score
                    VStack(spacing: 15) {
                        let progressPercent = Int(recommendation.overallProgress)
                        
                        ZStack {
                            Circle()
                                .fill(
                                    recommendation.overallProgress >= 85 ? Color.green.opacity(0.1) :
                                    recommendation.overallProgress >= 75 ? Color.orange.opacity(0.1) :
                                    Color.red.opacity(0.1)
                                )
                            
                            VStack {
                                Text("\(progressPercent)%")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundStyle(
                                        recommendation.overallProgress >= 85 ? .green :
                                        recommendation.overallProgress >= 75 ? .orange :
                                        .red
                                    )
                                Text("Réussite")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(height: 150)
                        
                        Text(recommendation.summary)
                            .font(.headline)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    
                    // Recommandations
                    if recommendation.hasChanges {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Recommandations de Progression")
                                .font(.headline)
                            
                            ForEach(recommendation.suggestedChanges, id: \.reason) { suggestion in
                                RecommendationCard(suggestion: suggestion)
                            }
                        }
                    } else {
                        VStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.green)
                            Text("Pas de changement recommandé")
                                .font(.headline)
                            Text("Continue avec le même programme")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.05))
                        .cornerRadius(12)
                    }
                    
                    // Boutons d'action
                    VStack(spacing: 12) {
                        if recommendation.hasChanges {
                            Button(action: { showAdaptationView = true }) {
                                HStack {
                                    Image(systemName: "sparkles")
                                    Text("Adapter Intelligemment la Séance")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .cornerRadius(10)
                            }
                            
                            Button(action: { dismiss() }) {
                                Text("Ignorer")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(.systemGray5))
                                    .foregroundStyle(.primary)
                                    .cornerRadius(10)
                            }
                        } else {
                            Button(action: { dismiss() }) {
                                Text("Fermer")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundStyle(.white)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding()
                }
                .padding()
            }
            .navigationTitle("Analyse de Séance")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAdaptationView) {
                SmartWorkoutAdaptationView(lastWorkout: workout, recommendation: recommendation)
            }
        }
    }
}

struct RecommendationCard: View {
    let suggestion: ExerciseSuggestion
    
    var changeColor: Color {
        switch suggestion.changeType {
        case .increase: return .green
        case .addWeight: return .blue
        case .decrease: return .orange
        case .changeVariant: return .purple
        case .rest: return .red
        }
    }
    
    var changeIcon: String {
        switch suggestion.changeType {
        case .increase: return "arrow.up"
        case .addWeight: return "plus"
        case .decrease: return "arrow.down"
        case .changeVariant: return "arrow.triangle.swap"
        case .rest: return "zzz"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(suggestion.exercise.name)
                        .font(.headline)
                    Text(suggestion.reason)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                
                HStack(spacing: 8) {
                    Image(systemName: changeIcon)
                    Text(suggestion.description)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(changeColor.opacity(0.2))
                .foregroundStyle(changeColor)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
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
        reason: "Excellente progression !"
    )
    
    let recommendation = WorkoutRecommendation(
        workoutId: workout,
        suggestedChanges: [suggestion],
        overallProgress: 95,
        timestamp: Date()
    )
    
    WorkoutRecommendationView(workout: workout, recommendation: recommendation)
}
