import Foundation
import SwiftData

@Model
class Workout {
    var name: String?
    var scheduledAt: Date
    var createdAt: Date
    var finishedAt: Date?
    
    var type: ExerciseType {
        // 1. On récupère la liste des types de tous les exos (sans les nil)
        let allTypes = sets.compactMap { $0.exercise.type }
            
        // 2. On dédoublonne (ex: [Push, Push, Pull] devient {Push, Pull})
        let uniqueTypes = Set(allTypes)
        
        if uniqueTypes.count == 1 {
            // Cas simple : Que du Push, ou que du Pull, ou que des Jambes
            return uniqueTypes.first!
        } else {
            // Cas complexe : Mélange (Push + Pull, etc.) -> Hybride
            return .hybrid
        }
    }
    
    var totalVolume: Double {
        var total: Double = 0
        for set in self.sets{
            total += set.weight ?? 0
        }
        return total
    }
    
    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.workout)
    var sets: [WorkoutSet] = []
    
    init(name: String? = nil, sets: [WorkoutSet], scheduledAt: Date) {
        self.name = name
        self.sets = sets
        self.scheduledAt = scheduledAt
        self.createdAt = Date()
        self.finishedAt = nil
    }
    
}
