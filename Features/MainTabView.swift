import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            // Onglet 1 : Dashboard
            HomeView() // HomeView doit contenir sa propre NavigationStack
                .tabItem { Label("Accueil", systemImage: "house") }
            
            // Onglet 2 : Historique
            WorkoutListView() // Idem, doit avoir sa NavigationStack
                .tabItem { Label("Historique", systemImage: "list.bullet") }
            
            // Onglet 3 : Exercices
            ExerciseListView() // Idem
                .tabItem { Label("Exercices", systemImage: "dumbbell") }
            
            //Onglet 4 : Profil
            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person.crop.circle")
                }
        }
    }
}

#Preview {
    MainTabView()
}
