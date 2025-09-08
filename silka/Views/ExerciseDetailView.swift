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
            ZStack {
                SilkaDesign.Colors.background
                    .ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: SilkaDesign.Spacing.lg) {
                        ModernExerciseHeader(exercise: exercise)
                            .padding(.top, SilkaDesign.Spacing.sm)

                        if let videoUrl = exercise.videoUrl, !videoUrl.isEmpty {
                            ImprovedYouTubePlayer(url: videoUrl)
                                .frame(height: 200)
                                .cornerRadius(SilkaDesign.CornerRadius.lg)
                                .silkaShadow()
                        }

                        ModernExerciseDetailsCard(exercise: exercise)

                        ModernTimerSection(breakTimer: breakTimer)

                        ModernExerciseActions(
                            exercise: exercise,
                            onSkip: {
                                dismiss()
                            },
                            onDelete: {
                                showingDeleteAlert = true
                            }
                        )
                    }
                    .padding(.horizontal, SilkaDesign.Spacing.md)
                    .padding(.bottom, SilkaDesign.Spacing.xl)
                }
            }
            .navigationTitle(exercise.nameEn)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Stats") {
                        showingExerciseStats = true
                    }
                    .font(SilkaDesign.Typography.bodyMedium)
                    .foregroundColor(SilkaDesign.Colors.accent)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(SilkaDesign.Typography.bodyMedium)
                    .fontWeight(.medium)
                    .foregroundColor(SilkaDesign.Colors.textPrimary)
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

// MARK: - Modern Exercise Detail Components

struct ModernExerciseHeader: View {
    let exercise: Exercise

