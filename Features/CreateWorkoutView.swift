import SwiftUI
import SwiftData

struct CreateWorkoutView: View {
    // Permet de fermer la fenêtre
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    
    // Champs du formulaire
    @State private var name: String = ""
    @State private var scheduledDate: Date = .now
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Détails") {
                    TextField("Nom de la séance (ex: Pecs/Dos)", text: $name)
                    
                    DatePicker("Date prévue", selection: $scheduledDate, displayedComponents: .date)
                }
                
                Section {
                    Button("Créer la séance") {
                        saveWorkout()
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
        }
    }
    
    func saveWorkout() {
        // 1. Créer l'objet
        let newWorkout = Workout(name: name, sets: [], scheduledAt: scheduledDate)
        
        // 2. Insérer
        context.insert(newWorkout)
        
        // 3. Fermer la fenêtre
        dismiss()
    }
}

#Preview {
    CreateWorkoutView()
}
