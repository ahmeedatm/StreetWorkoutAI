import Foundation
import SwiftData

class DataSeeder {
    // La liste statique de tes exercices officiels
    static let defaultExercises: [Exercise] = [
        // PUSH (Poussée)
        Exercise(
            name: "Pompes",
            muscleGroup: "Pectoraux",
            equipment: nil,
            type: .push
        ).with(gifUrl: "https://media.giphy.com/media/g9GUuK567IqRDyAPE2/giphy.gif", description: "Écarte les bras à la largeur des épaules, descend lentement, remonte."),
        
        Exercise(
            name: "Dips",
            muscleGroup: "Triceps",
            equipment: "Barre",
            type: .push
        ).with(gifUrl: "https://media.giphy.com/media/l0MYt5jPR6QX5pnqM/giphy.gif", description: "Descend les coudes à 90°, remonte."),
        
        Exercise(
            name: "Pompes Diamant",
            muscleGroup: "Triceps",
            equipment: nil,
            type: .push
        ).with(description: "Les mains se touchent, forment un diamant, intensifie les triceps."),
        
        Exercise(
            name: "Handstand Push-ups",
            muscleGroup: "Épaules",
            equipment: nil,
            type: .push
        ).with(description: "Inverse, appuyé contre un mur, descend la tête vers le sol."),
        
        Exercise(
            name: "Planche Lean",
            muscleGroup: "Épaules",
            equipment: nil,
            type: .push
        ).with(description: "Planche inclinée vers l'avant pour intensifier l'engagement des épaules."),
        
        // PULL (Tirage)
        Exercise(
            name: "Tractions Pronation",
            muscleGroup: "Dos",
            equipment: "Barre",
            type: .pull
        ).with(gifUrl: "https://media.giphy.com/media/YoB1fTVCXwVZzBjZMP/giphy.gif", description: "Mains écartées, les paumes vers l'extérieur, tire-toi vers le haut."),
        
        Exercise(
            name: "Tractions Supination",
            muscleGroup: "Biceps",
            equipment: "Barre",
            type: .pull
        ).with(gifUrl: "https://media.giphy.com/media/JR5c5cTJaHGpYaLwHF/giphy.gif", description: "Mains écartées, les paumes vers toi, redresse-toi."),
        
        Exercise(
            name: "Australian Pull-ups",
            muscleGroup: "Dos",
            equipment: "Barre",
            type: .pull
        ).with(description: "Barre basse, sous le corps, tire la poitrine vers la barre."),
        
        Exercise(
            name: "Muscle-up",
            muscleGroup: "Dos",
            equipment: "Barre",
            type: .pull
        ).with(description: "Combine traction et dips, passe par-dessus la barre."),
        
        Exercise(
            name: "Front Lever Hold",
            muscleGroup: "Abdos",
            equipment: "Barre",
            type: .pull
        ).with(description: "Corps parallèle au sol, face vers l'avant, maîtrise l'équilibre."),
        
        // LEGS (Jambes)
        Exercise(
            name: "Squats",
            muscleGroup: "Jambes",
            equipment: nil,
            type: .legs
        ).with(gifUrl: "https://media.giphy.com/media/5T30JsEzVzCjvWydyX/giphy.gif", description: "Poids sur les talons, flexion contrôlée, remonte."),
        
        Exercise(
            name: "Pistol Squats",
            muscleGroup: "Jambes",
            equipment: nil,
            type: .legs
        ).with(description: "Squat sur une jambe, l'autre tendue, très intensif."),
        
        Exercise(
            name: "Fentes",
            muscleGroup: "Jambes",
            equipment: nil,
            type: .legs
        ).with(gifUrl: "https://media.giphy.com/media/Yo7LqC95k0Lx1ksVQz/giphy.gif", description: "Genou avant à 90°, genou arrière descend, alterne."),
        
        Exercise(
            name: "Calf Raises",
            muscleGroup: "Jambes",
            equipment: nil,
            type: .legs
        ).with(description: "Lève-toi sur la pointe des pieds, descends lentement."),
        
        // CORE (Abdos)
        Exercise(
            name: "Relevés de Jambes",
            muscleGroup: "Abdos",
            equipment: nil,
            type: .core
        ).with(description: "Accroché ou au sol, lève les jambes tendues, contrôle la descente."),
        
        Exercise(
            name: "L-Sit",
            muscleGroup: "Abdos",
            equipment: "Barre",
            type: .core
        ).with(description: "Corps parallèle au sol, jambes tendues, tiens la position."),
        
        Exercise(
            name: "Plank",
            muscleGroup: "Abdos",
            equipment: nil,
            type: .core
        ).with(gifUrl: "https://media.giphy.com/media/JwT1QBiMGcruA2zfPV/giphy.gif", description: "Corps droit du talon à la tête, maintiens la position.")
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

// Extension pour ajouter facilement des attributs à l'initialisation
extension Exercise {
    @discardableResult
    func with(
        gifUrl: String? = nil,
        videoUrl: String? = nil,
        description: String? = nil
    ) -> Exercise {
        self.gifUrl = gifUrl
        self.videoUrl = videoUrl
        self.description = description
        return self
    }
}
