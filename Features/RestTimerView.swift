import SwiftUI
internal import Combine

struct RestTimerView: View {
    // État du timer
    @State private var timeRemaining: Int = 0
    @State private var timerActive = false
    @State private var totalTime: Double = 0 // Pour la barre de progression
    
    // Le déclencheur (1 tic par seconde)
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 12) {
            if timerActive {
                // --- MODE: EN COURS ---
                HStack {
                    // TODO: Afficher le temps formaté (ex: "01:30")
                    Text(formatTime(timeRemaining))
                        .font(.largeTitle.monospacedDigit())
                        .bold()
                        .contentTransition(.numericText()) // Joli effet iOS 17
                    
                    Spacer()
                    
                    Button(role: .destructive) {
                        stopTimer()
                    } label: {
                        Image(systemName: "stop.circle.fill")
                            .font(.system(size: 40))
                    }
                }
                
                // Barre de progression visuelle
                ProgressView(value: Double(timeRemaining), total: totalTime)
                    .tint(.blue)
                
            } else {
                // --- MODE: SÉLECTION ---
                VStack(spacing: 10) { // Un peu d'espacement vertical
                        Text("Repos :")
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        
                        HStack(spacing: 12) { // Espacement entre les boutons
                            // On fait une boucle ou on liste les boutons
                            // Astuce : Group permet d'appliquer les modifiers à tous les boutons d'un coup
                            Group {
                                Button("+30s") { startTimer(30) }
                                Button("+1m") { startTimer(60) }
                                Button("+1m30") { startTimer(90) }
                                Button("+2m") { startTimer(120) }
                            }
                            .buttonStyle(.bordered)
                        }
                    }
            }
        }
        .padding()
        .background(.regularMaterial) // Effet de flou "Glassmorphism"
        .cornerRadius(16)
        .shadow(radius: 5)
        .padding() // Marge extérieure par rapport au bord de l'écran
        .frame(maxHeight: .infinity, alignment: .bottom) //la barre en bas
        
        // 👇 LA LOGIQUE DU TEMPS
        .onReceive(timer) { _ in
            // 1. Si le timer n'est pas actif, on ne fait rien
            guard timerActive else { return }
            
            // 2. Si il reste du temps, on enlève 1 seconde
            if timeRemaining > 0 {
                withAnimation(.linear(duration: 1.0)) { // Animation fluide de la barre
                    timeRemaining -= 1
                }
            } else {
                // 3. Si on arrive à 0, on arrête tout
                stopTimer()
                
                // 4. Feedback haptique (vibration) pour prévenir l'utilisateur
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
        }
        
    }
    
    // Fonctions helper
    func startTimer(_ seconds: Int) {
        timeRemaining = seconds
        totalTime = Double(seconds)
        withAnimation {
            timerActive = true
        }
    }
    
    func stopTimer() {
        withAnimation {
            timerActive = false
        }
    }
    
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let seconds = seconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    ZStack {
        Color.gray
        RestTimerView()
    }
}
