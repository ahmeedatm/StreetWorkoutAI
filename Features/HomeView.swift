import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<Workout> { $0.isTemplate == false }, sort: \Workout.scheduledAt)
    private var workouts: [Workout]
    
    @Query private var allExercises: [Exercise]
    
    var completedWorkouts: [Workout] {
        workouts.filter { $0.finishedAt != nil }
    }
    
    var totalVolume: Double {
        completedWorkouts.reduce(0) { total, workout in
            total + workout.totalVolume
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // --- STATS RAPIDES ---
                    HStack(spacing: 15) {
                        StatTile(
                            label: "Séances",
                            value: "\(completedWorkouts.count)",
                            icon: "checkmark.seal",
                            color: .green
                        )
                        
                        StatTile(
                            label: "Volume",
                            value: String(format: "%.0f", totalVolume),
                            subtitle: "kg",
                            icon: "dumbbell",
                            color: .blue
                        )
                        
                        StatTile(
                            label: "Exercices",
                            value: "\(allExercises.count)",
                            icon: "figure.strengthtraining",
                            color: .orange
                        )
                    }
                    .padding(.horizontal)
                    
                    // --- BLOC 1 : PROCHAINE SÉANCE ---
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("À venir")
                                .font(.headline)
                            Spacer()
                            NavigationLink("Voir tout", destination: WorkoutListView())
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }
                        
                        if let nextWorkout = workouts.first(where: { $0.scheduledAt >= Date.now }) {
                            NavigationLink(destination: WorkoutDetailView(workout: nextWorkout)) {
                                WorkoutCardView(workout: nextWorkout, color: .blue)
                            }
                            .buttonStyle(.plain)
                        } else {
                            ContentUnavailableView("Rien de prévu", systemImage: "zzz")
                        }
                    }
                    .padding(.horizontal)
                    
                    // --- BLOC 2 : DERNIER ENTRAÎNEMENT ---
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Dernier entraînement")
                                .font(.headline)
                            Spacer()
                        }
                        
                        if let lastWorkout = workouts.filter({ $0.scheduledAt < Date.now }).last {
                            VStack(alignment: .leading, spacing: 8) {
                                NavigationLink(destination: WorkoutDetailView(workout: lastWorkout)) {
                                    WorkoutCardView(workout: lastWorkout, color: .gray)
                                }
                                .buttonStyle(.plain)
                                
                                if let finishedAt = lastWorkout.finishedAt {
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                        Text("Terminé le \(finishedAt.formatted(date: .abbreviated, time: .shortened))")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        } else {
                            VStack(spacing: 10) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 32))
                                    .foregroundStyle(.orange)
                                Text("Commence ton premier entraînement !")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // --- BLOC 3 : CALENDRIER DE PROGRESSION ---
                    ProgressChartView(workouts: workouts)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
        }
    }
}

struct StatTile: View {
    let label: String
    let value: String
    var subtitle: String?
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            HStack(spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}
        
//    func addTestWorkout() {
//        // Création de l'objet (Instance)
//        let pushup = Exercise(name: "Pompes", muscleGroup: "Pectoraux", type: .push, prWeight: 12, prReps: 36)
//        let pullup = Exercise(name: "Tractions", muscleGroup: "Dos", type: .pull, prWeight: 0, prReps: 6)
//        
//        let workoutSet1 = WorkoutSet(reps: 10, weight: 2, rpe: 8, exercise: pushup)
//        let workoutSet2 = WorkoutSet(reps: 8, weight: 5, rpe: 8, exercise: pullup)
//        
//        let tomorrow = Date.now.addingTimeInterval(86400)
//        
//        let newWorkout = Workout(name: "Traction Push", sets: [workoutSet1, workoutSet2], scheduledAt: tomorrow, isTemplate: false)
//        
//        // Insertion en base (db.add(obj))
//        context.insert(newWorkout)
//        
//        // Pas besoin de context.save(), SwiftData le fait automatiquement à la fin de la boucle d'événement !
//    }
}


// Un composant réutilisable pour éviter de dupliquer le code
// Complète-le pour qu'il soit joli
struct WorkoutCardView: View {
    let workout: Workout
    let color: Color
    
    var body: some View {
        NavigationLink(destination: WorkoutDetailView(workout: workout)){
            VStack(alignment: .leading) {
                // TODO 6: Design de la carte
                // Affiche le nom (workout.name) et la date
                // Utilise la couleur passée en paramètre pour décorer
                HStack{
                    Text(workout.name ?? "Séance sans nom")
                    Spacer()
                    HStack(spacing: 4) {
                        Text(workout.type.rawValue)
                            .font(.caption)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(workout.type.color)) // Gris très clair natif iOS
                    .clipShape(Capsule()) // Arrondir les bords
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(radius: 2)
        }
    }}


#Preview {
    HomeView()
        .modelContainer(for: Workout.self, inMemory: true)
}
