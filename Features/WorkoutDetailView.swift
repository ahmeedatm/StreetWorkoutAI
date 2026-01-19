import SwiftUI
import SwiftData

struct WorkoutDetailView: View {
    @Environment(\.modelContext) private var context
    
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    @Bindable var workout: Workout
    
    // Variables du formulaire d'ajout
    @State private var reps: Int = 10
    @State private var weight: Double?
    @State private var selectedExercise: Exercise?
    @State private var showCreateExerciseSheet: Bool = false
    @State private var showRunner: Bool = false
    
    var sortedSets: [WorkoutSet] {
            return workout.sets.sorted { $0.index < $1.index }
    }
    
    var body: some View {
        // --- CAS 1 : SÉANCE ACTIVE ---
        if workout.finishedAt == nil {
            // 👇 1. On aligne le ZStack en bas pour coller le bouton
            ZStack(alignment: .bottom) {
                
                // A. LE FOND (Le Formulaire)
                Form {
                    Section("Séries réalisées") {
                        ForEach(sortedSets) { set in
                            HStack {
                                WorkoutSetRow(set: set)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteSet(set: set)
                                } label: {
                                    Label("Supprimer", systemImage: "trash")
                                }
                            }
                        }
                    }
                    Section {
                        Button("Terminer la séance") {
                            finishWorkout()
                        }
                    }
                }
                // 👇 Important : On ajoute du vide en bas du formulaire pour que le dernier exo
                // ne soit pas caché derrière le bouton flottant quand on scrolle tout en bas.
                .safeAreaPadding(.bottom, 100)
                
                // B. LE BOUTON FLOTTANT (Posé par-dessus)
                Button {
                    showRunner = true
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Lancer la séance (Mode Focus)")
                    }
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                    .shadow(radius: 5)
                }
                .padding() // Marge autour du bouton (gauche/droite/bas)
                .background(.thinMaterial) // Petit effet flou derrière le bouton (optionnel)
            }
            // 👇 Les modifieurs sont maintenant sur le ZStack global
            .navigationTitle(workout.name ?? "Nouvelle Séance")
            .onAppear {
                if selectedExercise == nil {
                    selectedExercise = exercises.first
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreateExerciseSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                    }
                }
            }
            
            .sheet(isPresented: $showCreateExerciseSheet) {
                CreateWorkoutSetView(workout: workout)
            }
            .fullScreenCover(isPresented: $showRunner) {
                NavigationStack {
                    SessionRunnerView(workout: workout)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button("Quitter") {
                                    showRunner = false
                                }
                            }
                        }
                }
            }
            
        } else {
            // --- CAS 2 : SÉANCE TERMINÉE (ARCHIVE) ---
            // (Pas de bouton flottant ici)
            Form {
                Section("Résumé de la séance") {
                    ForEach(sortedSets) { set in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(set.exercise.name)
                                    .font(.headline)
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
                
                Section {
                    Button("Reprendre la séance") {
                        reopenWorkout()
                    }
                }
                Section {
                    Button("Enregistrer comme Modèle") {
                        saveAsTemplate()
                    }
                    .foregroundStyle(.blue)
                }
            }
            .navigationTitle(workout.name ?? "Séance terminée")
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
    
    func saveAsTemplate() {
        // 1. On crée le conteneur, mais on le marque comme TEMPLATE
        let template = Workout(
            name: "Routine: \(workout.name ?? "Sans nom")",
            sets: [],
            scheduledAt: Date.now, // La date importe peu pour un template
            isTemplate: true // <--- C'EST ICI QUE CA CHANGE
        )
        
        // 2. On copie les exercices (comme avant)
        for oldSet in workout.sets {
            let newSet = WorkoutSet(
                reps: oldSet.reps,
                weight: oldSet.weight,
                exercise: oldSet.exercise
            )
            // On remet tout à zéro pour le modèle
            newSet.isCompleted = false
            template.sets.append(newSet)
        }
        
        // 3. Sauvegarder
        context.insert(template)
        
    }
}

struct WorkoutSetRow: View {
    // On utilise Bindable pour pouvoir modifier le set (le cocher)
    @Bindable var set: WorkoutSet
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                    Text(set.exercise.type.rawValue)
                        .font(.caption)
                        .foregroundStyle(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(set.exercise.type.color)) // Gris très clair natif iOS
                .clipShape(Capsule()) // Arrondir les bords
                        
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
    
    let demoWorkout = Workout(name: "Séance Dos", sets: [set1, set2], scheduledAt: tomorrow, isTemplate: false)

    // Insert into the in-memory context
    container.mainContext.insert(demoWorkout)

    return NavigationStack {
        WorkoutDetailView(workout: demoWorkout)
        .modelContainer(container)}
}
