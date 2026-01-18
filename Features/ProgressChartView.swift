import SwiftUI
import Charts
import SwiftData

struct ProgressChartView: View {
    // On reçoit la liste des séances
    let workouts: [Workout]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Progression du Volume (kg)")
                .font(.headline)
                .padding(.bottom, 5)
            
            if workouts.isEmpty {
                // État vide (si aucune séance n'existe)
                ContentUnavailableView("Pas assez de données", systemImage: "chart.xyaxis.line")
                    .frame(height: 200)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            } else {
                // LE GRAPHIQUE
                Chart {
                    ForEach(workouts) { workout in
                        // 1. La Ligne
                        LineMark(
                            x: .value("Date", workout.scheduledAt),
                            y: .value("Volume", workout.totalVolume)
                        )
                        .foregroundStyle(.blue)
                        .interpolationMethod(.catmullRom) // Courbe arrondie
                        
                        // 2. Les Points (pour marquer chaque séance)
                        PointMark(
                            x: .value("Date", workout.scheduledAt),
                            y: .value("Volume", workout.totalVolume)
                        )
                        .foregroundStyle(.blue)
                    }
                }
                .frame(height: 200) // Hauteur obligatoire
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            // Petite astuce pour enlever les décimales inutiles (.0)
                            if let doubleValue = value.as(Double.self) {
                                Text("\(doubleValue.formatted())")
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
