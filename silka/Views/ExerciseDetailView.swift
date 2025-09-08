//
//  ExerciseDetailView.swift
//  silka
//
//  Created by Rafał Piekara on 08/09/2025.
//

import SwiftUI
import WebKit
import SwiftData

struct ExerciseDetailView: View {
    @Bindable var exercise: Exercise
    @ObservedObject var sessionTimer: SessionTimer
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var trainingPlans: [TrainingPlan]
    @State private var breakTimer = BreakTimer()
    @State private var showingDeleteAlert = false
    @State private var showingExerciseStats = false
    
    private var currentTrainingPlan: TrainingPlan? {
        trainingPlans.first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ExerciseHeaderView(exercise: exercise)
                    
                    if let videoUrl = exercise.videoUrl, !videoUrl.isEmpty {
                        YouTubePlayerView(url: videoUrl)
                            .frame(height: 220)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    
                    ExerciseDetailsCard(exercise: exercise)
                    
                    TimerSection(breakTimer: breakTimer)
                    
                    ExerciseActionsView(
                        exercise: exercise,
                        onSkip: {
                            dismiss()
                        },
                        onDelete: {
                            showingDeleteAlert = true
                        }
                    )
                }
                .padding(.vertical)
            }
            .navigationTitle("Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("View Stats") {
                        showingExerciseStats = true
                    }
                    .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingExerciseStats) {
                if let plan = currentTrainingPlan,
                   let stats = ExerciseStatsService.getStatsForExercise(exercise.nameEn, from: plan) {
                    ExerciseStatsView(exerciseStats: stats)
                } else {
                    NavigationStack {
                        ContentUnavailableView(
                            "No Statistics Available",
                            systemImage: "chart.line.uptrend.xyaxis",
                            description: Text("Complete this exercise in more sessions to see statistics")
                        )
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    showingExerciseStats = false
                                }
                            }
                        }
                    }
                }
            }
            .alert("Delete Exercise", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let session = getSession(for: exercise) {
                        session.exercises.removeAll { $0.id == exercise.id }
                        try? modelContext.save()
                        dismiss()
                    }
                }
            } message: {
                Text("Are you sure you want to delete this exercise from the session?")
            }
        }
    }
    
    private func getSession(for exercise: Exercise) -> TrainingSession? {
        let descriptor = FetchDescriptor<TrainingSession>()
        let sessions = (try? modelContext.fetch(descriptor)) ?? []
        return sessions.first { session in
            session.exercises.contains { $0.id == exercise.id }
        }
    }
}

struct ExerciseHeaderView: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.nameEn)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(exercise.namePl)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if exercise.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(.horizontal)
    }
}

struct ExerciseDetailsCard: View {
    let exercise: Exercise
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            DetailRow(label: "Sets & Reps", value: exercise.setsReps)
            
            if let weight = exercise.startWeightKg {
                DetailRow(label: "Weight", value: "\(String(format: "%.0f", weight)) kg")
            } else if let weightPerHand = exercise.startWeightKgPerHand {
                DetailRow(label: "Weight", value: "\(String(format: "%.0f", weightPerHand)) kg per hand")
            }
            
            if let rir = exercise.rir {
                DetailRow(label: "RIR", value: rir)
            }
            
            if let tempo = exercise.tempo {
                DetailRow(label: "Tempo", value: tempo)
            }
            
