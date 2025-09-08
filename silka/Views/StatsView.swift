//
//  StatsView.swift
//  silka
//
//  Created by Rafał Piekara on 08/09/2025.
//

import SwiftUI
import SwiftData

struct StatsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var trainingPlans: [TrainingPlan]
    @State private var selectedExercise: String?
    @State private var exerciseSummaries: [ExerciseSummary] = []
    
    private var currentTrainingPlan: TrainingPlan? {
        trainingPlans.first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if let plan = currentTrainingPlan {
                        StatsOverviewCard(trainingPlan: plan)
                        
                        LazyVStack(spacing: 12) {
                            ForEach(exerciseSummaries, id: \.exerciseName) { summary in
                                ExerciseSummaryCard(summary: summary)
                                    .onTapGesture {
                                        selectedExercise = summary.exerciseName
                                    }
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        ContentUnavailableView(
                            "No Statistics Available",
                            systemImage: "chart.line.uptrend.xyaxis",
                            description: Text("Complete some workouts to see your progress")
                        )
                    }
                }
                .padding(.top)
            }
            .navigationTitle("Exercise Statistics")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                loadExerciseStats()
            }
            .sheet(item: Binding<IdentifiableString?>(
                get: { selectedExercise.map(IdentifiableString.init) },
                set: { selectedExercise = $0?.value }
            )) { exerciseWrapper in
                if let plan = currentTrainingPlan,
                   let stats = ExerciseStatsService.getStatsForExercise(exerciseWrapper.value, from: plan) {
                    ExerciseStatsView(exerciseStats: stats)
                }
            }
        }
    }
    
    private func loadExerciseStats() {
        guard let plan = currentTrainingPlan else { return }
        exerciseSummaries = ExerciseStatsService.getExerciseSummaries(from: plan)
    }
}

struct IdentifiableString: Identifiable {
    let id = UUID()
    let value: String
}

struct StatsOverviewCard: View {
    let trainingPlan: TrainingPlan
    
    private var totalWorkouts: Int {
        trainingPlan.trainingSessions.filter { $0.isCompleted }.count
    }
    
    private var totalExercisesCompleted: Int {
        trainingPlan.trainingSessions
            .flatMap { $0.exercises }
            .filter { $0.isCompleted }.count
    }
    
    private var uniqueExercises: Int {
        Set(trainingPlan.trainingSessions
            .flatMap { $0.exercises }
            .filter { $0.isCompleted }
            .map { $0.nameEn }).count
    }
    
    private var totalVolume: Double {
        trainingPlan.trainingSessions
            .filter { $0.isCompleted }
            .flatMap { $0.exercises }
            .filter { $0.isCompleted }
            .flatMap { exercise in
                exercise.setsData.values.compactMap { setData in
                    guard setData.isCompleted, let weight = setData.weight, let reps = setData.reps else { return nil }
                    return weight * Double(reps)
                }
            }
            .reduce(0, +)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Training Overview")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Your fitness journey at a glance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chart.bar.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            HStack(spacing: 0) {
                StatMetric(
                    title: "Workouts",
                    value: "\(totalWorkouts)",
                    color: .green
                )
                
                Divider()
                    .frame(height: 50)
                
                StatMetric(
                    title: "Exercises",
                    value: "\(totalExercisesCompleted)",
                    color: .blue
                )
                
                Divider()
                    .frame(height: 50)
                
                StatMetric(
                    title: "Volume",
                    value: String(format: "%.0fkg", totalVolume),
                    color: .orange
                )
                
                Divider()
                    .frame(height: 50)
                
                StatMetric(
                    title: "Types",
                    value: "\(uniqueExercises)",
                    color: .purple
                )
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct StatMetric: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ExerciseSummaryCard: View {
    let summary: ExerciseSummary
    
    private var trendIcon: String {
        switch summary.trend {
        case .increasing:
            return "arrow.up.right"
        case .decreasing:
            return "arrow.down.right"
        case .stable:
            return "arrow.right"
        case .insufficient:
            return "questionmark"
        }
    }
    
    private var trendColor: Color {
        switch summary.trend {
        case .increasing:
            return .green
        case .decreasing:
            return .red
        case .stable:
            return .orange
        case .insufficient:
            return .gray
        }
    }
    
    private var formattedLastPerformed: String {
        guard let date = summary.lastPerformed else { return "Never" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(summary.exerciseName)
                            .font(.headline)
                            .lineLimit(1)
                        Text(summary.exerciseNamePl)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: trendIcon)
                            .foregroundColor(trendColor)
                            .font(.caption)
                        Text("Trend")
                            .font(.caption2)
                            .foregroundColor(trendColor)
                    }
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(summary.totalSessions)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("Sessions")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    if let pr = summary.personalRecord {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(String(format: "%.0f", pr)) kg")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                            Text("PR")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let lastWeight = summary.lastWeight {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(String(format: "%.0f", lastWeight)) kg")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                            Text("Last")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(formattedLastPerformed)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Last session")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    StatsView()
        .modelContainer(for: TrainingPlan.self, inMemory: true)
}