import SwiftUI
import SwiftData

@main
struct StreetWorkoutAIApp: App {
    // 1. On déclare le container comme une propriété pour pouvoir y accéder plus tard
    let container: ModelContainer

    // 2. On l'initialise dans le constructeur de l'App (init)
    init() {
        do {
            // On crée le container avec tous tes modèles
            container = try ModelContainer(for: Exercise.self, Workout.self, WorkoutSet.self)
        } catch {
            fatalError("Impossible de créer le ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                // 3. 👇 C'est ICI qu'on met le onAppear (sur la Vue, pas sur la Scene)
                .onAppear {
                    // Maintenant 'container' existe, on peut l'utiliser !
                    DataSeeder.seed(context: container.mainContext)
                }
        }
        // 4. On injecte le container qu'on a créé manuellement plus haut
        .modelContainer(container)
    }
}
