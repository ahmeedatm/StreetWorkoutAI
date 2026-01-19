import SwiftUI
import SwiftData
internal import Combine

struct SessionRunnerView: View {
    @Environment(\.dismiss) private var dismiss
    
    // La séance à jouer
    var workout: Workout
    
    // --- ÉTATS DE LA VUE ---
    @State private var currentIndex: Int = 0
    @State private var isResting: Bool = false
    @State private var timeRemaining: Int = 120 // 2 min par défaut
    @State private var totalRestTime: Int = 120 // Pour la barre de progression
    
    // Le Timer
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Initialisation intelligente : on commence au premier exercice non fini
    init(workout: Workout) {
        self.workout = workout
        // On trouve l'index du premier set non complété (ou 0 si tout est fini)
        let firstIndex = workout.sets.firstIndex(where: { !$0.isCompleted }) ?? 0
        _currentIndex = State(initialValue: firstIndex)
    }
    
    var body: some View {
        VStack {
            // Si on a dépassé le dernier exercice, c'est fini !
            if currentIndex >= workout.sets.count {
                finishView
            } else {
                // Sinon, on alterne entre Repos et Travail
                if isResting {
                    restView
                } else {
                    exerciseView
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar) // On cache la barre du bas pour l'immersion
    }
    
    // MARK: - VUE EXERCICE (WORK)
    var exerciseView: some View {
        let currentSet = workout.sets[currentIndex]
        let currentExo = currentSet.exercise
        
        return VStack(spacing: 30) {
            // Barre de progression (Ex: 1/12)
            ProgressView(value: Double(currentIndex), total: Double(workout.sets.count))
                .padding(.horizontal)
            
            Spacer()
            
            // 1. Image / Icône de l'exo
            Image(systemName: "figure.strengthtraining.traditional") // Placeholder
                .font(.system(size: 100))
                .foregroundStyle(.blue)
                .padding()
                .background(Circle().fill(Color.blue.opacity(0.1)))
            
            // 2. Gros Titre
            Text(currentExo.name)
                .font(.system(size: 32, weight: .heavy))
                .multilineTextAlignment(.center)
            
            // 3. Instruction (Reps / Poids)
            VStack(spacing: 10) {
                Text("\(currentSet.reps)")
                    .font(.system(size: 80, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text("Répétitions")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                if let weight = currentSet.weight, weight > 0 {
                    Text("à \(weight.formatted()) kg")
                        .font(.headline)
                        .foregroundStyle(.blue)
                        .padding(.top, 4)
                }
            }
            
            Spacer()
            
            // 4. Bouton VALIDÉ
            Button {
                completeSetAndRest()
            } label: {
                Text("C'EST FAIT  ✓")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
                    .shadow(radius: 10)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - VUE REPOS (REST)
    var restView: some View {
        let nextIndex = currentIndex + 1
        let hasNext = nextIndex < workout.sets.count
        
        return VStack {
            Spacer()
            
            Text("REPOS")
                .font(.headline)
                .foregroundStyle(.secondary)
                .tracking(2)
            
            // Compte à rebours géant
            Text(timeString(time: timeRemaining))
                .font(.system(size: 90, weight: .black, design: .monospaced))
                .contentTransition(.numericText()) // Bel effet de changement de chiffre
            
            // Barre de progression du temps
            ProgressView(value: Double(timeRemaining), total: Double(totalRestTime))
                .tint(.orange)
                .padding(.horizontal, 50)
            
            // Boutons d'ajustement du temps
            HStack(spacing: 40) {
                Button("-10s") { timeRemaining = max(0, timeRemaining - 10) }
                Button("+10s") { timeRemaining += 10 }
            }
            .buttonStyle(.bordered)
            .padding(.top)
            
            Spacer()
            
            // Aperçu du prochain exercice
            if hasNext {
                let nextSet = workout.sets[nextIndex]
                VStack(spacing: 5) {
                    Text("À SUIVRE :")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(nextSet.exercise.name)
                        .font(.title3)
                        .bold()
                    Text("\(nextSet.reps) reps")
                        .foregroundStyle(.blue)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
            }
            
            // Bouton PASSER
            Button {
                skipRest()
            } label: {
                Text("PASSER LE REPOS")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange.opacity(0.15))
                    .foregroundStyle(.orange)
                    .clipShape(Capsule())
            }
            .padding(40)
        }
        // Logique du Timer
        .onReceive(timer) { _ in
            if isResting {
                if timeRemaining > 0 {
                    timeRemaining -= 1
                } else {
                    skipRest() // Fin du repos, on passe à la suite
                }
            }
        }
    }
    
    // MARK: - VUE FIN (FINISH)
    var finishView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "trophy.fill")
                .font(.system(size: 80))
                .foregroundStyle(.yellow)
            
            Text("Séance Terminée !")
                .font(.largeTitle)
                .bold()
            
            Text("Bravo, tu as complété tous les exercices.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Button("Fermer") {
                workout.finishedAt = Date.now // On marque la date de fin
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.bottom, 50)
        }
    }
    
    // MARK: - FONCTIONS LOGIQUES
    
    func completeSetAndRest() {
        // 1. Valider le set actuel
        let currentSet = workout.sets[currentIndex]
        currentSet.isCompleted = true
        currentSet.completedAt = Date.now
        
        // 2. Feedback Haptique (Vibration)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // 3. Vérifier si c'est vraiment fini
        if currentIndex + 1 >= workout.sets.count {
            // C'était le dernier, on va direct à la fin sans repos
            withAnimation {
                currentIndex += 1
            }
        } else {
            // 4. Lancer le repos
            startRest()
        }
    }
    
    func startRest() {
        timeRemaining = 120 // Reset à 2 min (ou paramètre user plus tard)
        totalRestTime = 120
        withAnimation {
            isResting = true
        }
    }
    
    func skipRest() {
        // Feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // On arrête le repos et on passe à l'index suivant
        withAnimation {
            isResting = false
            currentIndex += 1
        }
    }
    
    // Petit utilitaire pour afficher "01:30"
    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
