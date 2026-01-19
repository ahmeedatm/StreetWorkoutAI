import SwiftUI
import SwiftData

struct AddExerciseView: View {
    // 1. Outils pour fermer la fenêtre et accéder à la DB
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss // Permet de fermer la modale
    
    // 2. Les variables temporaires du formulaire (@State)
    // C'est le "buffer" avant la sauvegarde.
    @State private var name: String = ""
    @State private var types: ExerciseType = ExerciseType.push
    @State private var selectedMuscle: String = "Pectoraux"
    
    @State private var prWeight: Double? // Pour le poids (ex: 100 kg)
    @State private var prReps: Int?      // Pour les reps (ex: 20 reps)
    
    // Une petite liste statique pour le menu déroulant
    let muscles = ["Pectoraux", "Dos", "Jambes", "Épaules", "Bras", "Abdos", "Cardio"]
    
    var body: some View {
        NavigationStack {
            Form {
                // Section 1 : Informations de base
                Section("Détails") {
                    // $name veut dire : "Lie ce champ texte à la variable name" (Binding)
                    TextField("Nom de l'exercice (ex: Dips)", text: $name)
                    
                    Picker("Groupe Musculaire", selection: $selectedMuscle) {
                        ForEach(muscles, id: \.self) { muscle in
                            Text(muscle).tag(muscle)
                        }
                    }
                    
                    Picker("Type", selection: $types){
                        ForEach(ExerciseType.allCases, id: \.self){ type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
                Section("Définir un record initial (Optionnel)") {
                    // $name veut dire : "Lie ce champ texte à la variable name" (Binding)
                    HStack {
                        Text("Poids max (kg)")
                        Spacer()
                        TextField("0", value: $prWeight, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    HStack {
                        Text("Réps max (PDC)")
                        Spacer()
                        TextField("0", value: $prReps, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    
                }

            }
            .navigationTitle("Nouvel Exercice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Bouton Annuler (à gauche)
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                // Bouton Sauvegarder (à droite)
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sauvegarder") {
                        saveExercise()
                    }
                    // Désactivé si le nom est vide (Validation simple)
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    // Logique de sauvegarde
    func saveExercise() {
        // 1. Créer l'objet
        let newExercise = Exercise(
                    name: name,
                    muscleGroup: selectedMuscle,
                    type: types,
                )
        context.insert(newExercise)
        
        // 3. Fermer la fenêtre
        dismiss()
    }
    
    func createInitialRecord(for exercise: Exercise) {
        // On crée une séance "Archive" pour stocker ces records
        let recordWorkout = Workout(
            name: "Initialisation Records",
            sets: [], // On commence vide
            scheduledAt: Date.now.addingTimeInterval(-86400),
            isTemplate: false
        )
        recordWorkout.finishedAt = Date.now
        
        // 1. Gérer le Record de POIDS (Force)
        if let w = prWeight, w > 0 {
            let weightSet = WorkoutSet(
                reps: 1, // Par convention, un "Max Weight" est souvent sur 1 rep
                weight: w,
                exercise: exercise
            )
            weightSet.isCompleted = true
            recordWorkout.sets.append(weightSet)
        }
        
        // 2. Gérer le Record d'ENDURANCE (Reps PDC)
        if let r = prReps, r > 0 {
            let repSet = WorkoutSet(
                reps: r,
                weight: nil, // 0kg / PDC
                exercise: exercise
            )
            repSet.isCompleted = true
            recordWorkout.sets.append(repSet)
        }
        
        // 3. On sauvegarde le tout (si on a ajouté au moins un truc)
        if !recordWorkout.sets.isEmpty {
            context.insert(recordWorkout)
        }
    }
}

#Preview {
    AddExerciseView()
}
