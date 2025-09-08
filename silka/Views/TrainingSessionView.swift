//
//  TrainingSessionView.swift
//  silka
//
//  Created by Rafał Piekara on 08/09/2025.
//

import SwiftUI
import SwiftData

struct TrainingSessionView: View {
    @Bindable var session: TrainingSession
    @Environment(\.modelContext) private var modelContext
    @State private var selectedExercise: Exercise?
    @State private var showingWarmup = false
    @State private var sessionTimer = SessionTimer()
    @State private var showingTimer = false
    
    var body: some View {
        VStack(spacing: 0) {
            if showingTimer {
                TimerView(sessionTimer: sessionTimer)
                    .padding()
                    .background(Color(.systemGray6))
            }
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SessionHeaderView(session: session)
                    
                    Button(action: { showingWarmup.toggle() }) {
                        Label("Warmup Exercises", systemImage: "flame")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        ForEach(Array(session.exercises.sorted(by: { $0.sortOrder < $1.sortOrder }).enumerated()), id: \.element) { index, exercise in
                            ExerciseCard(
                                exercise: exercise,
                                number: index + 1,
                                onTap: {
                                    selectedExercise = exercise
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    if let cardio = session.cardio {
                        CardioCard(cardio: cardio)
                            .padding(.horizontal)
                    }
                    
                    CompleteSessionButton(session: session, modelContext: modelContext)
                        .padding()
                }
            }
        }
        .navigationTitle(session.day)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if !sessionTimer.isRunning {
                        sessionTimer.start()
                    }
                    showingTimer.toggle()
                }) {
                    Image(systemName: showingTimer ? "timer.circle.fill" : "timer")
                        .foregroundColor(sessionTimer.isRunning ? .blue : .primary)
                }
            }
        }
        .sheet(item: $selectedExercise) { exercise in
            ExerciseDetailView(exercise: exercise, sessionTimer: sessionTimer)
        }
        .sheet(isPresented: $showingWarmup) {
            WarmupView()
        }
    }
}

struct SessionHeaderView: View {
    let session: TrainingSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(session.focus)
                .font(.title2)
                .fontWeight(.semibold)
            
            HStack {
                Label(session.location, systemImage: session.location == "siłownia" ? "dumbbell" : "house")
                Spacer()
                if session.isCompleted {
                    Label("Completed", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct ExerciseCard: View {
    @Bindable var exercise: Exercise
    let number: Int
    let onTap: () -> Void
    
    private func getLastUsedWeight(_ exercise: Exercise) -> Double? {
        // Get the most recent weight from completed sets
        let completedSets = exercise.setsData.filter { $0.value.isCompleted }
        return completedSets.values.compactMap { $0.weight }.last
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(number).")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(exercise.nameEn)
                        .font(.headline)
                    if exercise.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
                
                Text(exercise.namePl)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 12) {
                    Text(exercise.setsReps)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    // Show set completion progress
                    Text("\(exercise.completedSets.count)/\(exercise.totalSets)")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(exercise.isCompleted ? Color.green.opacity(0.2) : Color.orange.opacity(0.1))
                        .cornerRadius(4)
                    
                    // Show weight used or suggested weight
                    if let lastWeight = getLastUsedWeight(exercise) {
                        Text("\(String(format: "%.0f", lastWeight)) kg")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(4)
                    } else if let weight = exercise.startWeightKg {
                        Text("\(String(format: "%.0f", weight)) kg")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(4)
                    } else if let weightPerHand = exercise.startWeightKgPerHand {
                        Text("\(String(format: "%.0f", weightPerHand)) kg/h")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(4)
                    }
                    
                    if let rir = exercise.rir {
                        Text("RIR: \(rir)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(exercise.isCompleted ? Color.green.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(12)
        .onTapGesture(perform: onTap)
    }
}

struct CardioCard: View {
    let cardio: String
    
    var body: some View {
        HStack {
            Label("Cardio", systemImage: "figure.run")
            Spacer()
            Text(cardio)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
}

struct CompleteSessionButton: View {
    @Bindable var session: TrainingSession
    let modelContext: ModelContext
    
    var allExercisesCompleted: Bool {
        session.exercises.allSatisfy { $0.isCompleted }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: {
                session.isCompleted = true
                session.completedDate = Date()
                try? modelContext.save()
            }) {
                Label(
                    session.isCompleted ? "Session Completed" : "Complete Session",
                    systemImage: session.isCompleted ? "checkmark.circle.fill" : "checkmark.circle"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(session.isCompleted || !allExercisesCompleted)
            
            Button(action: {
                // Reset all exercises
                for exercise in session.exercises {
                    exercise.resetSets()
                }
                // Reset session
                session.isCompleted = false
                session.completedDate = nil
                try? modelContext.save()
            }) {
                Label("Reset Session", systemImage: "arrow.counterclockwise")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .foregroundColor(.orange)
        }
    }
}

class SessionTimer: ObservableObject {
    @Published var elapsedTime: TimeInterval = 0
    @Published var isRunning = false
    private var timer: Timer?
    private var startTime: Date?
    
    func start() {
        if !isRunning {
            startTime = Date()
            isRunning = true
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if let startTime = self.startTime {
                    self.elapsedTime = Date().timeIntervalSince(startTime)
                }
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    func reset() {
        stop()
        elapsedTime = 0
    }
}