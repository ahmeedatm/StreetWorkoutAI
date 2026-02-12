import Foundation
import SwiftData

// Service d'adaptation automatique des séances
class WorkoutAdaptationEngine {
    
    // Adapte une séance basée sur les recommandations acceptées
    static func adaptWorkout(
        _ workout: Workout,
        with suggestions: [ExerciseSuggestion]
    ) -> Workout {
        // Créer une copie de la séance avec les changements appliqués
        let adaptedSets = workout.sets.map { set -> WorkoutSet in
            // Chercher si ce set a une suggestion
            if let suggestion = suggestions.first(where: { $0.exercise.id == set.exercise.id }) {
                return applySuggestion(suggestion, to: set)
            }
            return set
        }
        
        // Créer une nouvelle séance avec les sets adaptés
        let adaptedWorkout = Workout(
            name: workout.name,
            sets: adaptedSets,
            scheduledAt: Calendar.current.date(byAdding: .day, value: 2, to: Date()) ?? Date(),
            isTemplate: false
        )
        
        return adaptedWorkout
    }
    
    // Applique une suggestion à un set
    private static func applySuggestion(_ suggestion: ExerciseSuggestion, to set: WorkoutSet) -> WorkoutSet {
        let adapted = WorkoutSet(
            reps: suggestion.newReps ?? set.reps,
            weight: suggestion.newWeight ?? set.weight,
            rpe: set.rpe,
            exercise: set.exercise,
            index: set.index
        )
        return adapted
    }
}

// Stratégies d'adaptation smart
enum AdaptationStrategy {
    case conservative  // Changements petits et progressifs
    case moderate      // Changements modérés
    case aggressive    // Changements importants
    
    var repIncrement: Int {
        switch self {
        case .conservative: return 1
        case .moderate: return 2
        case .aggressive: return 3
        }
    }
    
    var weightIncrement: Double {
        switch self {
        case .conservative: return 1.25
        case .moderate: return 2.5
        case .aggressive: return 5.0
        }
    }
}
