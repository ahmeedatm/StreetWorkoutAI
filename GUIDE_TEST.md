# 🧪 Guide de Test - StreetWorkoutAI

## Démarrage de l'App

1. Ouvrir le projet Xcode
2. Sélectionner un simulateur iOS (iPhone 15+ recommandé)
3. Appuyer sur ▶️ (Cmd+R)
4. L'app démarre avec les données de seed

---

## 🧪 Scénarios de Test

### Test 1️⃣ : Voir les Exercices (Basique)
**Étapes** :
1. Lancer l'app
2. Onglet "Exercices" (en bas)
3. Voir la liste des 17 exercices
4. Cliquer sur un exercice (ex: Pompes)
5. ✅ Voir le graphique de progression

**Attendu** :
- ✅ Liste des exercices affichée
- ✅ Lien vers graphique fonctionne
- ✅ Stats personnelles visibles

---

### Test 2️⃣ : Créer et Exécuter une Séance
**Étapes** :
1. Onglet "Historique"
2. Cliquer sur "+" (en haut à droite)
3. Remplir le formulaire :
   - Nom : "Ma Séance Test"
   - Date : aujourd'hui
4. Cliquer "Ajouter Exercices"
5. Ajouter 3 exercices (ex: Pompes 10x, Tractions 8x, Squats 15x)
6. Cliquer "Fait"
7. Cliquer "Créer Séance"
8. **Lancer la séance (Mode Focus)**

**Attendu** :
- ✅ WarmupView s'affiche avec exercices d'échauffement
- ✅ Voir "ÉCHAUFFEMENT" avec propositions
- ✅ Bouton "Passer" ou "Suivant" fonctionne

---

### Test 3️⃣ : Exécuter avec Saisie des Reps
**Étapes** (continuation du Test 2) :
1. Terminer échauffement → "Démarrer la Séance"
2. **Premier exercice** : Pompes
3. Voir le GIF/image + description
4. Cliquer "C'EST FAIT ✓"
5. **RepsCompletionView s'ouvre** :
   - Entrer 8 reps (moins que 10)
   - Sélectionner RPE : 8/10
   - Ajouter note : "Un peu fatigué"
   - Cliquer "Enregistrer"
6. Voir page de repos (2 min)
7. Continuer avec prochain exercice