            if let notes = exercise.notes {
                DetailRow(label: "Notes", value: notes)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct TimerSection: View {
    @ObservedObject var breakTimer: BreakTimer
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Break Timer")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                ForEach([30, 60, 90, 120], id: \.self) { seconds in
                    Button(action: {
                        breakTimer.setDuration(TimeInterval(seconds))
                        breakTimer.start()
                    }) {
                        Text("\(seconds)s")
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            
            if breakTimer.isRunning {
                HStack {
                    Text("Remaining: \(Int(breakTimer.remainingTime))s")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.orange)
                    Spacer()
                    Button(action: { breakTimer.stop() }) {
                        Image(systemName: "stop.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }
}

struct ExerciseActionsView: View {
    @Bindable var exercise: Exercise
    @Environment(\.modelContext) private var modelContext
    @State private var setWeights: [Int: String] = [:]
    let onSkip: () -> Void
    let onDelete: () -> Void
    
    var defaultWeight: Double {
        exercise.startWeightKg ?? exercise.startWeightKgPerHand ?? 0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Individual set tracking with weight input
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Sets")
                        .font(.headline)
                    Spacer()
                    Text("Suggested: \(formatWeight(defaultWeight))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 12) {
                    ForEach(1...exercise.totalSets, id: \.self) { setNumber in
                        HStack(spacing: 12) {
                            // Set number and checkbox
                            Button(action: {
                                let weight = Double(setWeights[setNumber] ?? "") ?? defaultWeight
                                exercise.toggleSet(setNumber, weight: weight)
                                try? modelContext.save()
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: exercise.setsData[setNumber]?.isCompleted == true ? "checkmark.circle.fill" : "circle")
                                        .font(.title2)
                                        .foregroundColor(exercise.setsData[setNumber]?.isCompleted == true ? .green : .gray)
                                    Text("Set \(setNumber)")
                                        .font(.subheadline)
                                        .foregroundColor(.primary)
                                }
                            }
                            .buttonStyle(.plain)
                            
                            Spacer()
                            
                            // Weight input
                            HStack(spacing: 4) {
                                TextField(
                                    "Weight",
                                    text: Binding(
                                        get: {
                                            if let weight = exercise.setsData[setNumber]?.weight {
                                                return String(format: "%.1f", weight)
                                            }
                                            return setWeights[setNumber] ?? String(format: "%.1f", defaultWeight)
                                        },
                                        set: { newValue in
                                            setWeights[setNumber] = newValue
                                            if let weight = Double(newValue) {
                                                exercise.updateSetWeight(setNumber, weight: weight)
                                                try? modelContext.save()
                                            }
                                        }
                                    )
                                )
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 70)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.center)
                                .disabled(exercise.setsData[setNumber]?.isCompleted == true)
                                
                                Text("kg")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            // Quick weight adjustment buttons
                            HStack(spacing: 4) {
                                Button(action: {
                                    adjustWeight(for: setNumber, by: -2.5)
                                }) {
                                    Image(systemName: "minus.circle")
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(.plain)
                                .disabled(exercise.setsData[setNumber]?.isCompleted == true)
                                
                                Button(action: {
                                    adjustWeight(for: setNumber, by: 2.5)
                                }) {
                                    Image(systemName: "plus.circle")
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(.plain)
                                .disabled(exercise.setsData[setNumber]?.isCompleted == true)
                            }
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(
                            exercise.setsData[setNumber]?.isCompleted == true ? 
                            Color.green.opacity(0.1) : 
                            Color(.systemGray6)
                        )
                        .cornerRadius(8)
                    }
                }
                
                if exercise.totalSets > 0 {
                    ProgressView(value: Double(exercise.completedSets.count), total: Double(exercise.totalSets))
                        .progressViewStyle(.linear)
                        .tint(exercise.isCompleted ? .green : .orange)
                        .padding(.top, 8)
                    
                    HStack {
                        Text("\(exercise.completedSets.count) of \(exercise.totalSets) sets completed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        if exercise.isCompleted {
                            Label("All done!", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            HStack(spacing: 12) {
                Button(action: {
                    exercise.resetSets()
                    setWeights = [:]
                    try? modelContext.save()
                }) {
                    Label("Reset", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .foregroundColor(.orange)
                
                Button(action: onSkip) {
                    Label("Skip", systemImage: "forward")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button(action: onDelete) {
                    Label("Delete", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
            }
        }
        .padding(.horizontal)
        .onAppear {
            // Initialize weights from saved data
            for setNumber in 1...exercise.totalSets {
                if let weight = exercise.setsData[setNumber]?.weight {
                    setWeights[setNumber] = String(format: "%.1f", weight)
                }
            }
        }
    }
    
    private func adjustWeight(for setNumber: Int, by amount: Double) {
        let currentWeight = Double(setWeights[setNumber] ?? "") ?? 
                           exercise.setsData[setNumber]?.weight ?? 
                           defaultWeight
        let newWeight = max(0, currentWeight + amount)
        setWeights[setNumber] = String(format: "%.1f", newWeight)
        exercise.updateSetWeight(setNumber, weight: newWeight)
        try? modelContext.save()
    }
    
    private func formatWeight(_ weight: Double) -> String {
        return String(format: "%.1f kg", weight)
    }
}

struct YouTubePlayerView: UIViewRepresentable {
    let url: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let videoID = extractYouTubeID(from: url) else { return }
        let embedURL = "https://www.youtube.com/embed/\(videoID)"
        if let url = URL(string: embedURL) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
    
    private func extractYouTubeID(from url: String) -> String? {
        let patterns = [
            "v=([^&]+)",
            "youtu\\.be/([^?]+)",
            "embed/([^?]+)"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: url, range: NSRange(url.startIndex..., in: url)),
               let range = Range(match.range(at: 1), in: url) {
                return String(url[range])
            }
        }
        
        return nil
    }
}