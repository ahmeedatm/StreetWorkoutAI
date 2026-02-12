import Foundation

// Service d'analyse IA pour les recommandations de progression
class ProgressionAnalyzer {
    
    // Analyse une séance complète et retourne des recommandations
    static func analyzeWorkout(_ workout: Workout) -> WorkoutRecommendation {
        var recommendation = WorkoutRecommendation(
            workoutId: workout,
            suggestedChanges: [],
            overallProgress: calculateOverallProgress(workout),
            timestamp: Date()
        )
        
        // Analyser chaque exercice de la séance
        for (index, set) in workout.sets.enumerated() {
            if let repsCompleted = set.repsCompleted {
                let analysis = analyzeSet(set, targetReps: set.reps, repsCompleted: repsCompleted)
                if let suggestion = analysis {
                    recommendation.suggestedChanges.append(suggestion)
                }
            }
        }
        
        return recommendation
    }
    
    // Analyse un set individuel
    private static func analyzeSet(_ set: WorkoutSet, targetReps: Int, repsCompleted: Int) -> ExerciseSuggestion? {
        let exercise = set.exercise
        let completionRate = Double(repsCompleted) / Double(targetReps)
        
        // Récupérer l'historique de performance
        let performances = exercise.performanceHistory
        guard performances.count > 1 else { return nil }
        
        // Analyser la tendance
        let recentAvg = performances.suffix(3).map { Double($0.repsCompleted) }.reduce(0, +) / 3.0
        let historicalAvg = Double(exercise.averageReps)
        
        var suggestion: ExerciseSuggestion?
        
        // Cas 1: Progression - L'utilisateur fait plus que sa moyenne
        if repsCompleted > historicalAvg * 1.1 && completionRate >= 0.95 {
            suggestion = ExerciseSuggestion(
                exercise: exercise,
                changeType: .increase,
                newReps: min(repsCompleted + 2, repsCompleted + Int(Double(targetReps) * 0.15)),
                reason: "Excellente progression ! Augmente le nombre de reps."
            )
        }
        
        // Cas 2: Stagnation - Performance stable mais sans progrès
        else if completionRate >= 0.95 && !hasProgressed(exercise, in: 5) {
            suggestion = ExerciseSuggestion(
                exercise: exercise,
                changeType: .addWeight,
                newReps: targetReps,
                newWeight: (set.weight ?? 0) + 2.5,
                reason: "Stable mais stagnant. Ajoute du poids ou une variante plus difficile."
            )
        }
        
        // Cas 3: Sous-performance - L'utilisateur ne réussit pas les reps
        else if completionRate < 0.85 && repsCompleted < targetReps {
            suggestion = ExerciseSuggestion(
                exercise: exercise,
                changeType: .decrease,
                newReps: max(targetReps - 2, Int(Double(targetReps) * 0.8)),
                reason: "Réduction recommandée. Maîtrise d'abord les reps actuels."
            )
        }
        
        // Cas 4: Fatigue - Mauvaise performance après progression récente
        else if completionRate < 0.80 && recentAvg < historicalAvg * 0.95 {
            suggestion = ExerciseSuggestion(
                exercise: exercise,
                changeType: .rest,
                newReps: targetReps,
                reason: "Signes de fatigue. Envisage du repos supplémentaire."
            )
        }
        
        return suggestion
    }
    
    // Vérifie si l'exercice a progressé dans les N dernières séances
    private static func hasProgressed(_ exercise: Exercise, in sessions: Int) -> Bool {
        let recentPerformances = exercise.performanceHistory.suffix(sessions)
        guard recentPerformances.count >= 2 else { return false }
        
        let first = recentPerformances.first?.repsCompleted ?? 0
        let last = recentPerformances.last?.repsCompleted ?? 0
        
        return last > first
    }
    
    // Calcule la progression générale
    private static func calculateOverallProgress(_ workout: Workout) -> Double {
        var totalCompletion: Double = 0
        var count = 0
        
        for set in workout.sets {
            if let repsCompleted = set.repsCompleted {
                let rate = Double(repsCompleted) / Double(set.reps)
                totalCompletion += min(rate, 1.0) // Max 100%
                count += 1
            }
        }
        
        return count > 0 ? (totalCompletion / Double(count)) * 100 : 0
    }
}

// Modèle pour les recommandations
struct WorkoutRecommendation {
    let workoutId: Workout
    var suggestedChanges: [ExerciseSuggestion] = []
    let overallProgress: Double
    let timestamp: Date
    
    var summary: String {
        if overallProgress >= 95 {
            return "🔥 Performance exceptionnelle ! Continue comme ça."
        } else if overallProgress >= 85 {
            return "💪 Bonne séance ! Maintien ce rythme."
        } else if overallProgress >= 75 {
            return "👍 Correcte séance. Quelques ajustements recommandés."
        } else {
            return "⚠️ Séance difficile. Repos et récupération recommandés."
        }
    }
    
    var hasChanges: Bool {
        !suggestedChanges.isEmpty
    }
}

// Modèle pour une suggestion d'exercice
struct ExerciseSuggestion {
    let exercise: Exercise
    let changeType: ChangeType
    var newReps: Int?
    var newWeight: Double?
    let reason: String
    
    enum ChangeType {
        case increase      // Augmenter les reps
        case decrease      // Diminuer les reps
        case addWeight     // Ajouter du poids
        case changeVariant // Changer de variante
        case rest          // Prendre du repos
    }
    
    var description: String {
        switch changeType {
        case .increase:
            return "Augmenter à \(newReps ?? 0) reps"
        case .decrease:
            return "Réduire à \(newReps ?? 0) reps"
        case .addWeight:
            return "Ajouter \(String(format: "%.1f", newWeight ?? 0)) kg"
        case .changeVariant:
            return "Essayer une variante plus difficile"
        case .rest:
            return "Prendre du repos"
        }
    }
}
