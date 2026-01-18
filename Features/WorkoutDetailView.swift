import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    @Environment(\.modelContext) private var context
    
    // 1. On récupère le catalogue pour le Picker
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    
    // 2. On reçoit la séance en mode écriture
    @Bindable var workout: Workout
    
    // 3. Variables du formulaire d'ajout
    @State private var reps: Int = 10
    @State private var weight: Double? // Optionnel car poids du corps possible
    @State private var selectedExercise: Exercise? // Optionnel au début
    @State private var showCreateExerciseSheet: Bool = false
    
    var sortedSets: [WorkoutSet]{
        return workout.sets.sorted { $0.completedAt < $1.completedAt }
    }
    
    var body: some View {
        if workout.finishedAt == nil {
            Form {
                // SECTION 1 : L'HISTORIQUE (Ce qui est déjà fait)
                Section("Séries réalisées") {
                    // On boucle sur les séries de la séance (et pas sur le catalogue exercises !)
                    ForEach(sortedSets) { set in
                        HStack {
                            WorkoutSetRow(set: set)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) { // 1. On ouvre le menu
                            
                            // 2. On crée le bouton visuel
                            Button(role: .destructive) {
                                // 3. C'est ICI qu'on déclenche l'action quand l'utilisateur clique
                                deleteSet(set: set)
                            } label: {
                                // 4. L'icône du bouton (La poubelle)
                                Label("Supprimer", systemImage: "trash")
                            }
                            
                        }
                    }
                }
                
                //Le bouton de fin de séance
                Section{
                    Button("Terminer la séance"){
                        finishWorkout()
                    }
                }
            }
            // C'est ici qu'on définit le titre, le parent l'affichera
            .navigationTitle(workout.name ?? "Nouvelle Séance")
            // Une petite astuce pour initialiser le picker avec le premier exo dispo
            .onAppear {
                if selectedExercise == nil {
                    selectedExercise = exercises.first
                }
            }
            .toolbar {
                Button {
                    showCreateExerciseSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 22))
                }
            }
            .sheet(isPresented: $showCreateExerciseSheet) {
                CreateWorkoutSetView(workout: workout)
            }
        }else{
            Form {
                // SECTION 1 : L'HISTORIQUE (Ce qui est déjà fait)
                Section("Résumé de la séance") {
                    // On boucle sur les séries de la séance (et pas sur le catalogue exercises !)
                    ForEach(workout.sets.sorted{$0.completedAt < $1.completedAt}) { set in
                        HStack {
                            // Les infos (Reps / Poids)
                            VStack(alignment: .leading) {
                                Text(set.exercise.name)
                                    .font(.headline)
                                    // Bonus Visuel : Si complété, on barre le texte
                                    .strikethrough(set.isCompleted, color: .gray)
                                    .foregroundStyle(set.isCompleted ? .secondary : .primary)
                                
                                HStack {
                                    Text("\(set.reps) reps")
                                    if let w = set.weight {
                                        Text("\(w.formatted()) kg")
                                    }
                                }
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                
                //Le bouton de fin de séance
                Section{
                    Button("Reprendre la séance"){
                        reopenWorkout()
                    }
                }
            }
            // C'est ici qu'on définit le titre, le parent l'affichera
            .navigationTitle(workout.name ?? "Nouvelle Séance")
            // Une petite astuce pour initialiser le picker avec le premier exo dispo
            .onAppear {
                if selectedExercise == nil {
                    selectedExercise = exercises.first
                }
            }
        }
    }
    
    // LA LOGIQUE MÉTIER
    func addSet() {
        // Guard clause : On vérifie qu'on a bien un exercice
        guard let exercise = selectedExercise else { return }
        
        // 1. Création
        let newSet = WorkoutSet(reps: reps, weight: weight, exercise: exercise)
        
        // 2. Ajout (La magie SwiftData gère la relation inverse)
        workout.sets.append(newSet)
        
        // 3. Reset du formulaire (UX) pour enchainer
        // On garde l'exercice sélectionné car souvent on fait plusieurs séries du même
    }
    
    func deleteSet(set: WorkoutSet){
        if let tmp = workout.sets.firstIndex(where: {$0.id == set.id}) {
            workout.sets.remove(at: tmp)
            context.delete(set)
        }
    }
    
    func finishWorkout(){
        workout.finishedAt = Date.now
        workout.scheduledAt = Date.now
    }
    
    func reopenWorkout(){
        workout.finishedAt = nil
    }
}

struct WorkoutSetRow: View {
    // On utilise Bindable pour pouvoir modifier le set (le cocher)
    @Bindable var set: WorkoutSet
    
    var body: some View {
        HStack {
                        
            // Les infos (Reps / Poids)
            VStack(alignment: .leading) {
                Text(set.exercise.name)
                    .font(.headline)
                    // Bonus Visuel : Si complété, on barre le texte
                    .strikethrough(set.isCompleted, color: .gray)
                    .foregroundStyle(set.isCompleted ? .secondary : .primary)
                
                HStack {
                    Text("\(set.reps) reps")
                    if let w = set.weight {
                        Text("\(w.formatted()) kg")
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            // TODO 1 : Le Bouton "Check"
            Button(action: {
                // TODO 2 : La logique
                // Comment inverser un booléen en une ligne ? (true -> false, false -> true)
                // Indice Swift : set.isCompleted.t.....()
                set.isCompleted.toggle()
            }) {
                // Le visuel du bouton
                Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(set.isCompleted ? .green : .gray)
            }
            .buttonStyle(.plain) // Important pour ne pas rendre toute la ligne cliquable

        }
        .padding(.vertical, 4)
    }
}

// Preview corrigée
#Preview {
    // Build a schema that includes all models used in the preview
    let schema = Schema([
        Workout.self,
        WorkoutSet.self,
        Exercise.self
    ])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    // Create sample data
    let pushup = Exercise(name: "Pompes", muscleGroup: "Pectoraux", type: .push)
    let pullup = Exercise(name: "Tractions", muscleGroup: "Dos", type: .pull)
    let set1 = WorkoutSet(reps: 10, exercise: pushup)
    let set2 = WorkoutSet(reps: 10, exercise: pullup)
    
    let tomorrow = Date.now.addingTimeInterval(86400)
    
    let demoWorkout = Workout(name: "Séance Dos", sets: [set1, set2], scheduledAt: tomorrow)

    // Insert into the in-memory context
    container.mainContext.insert(demoWorkout)

    return NavigationStack {
        WorkoutDetailView(workout: demoWorkout)
        .modelContainer(container)}
}
