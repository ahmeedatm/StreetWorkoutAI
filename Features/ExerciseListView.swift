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
    
    @State private var showCreateExerciseSheet = false
    @State private var searchText = ""
    
    // 3. LE CORPS DE LA VUE (Le HTML/Template)
    var body: some View {
        NavigationStack {
                    // 👇 On appelle la sous-vue en lui passant le texte
                    ExerciseList(searchString: searchText)
                        .navigationTitle("Exercices")
                        .searchable(text: $searchText, prompt: "Rechercher (ex: Pecs, Banc...)") // La barre native iOS

                }
    }
    
    // 4. FONCTIONS (Logique Métier basique)
    
    func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let exerciseToDelete = exercises[index]
            context.delete(exerciseToDelete)
        }
    }
}

struct ExerciseList: View {
    @Environment(\.modelContext) private var context
    @Query private var exercises: [Exercise]
    
    // On passe l'init pour construire la requête
    init(searchString: String) {
        // La magie SwiftData : On construit le Prédicat dynamiquement
        _exercises = Query(filter: #Predicate {
            if searchString.isEmpty {
                return true // Si vide, on prend tout
            } else {
                // Recherche insensible à la casse
                return $0.name.localizedStandardContains(searchString)
            }
        }, sort: \Exercise.name)
    }
    
    var body: some View {
        List {
            ForEach(exercises) { exercise in
                NavigationLink {
                    // Vers le graphique de progression détaillé
                    ProgressChartDetailView(exercise: exercise)
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        
                        // --- LIGNE 1 : NOM + TYPE ---
                        HStack {
                            Text(exercise.name)
                                .font(.headline) // Le nom en gros
                            
                            Spacer()
                            
                            // Le Badge Type (Push/Pull) calé à droite
                            Text(exercise.type.rawValue)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(exercise.type.color)
                                .clipShape(Capsule())
                        }
                        
                        // --- LIGNE 2 : MUSCLE + RECORD + STATS ---
                        HStack {
                            // Le muscle en gris discret
                            VStack(alignment: .leading, spacing: 2) {
                                Text(exercise.muscleGroup)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                
                                // Afficher le nombre d'exécutions
                                HStack(spacing: 4) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.caption2)
                                    Text("\(exercise.totalCompletions) fois")
                                        .font(.caption2)
                                }
                                .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            // Le Record en bleu
                            HStack(spacing: 4) {
                                // Petite icône trophée pour le style
                                if exercise.personalRecord.contains("Max") {
                                    Image(systemName: "trophy.fill")
                                        .foregroundStyle(.yellow)
                                        .font(.caption2)
                                }
                                
                                Text(exercise.personalRecord)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundStyle(exercise.personalRecord.contains("Max") ? .blue : .secondary)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.1)) // Fond bleu très léger
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.vertical, 4) // Un peu d'air en haut et en bas de la cellule
                }            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    context.delete(exercises[index])
                }
            }
        }
        .overlay {
            if exercises.isEmpty {
                ContentUnavailableView("Aucun exercice trouvé", systemImage: "magnifyingglass")
            }
        }
    }
}

// Ceci sert juste à la prévisualisation dans Xcode (Canvas à droite)
#Preview {
    ExerciseListView()
        .modelContainer(for: Exercise.self, inMemory: true)
}
