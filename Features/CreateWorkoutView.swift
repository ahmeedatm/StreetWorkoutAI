import SwiftUI
import SwiftData

struct CreateWorkoutView: View {
    // Permet de fermer la fenêtre
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    @Query(filter: #Predicate<Workout> { $0.isTemplate == true })
    private var templates: [Workout]
    
    @Query(sort: \Exercise.name)
        private var allExercises: [Exercise]
    
    // Champs du formulaire
    @State private var name: String = ""
    @State private var scheduledDate: Date = .now
    
    // Pour afficher le sélecteur d'exercice
    @State private var showExercisePicker = false
    
    @State private var draftSets: [DraftSet] = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Détails") {
                    TextField("Nom de la séance (ex: Pecs/Dos)", text: $name)
                    
                    DatePicker("Date prévue", selection: $scheduledDate, displayedComponents: .date)
                }
                if !templates.isEmpty {
                    Section("Ou choisir un modèle") {
                        ForEach(templates) { template in
                            Button {
                                createWorkoutFromTemplate(template)
                            } label: {
                                HStack {
                                    Text(template.name ?? "Sans nom")
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Image(systemName: "arrow.right.circle")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                        // (Optionnel) Swipe to delete pour supprimer un vieux modèle
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                context.delete(templates[index])
                            }
                        }
                    }
                }
                
                Section("Programme") {
                                    if draftSets.isEmpty {
                                        Text("Aucun exercice ajouté")
                                            .foregroundStyle(.secondary)
                                            .italic()
                                    } else {
                                        // On affiche la liste des séries prévues
                                        List {
                                            ForEach($draftSets) { $draft in
                                                HStack {
                                                    // Nom de l'exo
                                                    VStack(alignment: .leading) {
                                                        Text(draft.exercise.name)
                                                            .fontWeight(.medium)
                                                        Text(draft.exercise.muscleGroup)
                                                            .font(.caption)
                                                            .foregroundStyle(.secondary)
                                                    }
                                                    
                                                    Spacer()
                                                    
                                                    // Champs pour modifier Reps / Poids
                                                    HStack(spacing: 10) {
                                                        VStack {
                                                            Text("Reps")
                                                                .font(.caption2)
                                                                .foregroundStyle(.secondary)
                                                            TextField("10", value: $draft.targetReps, format: .number)
                                                                .keyboardType(.numberPad)
                                                                .multilineTextAlignment(.center)
                                                                .frame(width: 40)
                                                                .padding(4)
                                                                .background(Color.gray.opacity(0.1))
                                                                .cornerRadius(6)
                                                        }
                                                        
//                                                        VStack {
//                                                            Text("kg")
//                                                                .font(.caption2)
//                                                                .foregroundStyle(.secondary)
//                                                            TextField("-", value: $draft.targetWeight, format: .number)
//                                                                .keyboardType(.decimalPad)
//                                                                .multilineTextAlignment(.center)
//                                                                .frame(width: 50)
//                                                                .padding(4)
//                                                                .background(Color.gray.opacity(0.1))
//                                                                .cornerRadius(6)
//                                                        }
                                                    }
                                                }
                                            }
                                            // Swipe to delete une série prévue
                                            .onDelete { indexSet in
                                                draftSets.remove(atOffsets: indexSet)
                                            }
                                        }
                                    }
                                    
                                    // Bouton pour ouvrir le menu d'ajout
                                    Button {
                                        showExercisePicker = true
                                    } label: {
                                        Label("Ajouter un exercice", systemImage: "plus.circle.fill")
                                    }
                                }
                
                Section {
                    Button("Créer la séance") {
                        createWorkout()
                    }
                    .bold()
                    .disabled(name.isEmpty) // On empêche de créer sans nom
                }
            }
            .navigationTitle("Nouvelle Séance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Bouton Annuler en haut à gauche
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showExercisePicker) {
                NavigationStack {
                    List(allExercises) { exercise in
                        Button {
                            addExerciseToDraft(exercise)
                            showExercisePicker = false
                        } label: {
                            HStack {
                                Text(exercise.name)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text(exercise.type.rawValue)
                                    .font(.caption)
                                    .padding(6)
                                    .background(exercise.type.color.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                        }.foregroundStyle(.primary)
                    }
                    .navigationTitle("Choisir un exercice")
                    .toolbar {
                        Button("Fermer") { showExercisePicker = false }
                    }
                }
                .presentationDetents([.medium, .large]) // Permet d'avoir une demi-fenêtre sympa
            }
        }
    }
    
    func addExerciseToDraft(_ exercise: Exercise) {
            // On ajoute une série par défaut (10 reps)
            let newDraft = DraftSet(exercise: exercise, targetReps: 10, targetWeight: nil)
            draftSets.append(newDraft)
            
            // Optionnel : On ferme le sheet après un clic ?
            // showExercisePicker = false
            // -> Je préfère le laisser ouvert pour pouvoir cliquer plusieurs fois (ex: ajouter 4 séries de Pompes d'affilée)
        }
        
    func createWorkout() {
        // 1. Créer la séance
        let finalName = name.isEmpty ? "Séance du \(scheduledDate.formatted(.dateTime.day().month()))" : name
        
        let newWorkout = Workout(
            name: finalName,
            sets: [], // On initialise vide
            scheduledAt: scheduledDate,
            isTemplate: false
        )
        
        // 2. Convertir les DraftSets en vrais WorkoutSets
        for draft in draftSets {
            let realSet = WorkoutSet(
                reps: draft.targetReps,
                weight: draft.targetWeight,
                exercise: draft.exercise
            )
            // Important : isCompleted est false par défaut, c'est ce qu'on veut (à faire)
            newWorkout.sets.append(realSet)
        }
        
        // 3. Sauvegarder
        context.insert(newWorkout)
        dismiss()
    }
    
    func createWorkoutFromTemplate(_ template: Workout) {
        // 1. On crée une VRAIE séance (isTemplate = false) basée sur le modèle
        let newSession = Workout(
            name: template.name, // On reprend le nom du template
            sets: [],
            scheduledAt: Date.now,
            isTemplate: false // C'est une séance active !
        )
        
        // 2. On clone les sets du template vers la nouvelle session
        for templateSet in template.sets {
            let activeSet = WorkoutSet(
                reps: templateSet.reps,
                weight: templateSet.weight,
                exercise: templateSet.exercise
            )
            newSession.sets.append(activeSet)
        }
        
        // 3. Insert & Fermer
        context.insert(newSession)
        dismiss()
    }
}

struct DraftSet: Identifiable {
    let id = UUID()
    var exercise: Exercise
    var targetReps: Int = 10
    var targetWeight: Double? = nil
}

#Preview {
    CreateWorkoutView()
}
