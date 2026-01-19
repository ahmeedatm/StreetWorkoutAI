import Foundation
import SwiftData

class DataSeeder {
    // La liste statique de tes exercices officiels
    static let defaultExercises: [Exercise] = [
        // PUSH (Poussée)
        Exercise(name: "Pompes", muscleGroup: "Pectoraux", type: .push),
        Exercise(name: "Dips", muscleGroup: "Triceps", type: .push),
        Exercise(name: "Pompes Diamant", muscleGroup: "Triceps", type: .push),
        Exercise(name: "Handstand Push-ups", muscleGroup: "Épaules", type: .push),
        Exercise(name: "Planche Lean", muscleGroup: "Épaules", type: .push),
        
        // PULL (Tirage)
        Exercise(name: "Tractions Pronation", muscleGroup: "Dos", type: .pull),
        Exercise(name: "Tractions Supination", muscleGroup: "Biceps", type: .pull),
        Exercise(name: "Australian Pull-ups", muscleGroup: "Dos", type: .pull),
        Exercise(name: "Muscle-up", muscleGroup: "Dos", type: .pull),
        Exercise(name: "Front Lever Hold", muscleGroup: "Abdos", type: .pull),
        
        // LEGS (Jambes)
        Exercise(name: "Squats", muscleGroup: "Jambes", type: .legs),
        Exercise(name: "Pistol Squats", muscleGroup: "Jambes", type: .legs),
        Exercise(name: "Fentes", muscleGroup: "Jambes", type: .legs),
        Exercise(name: "Calf Raises", muscleGroup: "Jambes", type: .legs),
        
        // CORE (Abdos)
        Exercise(name: "Relevés de Jambes", muscleGroup: "Abdos", type: .core),
        Exercise(name: "L-Sit", muscleGroup: "Abdos", type: .core),
        Exercise(name: "Plank", muscleGroup: "Abdos", type: .core)
    ]
    
    // Fonction magique qui vérifie et remplit
    @MainActor
    static func seed(context: ModelContext) {
        // 1. On vérifie si la base est vide
        let descriptor = FetchDescriptor<Exercise>()
        let count = (try? context.fetchCount(descriptor)) ?? 0
        
        if count == 0 {
            print("🌱 Base vide : Injection des exercices par défaut...")
            // 2. Si vide, on injecte tout
            for exercise in defaultExercises {
                context.insert(exercise)
            }
            // (La sauvegarde est automatique avec SwiftData en fin de runloop)
        } else {
            print("✅ La base contient déjà \(count) exercices. Pas de modification.")
        }
    }
}
