import Foundation
import SwiftData

// Modèle pour tracker la performance de chaque exécution d'exercice
@Model
class ExercisePerformance {
    var exercise: Exercise
    var repsCompleted: Int
    var weight: Double?
    var rpe: Int? // Rate of Perceived Exertion (1-10)
    var completedAt: Date
    var workout: Workout?
    var notes: String? // Notes sur la performance
    
    init(
        exercise: Exercise,
        repsCompleted: Int,
        weight: Double? = nil,
        rpe: Int? = nil,
        notes: String? = nil
    ) {
        self.exercise = exercise
        self.repsCompleted = repsCompleted
        self.weight = weight
        self.rpe = rpe
        self.completedAt = Date()
        self.notes = notes
    }
}

// Extension pour calculer les stats de progression
extension Exercise {
    var performanceHistory: [ExercisePerformance] {
        sets.compactMap { set in
            set.completedPerformance
        }
    }
    
    var personalRecordReps: Int? {
        performanceHistory.map { $0.repsCompleted }.max()
    }
    
    var personalRecordWeight: Double? {
        performanceHistory
            .filter { ($0.weight ?? 0) > 0 }
            .map { $0.weight }
            .compactMap { $0 }
            .max()
    }
    
    var averageReps: Double {
        guard !performanceHistory.isEmpty else { return 0 }
        let total = performanceHistory.map { Double($0.repsCompleted) }.reduce(0, +)
        return total / Double(performanceHistory.count)
    }
    
    var totalCompletions: Int {
        performanceHistory.count
    }
}
