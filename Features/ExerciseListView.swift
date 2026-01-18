import SwiftUI
import SwiftData

struct ExerciseListView: View {
    // 1. L'INJECTION DE DÉPENDANCE (Le Context)
    // C'est ta "Session" de base de données (comme `db: Session` dans FastAPI).
    // On en a besoin pour faire des insert/delete.
    @Environment(\.modelContext) private var context
    
    // 2. LA REQUÊTE (Le Select)
    // @Query est une macro magique.
    // Elle fait : "SELECT * FROM Exercise ORDER BY name".
    // Le plus fou : Si la table change, cette variable se met à jour et l'écran se redessine.
    @Query(sort: \Exercise.name) private var exercises: [Exercise]
    
    // 3. LE CORPS DE LA VUE (Le HTML/Template)
    var body: some View {
        NavigationStack {
            List {
                // Boucle For-Each sur les résultats de la requête
                ForEach(exercises) { exercise in
                    HStack {
                        Text(exercise.name)
                            .font(.headline)
                        Spacer()
                        
                        HStack(spacing: 4) {
                                Text(exercise.type.rawValue)
                                    .font(.caption)
                                    .foregroundStyle(.white)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(exercise.type.color)) // Gris très clair natif iOS
                            .clipShape(Capsule()) // Arrondir les bords
                        
                    }
                }
                // Swipe-to-delete natif
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Exercices")
            .toolbar {
                // Un bouton temporaire pour tester l'ajout
                Button("Ajouter Test", systemImage: "plus") {
                    addTestExercise()
                }
            }
        }
    }
    
    // 4. FONCTIONS (Logique Métier basique)
    
    func addTestExercise() {
        // Création de l'objet (Instance)
        let pullup = Exercise(name: "Traction", muscleGroup: "Dos", type: ExerciseType.pull)
        let pushup = Exercise(name: "Pompes", muscleGroup: "Pectoraux", type: ExerciseType.push)
        
        // Insertion en base (db.add(obj))
        context.insert(pushup)
        
        // Pas besoin de context.save(), SwiftData le fait automatiquement à la fin de la boucle d'événement !
    }
    
    func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let exerciseToDelete = exercises[index]
            context.delete(exerciseToDelete)
        }
    }
}

// Ceci sert juste à la prévisualisation dans Xcode (Canvas à droite)
#Preview {
    ExerciseListView()
        .modelContainer(for: Exercise.self, inMemory: true)
}
