import SwiftUI
import SwiftData

struct WorkoutListView: View {
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<Workout> { $0.isTemplate == false }, sort: \Workout.scheduledAt)
    private var workouts: [Workout]
    
    @State private var showCreateWorkoutSheet = false
    @State private var filterCompleted: Bool?
    
    var filteredWorkouts: [Workout] {
        if let filter = filterCompleted {
            return workouts.filter { (workout) -> Bool in
                if filter {
                    return workout.finishedAt != nil
                } else {
                    return workout.finishedAt == nil
                }
            }
        }
        return workouts
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Filtre par statut
                Picker("Statut", selection: $filterCompleted) {
                    Text("Tous").tag(Optional<Bool>(nil))
                    Text("À venir").tag(Optional<Bool>(false))
                    Text("Terminées").tag(Optional<Bool>(true))
                }
                .pickerStyle(.segmented)
                .padding()
                
                List {
                    // Boucle For-Each sur les résultats de la requête
                    ForEach(filteredWorkouts) { workout in
                        NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                            WorkoutRowView(workout: workout)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Historique")
            .toolbar {
                Button {
                    showCreateWorkoutSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                }
            }
            // C'est ici qu'on attache la feuille de création
            .sheet(isPresented: $showCreateWorkoutSheet) {
                CreateWorkoutView()
                    // Pas besoin de passer le container, la feuille hérite de l'environnement du parent
            }
        }
    }
    
    func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            context.delete(filteredWorkouts[index])
        }
    }
}

struct WorkoutRowView: View {
    let workout: Workout
    
    var durationText: String {
        guard let finishedAt = workout.finishedAt else { return "En cours" }
        let duration = finishedAt.timeIntervalSince(workout.createdAt)
        let minutes = Int(duration / 60)
        return "\(minutes)min"
    }
    
    var statusIcon: String {
        if let _ = workout.finishedAt {
            return "checkmark.circle.fill"
        } else {
            return "hourglass.tophalf.fill"
        }
    }
    
    var statusColor: Color {
        if let _ = workout.finishedAt {
            return .green
        } else {
            return .orange
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: statusIcon)
                            .font(.caption)
                            .foregroundStyle(statusColor)
                        
                        Text(workout.name ?? "Séance sans nom")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text(workout.type.rawValue)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(workout.type.color))
                            .clipShape(Capsule())
                    }
                    
                    HStack(spacing: 15) {
                        Label(workout.createdAt.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Label("\(workout.sets.count) exercices", systemImage: "dumbbell")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        if !durationText.isEmpty && durationText != "En cours" {
                            Label(durationText, systemImage: "clock")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}
    
    func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let workoutToDelete = workouts[index]
            context.delete(workoutToDelete)
        }
    }
}

// Ceci sert juste à la prévisualisation dans Xcode (Canvas à droite)
#Preview {
    WorkoutListView()
        .modelContainer(for: Workout.self, inMemory: true)
}
