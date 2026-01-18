import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Workout.scheduledAt) private var workouts: [Workout]
    
    @State private var showCreateSheet = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // --- BLOC 1 : PROCHAINE SÉANCE ---
                    HStack {
                        Text("À venir")
                            .font(.headline)
                        Spacer()
                    }
                    
                    // TODO 2: Logique de filtrage
                    // Trouve la séance où la date est > maintenant
                    if let nextWorkout = workouts.first(where: { $0.scheduledAt >= Date.now }) {
                        
                        // TODO 3: Créer une "Card" pour afficher cette séance
                        // Tu peux créer une petite vue dédiée ou mettre un VStack ici
                        // Affiche: Nom, Date, et peut-être un bouton "Go"
                        NavigationLink {
                            // Destination : La vue de détail qu'on a bossée ensemble
                            WorkoutDetailView(workout: nextWorkout)
                        } label: {
                            // Ce sur quoi on clique
                            WorkoutCardView(workout: nextWorkout, color: .blue)
                        }
                        // Petite astuce pour enlever la couleur bleue moche par défaut du lien
                        .buttonStyle(.plain)
                        
                    } else {
                        // TODO 4: Empty State
                        // Affiche un texte sympa genre "Rien de prévu. Repos ?"
                        ContentUnavailableView("Rien de prévu", systemImage: "zzz")
                    }
                    
                    
                    // --- BLOC 2 : HISTORIQUE RÉCENT ---
                    HStack {
                        Text("Dernière session")
                            .font(.headline)
                        Spacer()
                    }
                    
                    // TODO 5: Logique de filtrage (Inverse du futur)
                    if let lastWorkout = workouts.filter({ $0.scheduledAt < Date.now }).last {
                         WorkoutCardView(workout: lastWorkout, color: .blue).buttonStyle(.plain)
                    } else {
                        Text("Commence ton premier entraînement !")
                    }
                    
                    // --- BLOC 3 : STATS / CALENDRIER ---
                    ProgressChartView(workouts: workouts)
                }
                .padding()
            }
            .navigationTitle("Tableau de bord")
            .toolbar {
                Button {
                    showCreateSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                }
            }
            // C'est ici qu'on attache la feuille de création
            .sheet(isPresented: $showCreateSheet) {
                CreateWorkoutView()
                    // Pas besoin de passer le container, la feuille hérite de l'environnement du parent
            }
        }
    }
        
    func addTestWorkout() {
        // Création de l'objet (Instance)
        let pullup = Exercise(name: "Traction", muscleGroup: "Dos", type: ExerciseType.pull)
        let pushup = Exercise(name: "Pompes", muscleGroup: "Pectoraux", type: ExerciseType.push)
        
        let workoutSet1 = WorkoutSet(reps: 10, weight: 2, rpe: 8, exercise: pushup)
        let workoutSet2 = WorkoutSet(reps: 8, weight: 5, rpe: 8, exercise: pullup)
        
        let tomorrow = Date.now.addingTimeInterval(86400)
        
        let newWorkout = Workout(name: "Traction Push", sets: [workoutSet1, workoutSet2], scheduledAt: tomorrow)
        
        // Insertion en base (db.add(obj))
        context.insert(newWorkout)
        
        // Pas besoin de context.save(), SwiftData le fait automatiquement à la fin de la boucle d'événement !
    }
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
