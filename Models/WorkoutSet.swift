import Foundation
import SwiftData

@Model
class WorkoutSet {
    var reps: Int // Reps prévus
    var repsCompleted: Int? // Reps réellement complétés
    var weight: Double? // Optionnel : Peut être null si poids du corps
    var rpe: Int? // Rate of Perceived Exertion (1-10)
    var isCompleted: Bool = false
    var completedAt: Date
    var index: Int = 0
    var notes: String? // Notes supplémentaires
    
    // Relation inverse (Un set appartient à un exercice)
    var exercise: Exercise
    var workout: Workout?
    
    // Performance enregistrée pour ce set
    var completedPerformance: ExercisePerformance? {
        guard let completed = repsCompleted else { return nil }
        return ExercisePerformance(
            exercise: exercise,
            repsCompleted: completed,
            weight: weight,
            rpe: rpe,
            notes: notes
        )
    }
    
    init(reps: Int, weight: Double? = nil, rpe: Int? = nil, exercise: Exercise, index: Int = 0) {
        self.reps = reps
        self.weight = weight
        self.rpe = rpe
        self.exercise = exercise
        self.completedAt = Date()
        self.index = index
    }
}
