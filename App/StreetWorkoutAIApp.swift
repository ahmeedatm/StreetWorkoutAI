import SwiftUI
import SwiftData

@main
struct StreetWorkoutAIApp: App {
    var body: some Scene {
        WindowGroup {
            // On appelle notre nouvelle vue ici
            MainTabView()
        }
        // C'est ICI qu'on initialise la DB (SQLite).
        // On lui dit : "Prépare les tables pour Exercise, Workout et WorkoutSet".
        .modelContainer(for: [Exercise.self, Workout.self, WorkoutSet.self])
    }
}
