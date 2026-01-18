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
        let newExercise = Exercise(name: name, muscleGroup: selectedMuscle, type: types)
        
        // 2. Insérer dans le contexte (DB)
        context.insert(newExercise)
        
        // 3. Fermer la fenêtre
        dismiss()
    }
}

#Preview {
    AddExerciseView()
}
