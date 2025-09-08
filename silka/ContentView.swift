//
//  ContentView.swift
//  silka
//
//  Created by Rafał Piekara on 08/09/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var trainingPlans: [TrainingPlan]
    @State private var selectedSession: TrainingSession?
    @State private var showSplash = true
    
    private var currentTrainingPlan: TrainingPlan? {
        trainingPlans.first
    }
    
    private let weekDays = ["Poniedziałek", "Wtorek", "Środa", "Czwartek", "Piątek", "Sobota", "Niedziela"]
    
    var body: some View {
        if showSplash {
            SplashView {
                withAnimation(.easeInOut(duration: 0.6)) {
                    showSplash = false
                }
            }
        } else {
            TabView {
                NavigationStack {
                    ScrollView {
                        VStack(spacing: 16) {
                            if let plan = currentTrainingPlan {
                                WeeklyProgressSummary(trainingPlan: plan)
                                
                                ForEach(weekDays, id: \.self) { day in
                                    if let session = plan.trainingSessions.first(where: { $0.day == day }) {
                                        TrainingDayCard(session: session)
                                            .onTapGesture {
                                                selectedSession = session
                                            }
                                    } else {
                                        RestDayCard(day: day)
                                    }
                                }
                            } else {
                                ContentUnavailableView(
                                    "No Training Plan",
                                    systemImage: "dumbbell",
                                    description: Text("Training plan data not loaded")
                                )
                            }
                        }
                        .padding()
                    }
                    .navigationTitle("Training Week")
                    .navigationDestination(item: $selectedSession) { session in
                        TrainingSessionView(session: session)
                    }
                }
                .tabItem {
                    Label("Training", systemImage: "calendar")
                }
                
                StatsView()
                    .tabItem {
                        Label("Statistics", systemImage: "chart.line.uptrend.xyaxis")
                    }
            }
            .transition(.opacity.combined(with: .scale))
        }
    }
}

struct TrainingDayCard: View {
    let session: TrainingSession
    
    private var completedExercises: Int {
        session.exercises.filter { $0.isCompleted }.count
    }
    
    private var completionPercentage: Double {
        guard session.exercises.count > 0 else { return 0 }
        return Double(completedExercises) / Double(session.exercises.count)
    }
    
    private var formattedCompletionDate: String {
        guard let date = session.completedDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with day and completion status
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(session.day)
                        .font(.headline)
                        .foregroundColor(session.isCompleted ? .green : .primary)
                    Text(session.focus)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if session.isCompleted {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.title2)
                            Text("DONE")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    } else if completedExercises > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text("IN PROGRESS")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                    }
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
            
            // Progress bar and exercise info
            VStack(spacing: 8) {
                HStack {
                    Label(session.location, systemImage: session.location == "siłownia" ? "dumbbell" : "house")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(completedExercises)/\(session.exercises.count) exercises")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(session.isCompleted ? .green : .secondary)
                }
                
                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(.systemGray4))
                            .frame(height: 4)
                            .cornerRadius(2)
                        
                        Rectangle()
                            .fill(session.isCompleted ? Color.green : Color.blue)
                            .frame(width: geometry.size.width * completionPercentage, height: 4)
                            .cornerRadius(2)
                            .animation(.easeInOut(duration: 0.3), value: completionPercentage)
                    }
                }
                .frame(height: 4)
            }
            
            // Completion date if completed
            if session.isCompleted, !formattedCompletionDate.isEmpty {
                HStack {
                    Image(systemName: "calendar.badge.checkmark")
                        .foregroundColor(.green)
                        .font(.caption)
                    Text("Completed: \(formattedCompletionDate)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(
            session.isCompleted 
            ? Color.green.opacity(0.1)
            : (completedExercises > 0 ? Color.blue.opacity(0.05) : Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    session.isCompleted 
                    ? Color.green.opacity(0.3)
                    : (completedExercises > 0 ? Color.blue.opacity(0.2) : Color.clear),
                    lineWidth: session.isCompleted ? 2 : 1
                )
        )
        .cornerRadius(12)
    }
}

struct RestDayCard: View {
    let day: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(day)
                    .font(.headline)
                Text("Rest Day")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "bed.double")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
    }
}

struct WeeklyProgressSummary: View {
    let trainingPlan: TrainingPlan
    
    private var completedSessions: Int {
        trainingPlan.trainingSessions.filter { $0.isCompleted }.count
    }
    
    private var totalSessions: Int {
        trainingPlan.trainingSessions.count
    }
    
    private var completionPercentage: Double {
        guard totalSessions > 0 else { return 0 }
        return Double(completedSessions) / Double(totalSessions)
    }
    
    private var currentStreak: Int {
        let sortedSessions = trainingPlan.trainingSessions.sorted { session1, session2 in
            let weekDays = ["Poniedziałek", "Wtorek", "Środa", "Czwartek", "Piątek", "Sobota", "Niedziela"]
            let index1 = weekDays.firstIndex(of: session1.day) ?? 0
            let index2 = weekDays.firstIndex(of: session2.day) ?? 0
            return index1 < index2
        }
        
        var streak = 0
        for session in sortedSessions {
            if session.isCompleted {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }
    
    private var totalExercisesCompleted: Int {
        trainingPlan.trainingSessions.flatMap { $0.exercises }.filter { $0.isCompleted }.count
    }
    
    private var totalExercises: Int {
        trainingPlan.trainingSessions.flatMap { $0.exercises }.count
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly Progress")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Track your training consistency")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                if currentStreak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(currentStreak)")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("streak")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Progress statistics
            HStack(spacing: 20) {
                // Sessions progress
                VStack(alignment: .center, spacing: 4) {
                    Text("\(completedSessions)/\(totalSessions)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(completionPercentage == 1.0 ? .green : .primary)
                    Text("Sessions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 30)
                
                // Exercises progress
                VStack(alignment: .center, spacing: 4) {
                    Text("\(totalExercisesCompleted)/\(totalExercises)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Exercises")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 30)
                
                // Overall percentage
                VStack(alignment: .center, spacing: 4) {
                    Text("\(Int(completionPercentage * 100))%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(completionPercentage >= 0.8 ? .green : (completionPercentage >= 0.5 ? .orange : .red))
                    Text("Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Overall progress bar
            VStack(spacing: 6) {
                HStack {
                    Text("Week Overview")
                        .font(.caption)
                        .fontWeight(.medium)
                    Spacer()
                    Text("🔥 \(currentStreak) day streak")
                        .font(.caption2)
                        .foregroundColor(.orange)
                        .opacity(currentStreak > 0 ? 1 : 0)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 6)
                            .cornerRadius(3)
                        
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: completionPercentage >= 0.8 ? [.green, .green.opacity(0.7)] : [.blue, .blue.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * completionPercentage, height: 6)
                            .cornerRadius(3)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: completionPercentage)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color(.systemGray6),
                    Color(.systemGray6).opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TrainingPlan.self, inMemory: true)
}
