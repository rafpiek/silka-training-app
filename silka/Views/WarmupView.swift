//
//  WarmupView.swift
//  silka
//
//  Created by Rafał Piekara on 08/09/2025.
//

import SwiftUI
import SwiftData

struct WarmupView: View {
    @Query private var trainingPlans: [TrainingPlan]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    private var warmupExercises: [WarmupExercise] {
        trainingPlans.first?.warmupExercises ?? []
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(warmupExercises) { exercise in
                        WarmupExerciseCard(exercise: exercise)
                    }
                    
                    if !warmupExercises.isEmpty {
                        Button(action: {
                            // Reset all warmup exercises
                            for exercise in warmupExercises {
                                exercise.isCompleted = false
                                exercise.completedAt = nil
                            }
                            try? modelContext.save()
                        }) {
                            Label("Reset All Warmups", systemImage: "arrow.counterclockwise")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.orange)
                        .padding(.top)
                    }
                }
                .padding()
            }
            .navigationTitle("Warmup & Knee Rehab")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct WarmupExerciseCard: View {
    @Bindable var exercise: WarmupExercise
    @Environment(\.modelContext) private var modelContext
    @State private var showingVideo = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(exercise.nameEn)
                        .font(.headline)
                    Text(exercise.namePl)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    exercise.isCompleted.toggle()
                    if exercise.isCompleted {
                        exercise.completedAt = Date()
                    } else {
                        exercise.completedAt = nil
                    }
                    try? modelContext.save()
                }) {
                    Image(systemName: exercise.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(exercise.isCompleted ? .green : .gray)
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Label(exercise.sets, systemImage: "number")
                        .font(.subheadline)
                    Label(exercise.tempo, systemImage: "metronome")
                        .font(.subheadline)
                }
                
                Spacer()
                
                if exercise.videoUrl != nil {
                    Button(action: { showingVideo = true }) {
                        Label("Video", systemImage: "play.circle.fill")
                            .font(.subheadline)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
        .background(exercise.isCompleted ? Color.green.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(12)
        .sheet(isPresented: $showingVideo) {
            if let videoUrl = exercise.videoUrl {
                WarmupVideoView(url: videoUrl)
            }
        }
    }
}

struct WarmupVideoView: View {
    let url: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            YouTubePlayerView(url: url)
                .navigationTitle("Exercise Video")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
    }
}