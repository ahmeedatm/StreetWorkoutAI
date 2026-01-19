import Foundation
import SwiftUI
import SwiftData

enum ExerciseType: String, Codable, CaseIterable {
    case push = "Push"
    case pull = "Pull"
    case legs = "Jambes"
    case hybrid = "Push & Pull"
    case core = "Statique" // Ton cas "en même temps"
}

extension ExerciseType {
    var color: Color {
        switch self {
        case .push: return .red
        case .pull: return .blue
        case .legs: return .orange
        case .hybrid: return .purple
        case .core: return .yellow
        }
    }
}

// @Model : C'est la magie. Ça transforme la classe en table de base de données SQLite.
// C'est l'équivalent de `class Exercise(Base): __tablename__ = ...`
@Model
class Exercise {
    // id: Pas besoin de le déclarer, SwiftData gère un ID unique automatiquement.
    
    var name: String
    var muscleGroup: String
    var type: ExerciseType
    var equipment: String? // Optionnel : Peut être "Barre", "Anneaux" ou rien (poids du corps)
    
    var prWeight: Double? // Record de force (kg)
    var prReps: Int?      // Record d'endurance (reps)
    
    // Relation One-to-Many (Un exercice a plusieurs sets)
    // .cascade : Si on supprime l'exercice, on supprime ses sets.
    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.exercise)
        var sets: [WorkoutSet] = []
    
    var createdAt: Date
    
    var personalRecord: String {
            // Règle : Poids en priorité, sinon Reps
            if let w = prWeight, w > 0 {
                return "Max : \(w.formatted()) kg"
            } else if let r = prReps, r > 0 {
                return "Max : \(r) reps"
            } else {
                return "Pas de record"
            }
        }

    // Constructeur (Comme __init__ en Python)
    init(name: String, muscleGroup: String, equipment: String? = nil, type: ExerciseType) {
        self.name = name
        self.muscleGroup = muscleGroup
        self.type = type
        self.equipment = equipment
        self.createdAt = Date()
    }
}
