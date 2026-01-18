import Foundation
import SwiftData

@Model
class WorkoutSet {
    var reps: Int
    var weight: Double? // Optionnel : Peut être null si poids du corps
    var rpe: Int? // Rate of Perceived Exertion (1-10)
    var isCompleted: Bool = false
    var completedAt: Date
    
    // Relation inverse (Un set appartient à un exercice)
    var exercise: Exercise
    var workout: Workout?
    
    init(reps: Int, weight: Double? = nil, rpe: Int? = nil, exercise: Exercise) {
        self.reps = reps
        self.weight = weight
        self.rpe = rpe
        self.exercise = exercise
        self.completedAt = Date()
    }
}