    var body: some View {
        VStack(spacing: SilkaDesign.Spacing.md) {
            HStack(alignment: .top, spacing: SilkaDesign.Spacing.md) {
                VStack(alignment: .leading, spacing: SilkaDesign.Spacing.xs) {
                    Text(exercise.nameEn)
                        .font(SilkaDesign.Typography.displayMedium)
                        .foregroundColor(SilkaDesign.Colors.textPrimary)
                        .lineLimit(3)

                    Text(exercise.namePl)
                        .font(SilkaDesign.Typography.bodyLarge)
                        .foregroundColor(SilkaDesign.Colors.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                if exercise.isCompleted {
                    SilkaStatusBadge(text: "Complete", status: .completed)
                }
            }

            // Progress indicator
            VStack(spacing: SilkaDesign.Spacing.sm) {
                HStack {
                    Text("Sets Progress")
                        .font(SilkaDesign.Typography.labelMedium)
                        .foregroundColor(SilkaDesign.Colors.textSecondary)

                    Spacer()

                    Text("\(exercise.completedSets.count)/\(exercise.totalSets)")
                        .font(SilkaDesign.Typography.labelMedium)
                        .fontWeight(.medium)
                        .foregroundColor(SilkaDesign.Colors.textPrimary)
                }

                SilkaProgressBar(
                    progress: Double(exercise.completedSets.count),
                    total: Double(exercise.totalSets),
                    color: exercise.isCompleted ? SilkaDesign.Colors.success : SilkaDesign.Colors.accent,
                    height: 6
                )
            }
        }
        .padding(SilkaDesign.Spacing.lg)
        .background(SilkaDesign.Colors.surface)
        .cornerRadius(SilkaDesign.CornerRadius.lg)
        .silkaShadow()
    }
}

struct ModernExerciseDetailsCard: View {
    let exercise: Exercise

    var body: some View {
        VStack(alignment: .leading, spacing: SilkaDesign.Spacing.md) {
            Text("Exercise Details")
                .font(SilkaDesign.Typography.headlineSmall)
                .foregroundColor(SilkaDesign.Colors.textPrimary)

            VStack(spacing: SilkaDesign.Spacing.sm) {
                ModernDetailRow(label: "Sets & Reps", value: exercise.setsReps)

                if let weight = exercise.startWeightKg {
                    ModernDetailRow(label: "Weight", value: "\(String(format: "%.0f", weight)) kg")
                } else if let weightPerHand = exercise.startWeightKgPerHand {
                    ModernDetailRow(label: "Weight", value: "\(String(format: "%.0f", weightPerHand)) kg per hand")
                }

                if let rir = exercise.rir {
                    ModernDetailRow(label: "RIR", value: rir)
                }

                if let tempo = exercise.tempo {
                    ModernDetailRow(label: "Tempo", value: tempo)
                }

                if let notes = exercise.notes {
                    ModernDetailRow(label: "Notes", value: notes)
                }
            }
        }
        .padding(SilkaDesign.Spacing.lg)
        .background(SilkaDesign.Colors.surface)
        .cornerRadius(SilkaDesign.CornerRadius.lg)
        .silkaShadow()
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

struct ModernDetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(SilkaDesign.Typography.bodyMedium)
                .foregroundColor(SilkaDesign.Colors.textSecondary)
            Spacer()
            Text(value)
                .font(SilkaDesign.Typography.bodyMedium)
                .fontWeight(.medium)
                .foregroundColor(SilkaDesign.Colors.textPrimary)
        }
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

struct ModernTimerSection: View {
    @ObservedObject var breakTimer: BreakTimer

    var body: some View {
        VStack(spacing: SilkaDesign.Spacing.md) {
            HStack {
                Text("Break Timer")
                    .font(SilkaDesign.Typography.headlineSmall)
                    .foregroundColor(SilkaDesign.Colors.textPrimary)
                Spacer()
                if breakTimer.isRunning {
                    Text("\(Int(breakTimer.remainingTime))s")
                        .font(SilkaDesign.Typography.monoMedium)
                        .foregroundColor(SilkaDesign.Colors.warning)
                }
            }

            HStack(spacing: SilkaDesign.Spacing.sm) {
                ForEach([30, 60, 90, 120], id: \.self) { seconds in
                    Button(action: {
                        breakTimer.setDuration(TimeInterval(seconds))
                        breakTimer.start()
                    }) {
                        Text("\(seconds)s")
                            .font(SilkaDesign.Typography.labelMedium)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, SilkaDesign.Spacing.sm)
                    }
                    .silkaButton(.secondary)
                }
            }

            if breakTimer.isRunning {
                HStack(spacing: SilkaDesign.Spacing.sm) {
                    VStack(alignment: .leading, spacing: SilkaDesign.Spacing.xs) {
                        Text("Break in progress")
                            .font(SilkaDesign.Typography.labelMedium)
                            .foregroundColor(SilkaDesign.Colors.textSecondary)
                        Text("\(Int(breakTimer.remainingTime)) seconds left")
                            .font(SilkaDesign.Typography.monoMedium)
                            .foregroundColor(SilkaDesign.Colors.warning)
                    }

                    Spacer()

                    Button(action: { breakTimer.stop() }) {
                        Image(systemName: "stop.circle.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(SilkaDesign.Colors.error)
                    }
                }
                .padding(SilkaDesign.Spacing.md)
                .background(SilkaDesign.Colors.warning.opacity(0.1))
                .cornerRadius(SilkaDesign.CornerRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: SilkaDesign.CornerRadius.md)
                        .stroke(SilkaDesign.Colors.warning.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .padding(SilkaDesign.Spacing.lg)
        .background(SilkaDesign.Colors.surface)
        .cornerRadius(SilkaDesign.CornerRadius.lg)
        .silkaShadow()
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

struct ModernExerciseActions: View {
    @Bindable var exercise: Exercise
    @Environment(\.modelContext) private var modelContext
    @State private var setWeights: [Int: String] = [:]
    let onSkip: () -> Void
    let onDelete: () -> Void

    var defaultWeight: Double {
        exercise.startWeightKg ?? exercise.startWeightKgPerHand ?? 0
    }

    var body: some View {
        VStack(spacing: SilkaDesign.Spacing.lg) {
            // Sets tracking section
            VStack(alignment: .leading, spacing: SilkaDesign.Spacing.md) {
                HStack {
                    Text("Track Sets")
                        .font(SilkaDesign.Typography.headlineSmall)
                        .foregroundColor(SilkaDesign.Colors.textPrimary)

                    Spacer()

                    if defaultWeight > 0 {
                        Text("Suggested: \(formatWeight(defaultWeight))")
                            .font(SilkaDesign.Typography.labelMedium)
                            .foregroundColor(SilkaDesign.Colors.textSecondary)
                    }
                }

                LazyVStack(spacing: SilkaDesign.Spacing.sm) {
                    ForEach(1...exercise.totalSets, id: \.self) { setNumber in
                        ModernSetRow(
                            exercise: exercise,
                            setNumber: setNumber,
                            setWeights: $setWeights,
                            defaultWeight: defaultWeight,
                            modelContext: modelContext
                        )
                    }
                }

                // Progress
                if exercise.totalSets > 0 {
                    VStack(spacing: SilkaDesign.Spacing.sm) {
                        SilkaProgressBar(
                            progress: Double(exercise.completedSets.count),
                            total: Double(exercise.totalSets),
                            color: exercise.isCompleted ? SilkaDesign.Colors.success : SilkaDesign.Colors.accent,
                            height: 6
                        )

                        HStack {
                            Text("\(exercise.completedSets.count) of \(exercise.totalSets) sets completed")
                                .font(SilkaDesign.Typography.labelMedium)
                                .foregroundColor(SilkaDesign.Colors.textSecondary)

                            Spacer()

                            if exercise.isCompleted {
                                SilkaStatusBadge(text: "Complete", status: .completed)
                            }
                        }
                    }
                }
            }
            .padding(SilkaDesign.Spacing.lg)
            .background(SilkaDesign.Colors.surface)
            .cornerRadius(SilkaDesign.CornerRadius.lg)
            .silkaShadow()

            // Action buttons
            HStack(spacing: SilkaDesign.Spacing.sm) {
                Button(action: {
                    exercise.resetSets()
                    setWeights = [:]
                    try? modelContext.save()
                }) {
                    HStack(spacing: SilkaDesign.Spacing.xs) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 14, weight: .medium))
                        Text("Reset")
                            .font(SilkaDesign.Typography.labelMedium)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                }
                .silkaButton(.secondary)

                Button(action: onSkip) {
                    HStack(spacing: SilkaDesign.Spacing.xs) {
                        Image(systemName: "forward")
                            .font(.system(size: 14, weight: .medium))
                        Text("Skip")
                            .font(SilkaDesign.Typography.labelMedium)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                }
                .silkaButton(.tertiary)

                Button(action: onDelete) {
                    HStack(spacing: SilkaDesign.Spacing.xs) {
                        Image(systemName: "trash")
                            .font(.system(size: 14, weight: .medium))
                        Text("Delete")
                            .font(SilkaDesign.Typography.labelMedium)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                }
                .silkaButton(.destructive)
            }
        }
        .onAppear {
            // Initialize weights from saved data
            for setNumber in 1...exercise.totalSets {
                if let weight = exercise.setsData[setNumber]?.weight {
                    setWeights[setNumber] = String(format: "%.1f", weight)
                }
            }
        }
    }

    private func formatWeight(_ weight: Double) -> String {
        return String(format: "%.1f kg", weight)
    }
}

struct ModernSetRow: View {
    @Bindable var exercise: Exercise
    let setNumber: Int
    @Binding var setWeights: [Int: String]
    let defaultWeight: Double
    let modelContext: ModelContext

    private var isCompleted: Bool {
        exercise.setsData[setNumber]?.isCompleted == true
    }

    var body: some View {
        HStack(spacing: SilkaDesign.Spacing.md) {
            // Set completion button
            Button(action: {
                let weight = Double(setWeights[setNumber] ?? "") ?? defaultWeight
                exercise.toggleSet(setNumber, weight: weight)
                try? modelContext.save()
            }) {
                HStack(spacing: SilkaDesign.Spacing.sm) {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isCompleted ? SilkaDesign.Colors.success : SilkaDesign.Colors.textTertiary)

                    Text("Set \(setNumber)")
                        .font(SilkaDesign.Typography.bodyMedium)
                        .foregroundColor(SilkaDesign.Colors.textPrimary)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            // Weight input
            HStack(spacing: SilkaDesign.Spacing.xs) {
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
                .disabled(isCompleted)

                Text("kg")
                    .font(SilkaDesign.Typography.labelMedium)
                    .foregroundColor(SilkaDesign.Colors.textSecondary)
            }

            // Quick adjustment buttons
            HStack(spacing: SilkaDesign.Spacing.xs) {
                Button(action: { adjustWeight(for: setNumber, by: -2.5) }) {
                    Image(systemName: "minus.circle")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(SilkaDesign.Colors.accent)
                }
                .buttonStyle(.plain)
                .disabled(isCompleted)

                Button(action: { adjustWeight(for: setNumber, by: 2.5) }) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(SilkaDesign.Colors.accent)
                }
                .buttonStyle(.plain)
                .disabled(isCompleted)
            }
        }
        .padding(SilkaDesign.Spacing.sm)
        .background(
            isCompleted ? SilkaDesign.Colors.success.opacity(0.1) : SilkaDesign.Colors.surface
        )
        .cornerRadius(SilkaDesign.CornerRadius.sm)
        .overlay(
            RoundedRectangle(cornerRadius: SilkaDesign.CornerRadius.sm)
                .stroke(
                    isCompleted ? SilkaDesign.Colors.success.opacity(0.3) : SilkaDesign.Colors.borderSubtle,
                    lineWidth: 1
                )
        )
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

struct ImprovedYouTubePlayer: View {
    let url: String
    @State private var hasError = false

    var body: some View {
        ZStack {
            if hasError {
                // Show fallback when there's an error
                VStack(spacing: SilkaDesign.Spacing.md) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(SilkaDesign.Colors.warning)

                    VStack(spacing: SilkaDesign.Spacing.sm) {
                        Text("Video Load Error")
                            .font(SilkaDesign.Typography.headlineSmall)
                            .foregroundColor(SilkaDesign.Colors.textPrimary)

                        Text("Unable to load video in app")
                            .font(SilkaDesign.Typography.bodyMedium)
                            .foregroundColor(SilkaDesign.Colors.textSecondary)
                    }

                    Button("Watch on YouTube") {
                        if let youtubeURL = URL(string: url) {
                            UIApplication.shared.open(youtubeURL)
                        }
                    }
                    .padding(.horizontal, SilkaDesign.Spacing.md)
                    .padding(.vertical, SilkaDesign.Spacing.sm)
                    .background(SilkaDesign.Colors.accent)
                    .foregroundColor(.white)
                    .cornerRadius(SilkaDesign.CornerRadius.sm)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(SilkaDesign.Colors.surface)
            } else {
                // Try to load YouTube player
                YouTubePlayerView(url: url, onError: {
                    hasError = true
                })
                .background(Color.black) // YouTube videos have black background while loading

                // Always show the "Open in YouTube" button as an overlay
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            if let youtubeURL = URL(string: url) {
                                UIApplication.shared.open(youtubeURL)
                            }
                        }) {
                            HStack(spacing: SilkaDesign.Spacing.xs) {
                                Image(systemName: "arrow.up.right.square")
                                    .font(.system(size: 12, weight: .medium))
                                Text("YouTube")
                                    .font(SilkaDesign.Typography.labelSmall)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, SilkaDesign.Spacing.sm)
                            .padding(.vertical, SilkaDesign.Spacing.xs)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(SilkaDesign.CornerRadius.xs)
                        }
                        .padding(SilkaDesign.Spacing.sm)
                    }
                }
            }
        }
        .cornerRadius(SilkaDesign.CornerRadius.lg)
    }
}

struct YouTubePlayerView: UIViewRepresentable {
    let url: String
    let onError: (() -> Void)?

    init(url: String, onError: (() -> Void)? = nil) {
        self.url = url
        self.onError = onError
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let videoID = extractYouTubeID(from: url) else {
            print("Failed to extract YouTube ID from URL: \(url)")
            onError?()
            return
        }

        // Use direct YouTube embed URL (this was working before)
        let embedURL = "https://www.youtube.com/embed/\(videoID)?playsinline=1&controls=1&modestbranding=1&rel=0"
        if let embedURL = URL(string: embedURL) {
            let request = URLRequest(url: embedURL)
            uiView.load(request)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: YouTubePlayerView

        init(_ parent: YouTubePlayerView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("YouTube video failed to load: \(error)")
            parent.onError?()
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            print("YouTube video failed provisional navigation: \(error)")
            parent.onError?()
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