**Attendu** :
- ✅ GIF affiché (ou icône si pas d'image)
- ✅ Formulaire reps fonctionne
- ✅ RPE slider fonctionne
- ✅ Progression automatique

---

### Test 4️⃣ : Recommandations Post-Séance
**Étapes** (continuation du Test 3) :
1. Compléter tous les exercices
2. Voir "Séance Terminée !"
3. Cliquer "Voir Analyse"
4. **WorkoutRecommendationView** s'ouvre

**Attendu** :
- ✅ Score de réussite en %
- ✅ Résumé personnalisé (progression/stagnation)
- ✅ Cartes de recommandations visibles
- ✅ Bouton "Adapter Intelligemment" présent

---

### Test 5️⃣ : Adapter Séance Intelligemment
**Étapes** (continuation du Test 4) :
1. Cliquer "Adapter Intelligemment la Séance"
2. Voir 3 stratégies :
   - Conservative
   - Modéré
   - Agressif
3. Sélectionner "Modéré"
4. Cocher les changements souhaités
5. Cliquer "Créer une Nouvelle Séance Adaptée"
6. Voir message "Séance créée !"

**Attendu** :
- ✅ SmartWorkoutAdaptationView s'ouvre
- ✅ Stratégies affichées
- ✅ Changements sélectionnables
- ✅ Nouvelle séance créée (visible demain)

---

### Test 6️⃣ : Dashboard (HomeView)
**Étapes** :
1. Onglet "Accueil"
2. Scroller pour voir :
   - Tuiles de stats (Séances, Volume, Exercices)
   - Prochaine séance
   - Dernier entraînement

**Attendu** :
- ✅ Stats affichées correctement
- ✅ Liens de navigation présents
- ✅ Dates affichées

---

### Test 7️⃣ : Profil Utilisateur
**Étapes** :
1. Onglet "Profil"
2. Scroller pour voir :
   - En-tête profil
   - Stats globales (cartes)
   - Exercice préféré
   - Zone de danger

**Attendu** :
- ✅ Toutes les stats affichées
- ✅ Exercice préféré = Pompes (le plus exécuté)
- ✅ Volume total correct

---

### Test 8️⃣ : Graphiques Détaillés
**Étapes** :
1. Onglet "Exercices"
2. Cliquer sur un exercice
3. **ProgressChartDetailView** s'ouvre

**Attendu** :
- ✅ Graphiques affichés (même si pas de données)
- ✅ Filtres Semaine/Mois/Tout fonctionnent
- ✅ Stats en bas visibles

---

## 🐛 Débogage Rapide

Si quelque chose ne fonctionne pas :

### 1. App ne démarre pas
```
Solution : Nettoyer le build
Cmd + Shift + K (Clean Build Folder)
Puis relancer Cmd + R
```

### 2. Erreurs de compilation
```
Solution : Vérifier console Xcode
(Cmd + 9 pour voir la console)
Chercher les erreurs rouges
```

### 3. Données n'apparaissent pas
```
Solution : Réinitialiser le simulateur
Simulator → Device → Erase All Content and Settings
Relancer l'app
```

### 4. Graphiques vides
```
Normal si c'est la première exécution
Faire plusieurs séances pour voir les données
```

---

## ✅ Checklist de Test Complet

Avant de déployer, vérifier :

- [ ] ✅ App démarre sans erreur
- [ ] ✅ Exercices affichés
- [ ] ✅ Création séance fonctionne
- [ ] ✅ Échauffement s'affiche
- [ ] ✅ GIFs chargent (ou images par défaut)
- [ ] ✅ Formulaire reps fonctionne
- [ ] ✅ Recommandations générées
- [ ] ✅ Adaptation séance crée nouvelle séance
- [ ] ✅ HomeView affiche stats
- [ ] ✅ Profil affiche stats
- [ ] ✅ Graphiques affichent données
- [ ] ✅ Navigation fonctionne bien
- [ ] ✅ Pas d'erreurs dans la console

---

## 🚀 Tips pour Tester Rapidement

### Ajouter plusieurs séances
1. Créer 3-4 séances avec dates différentes
2. Exécuter chacune en changeant les reps
3. Voir les patterns émerger

### Voir les Recommandations
1. Exécuter une séance en faisant **plus** que prévu
2. Voir recommandation "AUGMENTER"
3. Adapter intelligemment
4. Voir nouvelle séance créée

### Tester l'Adaptation
1. Créer séance facile
2. L'exécuter en sur-performant
3. Voir recommandation d'augmentation
4. Choisir "Agressif"
5. Voir nouveaux reps plus élevés

---

## 📊 Données de Test

La base de données est pré-remplie avec 17 exercices :

**Push** : Pompes, Dips, Pompes Diamant, Handstand Push-ups, Planche Lean
**Pull** : Tractions Pronation, Tractions Supination, Australian Pull-ups, Muscle-up, Front Lever Hold
**Legs** : Squats, Pistol Squats, Fentes, Calf Raises
**Core** : Relevés de Jambes, L-Sit, Plank

Tous avec GIFs + descriptions techniques.

---

## 💡 FAQ Test

**Q: Pourquoi pas de GIF au démarrage ?**
A: Les GIFs chargent depuis Giphy. Si internet est lent, elles apparaissent en retard.

**Q: Combien de séances avant de voir patterns ?**
A: 3-4 séances minimum pour voir les recommandations changer.

**Q: Les stats zéro sont normales ?**
A: Oui au démarrage. Elles se remplissent après les séances.

**Q: Comment réinitialiser tout ?**
A: Onglet Profil → "Réinitialiser l'historique" → Supprimer

---

**Bon test ! 🧪**
