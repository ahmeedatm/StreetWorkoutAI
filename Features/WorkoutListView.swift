import SwiftUI
import SwiftData

struct WorkoutListView: View {
    @Environment(\.modelContext) private var context
    @Query(filter: #Predicate<Workout> { $0.isTemplate == false }, sort: \Workout.scheduledAt)
    private var workouts: [Workout]
    
    @State private var showCreateWorkoutSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                // Boucle For-Each sur les résultats de la requête
                ForEach(workouts) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                        HStack {
                            VStack(alignment: .leading){
                                if let name = workout.name {
                                    Text(name)
                                        .font(.headline)
                                    
                                }else{
                                    Text("Séance sans nom")
                                        .font(.headline)
                                }
                                
                                Spacer()
                                Text(workout.createdAt, format: .dateTime.day().month()).font(.caption).foregroundStyle(.secondary)
                            }
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
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Séances")
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
