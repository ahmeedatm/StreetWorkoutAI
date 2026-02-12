import SwiftUI
import Charts

struct ProgressChartDetailView: View {
    var exercise: Exercise
    @State private var timeframe: ChartTimeframe = .month
    
    enum ChartTimeframe: String, CaseIterable {
        case week = "Semaine"
        case month = "Mois"
        case allTime = "Tout"
    }
    
    var chartData: [(date: Date, reps: Int, weight: Double?)] {
        let performances = exercise.performanceHistory
            .sorted { $0.completedAt < $1.completedAt }
        
        let cutoffDate: Date
        switch timeframe {
        case .week:
            cutoffDate = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        case .month:
            cutoffDate = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        case .allTime:
            cutoffDate = Date.distantPast
        }
        
        return performances
            .filter { $0.completedAt > cutoffDate }
            .map { (date: $0.completedAt, reps: $0.repsCompleted, weight: $0.weight) }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Sélecteur de période
                    Picker("Période", selection: $timeframe) {
                        ForEach(ChartTimeframe.allCases, id: \.self) { frame in
                            Text(frame.rawValue).tag(frame)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    if chartData.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 40))
                                .foregroundStyle(.gray)
                            Text("Pas de données")
                                .foregroundStyle(.secondary)
                        }
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding()
                    } else {
                        // Chart des Reps
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Progression des Reps")
                                .font(.headline)
                            
                            Chart {
                                ForEach(chartData, id: \.date) { data in
                                    LineMark(
                                        x: .value("Date", data.date),
                                        y: .value("Reps", data.reps)
                                    )
                                    .foregroundStyle(.blue)
                                    
                                    PointMark(
                                        x: .value("Date", data.date),
                                        y: .value("Reps", data.reps)
                                    )
                                    .foregroundStyle(.blue)
                                }
                            }
                            .frame(height: 200)
                            .chartYAxis {
                                AxisMarks(position: .leading)
                            }
                            .chartXAxis {
                                AxisMarks(format: .dateTime.day().month())
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Chart des Poids si disponible
                        let weightData = chartData.filter { $0.weight ?? 0 > 0 }
                        if !weightData.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Progression du Poids")
                                    .font(.headline)
                                
                                Chart {
                                    ForEach(weightData, id: \.date) { data in
                                        LineMark(
                                            x: .value("Date", data.date),
                                            y: .value("Poids", data.weight ?? 0)
                                        )
                                        .foregroundStyle(.orange)
                                        
                                        PointMark(
                                            x: .value("Date", data.date),
                                            y: .value("Poids", data.weight ?? 0)
                                        )
                                        .foregroundStyle(.orange)
                                    }
                                }
                                .frame(height: 200)
                                .chartYAxis {
                                    AxisMarks(position: .leading)
                                }
                                .chartXAxis {
                                    AxisMarks(format: .dateTime.day().month())
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        // Statistiques
                        VStack(spacing: 12) {
                            StatCard(
                                label: "Reps Max",
                                value: "\(exercise.personalRecordReps ?? 0)",
                                icon: "arrow.up"
                            )
                            StatCard(
                                label: "Moyenne",
                                value: String(format: "%.1f", exercise.averageReps),
                                icon: "chart.bar"
                            )
                            StatCard(
                                label: "Total Exécutions",
                                value: "\(exercise.totalCompletions)",
                                icon: "checkmark.circle"
                            )
                        }
                        .padding()
                    }
                }
                .padding()
            }
            .navigationTitle(exercise.name)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct StatCard: View {
    let label: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.headline)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    let exercise = Exercise(name: "Pompes", muscleGroup: "Pectoraux", type: .push)
    ProgressChartDetailView(exercise: exercise)
}
