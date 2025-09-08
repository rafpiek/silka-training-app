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
        ZStack {
            SilkaDesign.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Timer overlay when active
                if showingTimer {
                    ModernTimerOverlay(sessionTimer: sessionTimer)
                        .padding(SilkaDesign.Spacing.md)
                        .background(SilkaDesign.Colors.surface)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }

                ScrollView {
                    LazyVStack(spacing: SilkaDesign.Spacing.md) {
                        ModernSessionHeader(session: session)
                            .padding(.top, SilkaDesign.Spacing.sm)

                        ModernWarmupButton(action: { showingWarmup.toggle() })

                        LazyVStack(spacing: SilkaDesign.Spacing.sm) {
                            ForEach(Array(session.exercises.sorted(by: { $0.sortOrder < $1.sortOrder }).enumerated()), id: \.element) { index, exercise in
                                ModernExerciseCard(
                                    exercise: exercise,
                                    number: index + 1,
                                    onTap: {
                                        selectedExercise = exercise
                                    }
                                )
                            }
                        }

                        if let cardio = session.cardio {
                            ModernCardioCard(cardio: cardio)
                        }

                        ModernCompleteSessionButton(session: session, modelContext: modelContext)
                    }
                    .padding(.horizontal, SilkaDesign.Spacing.md)
                    .padding(.bottom, SilkaDesign.Spacing.xl)
                }
            }
        }
        .navigationTitle(session.day)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if !sessionTimer.isRunning {
                        sessionTimer.start()
                    }
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingTimer.toggle()
                    }
                }) {
                    Image(systemName: showingTimer ? "timer.circle.fill" : "timer")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(sessionTimer.isRunning ? SilkaDesign.Colors.accent : SilkaDesign.Colors.textSecondary)
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

// MARK: - Modern Session Components

struct ModernSessionHeader: View {
    let session: TrainingSession

    var body: some View {
        VStack(spacing: SilkaDesign.Spacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: SilkaDesign.Spacing.xs) {
                    Text(session.focus)
                        .font(SilkaDesign.Typography.displaySmall)
                        .foregroundColor(SilkaDesign.Colors.textPrimary)
                        .lineLimit(2)

                    HStack(spacing: SilkaDesign.Spacing.sm) {
                        HStack(spacing: SilkaDesign.Spacing.xs) {
                            Image(systemName: session.location == "siłownia" ? "dumbbell" : "house")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(SilkaDesign.Colors.textSecondary)
                            Text(session.location.capitalized)
                                .font(SilkaDesign.Typography.bodyMedium)
                                .foregroundColor(SilkaDesign.Colors.textSecondary)
                        }

                        if session.isCompleted {
                            SilkaStatusBadge(text: "Completed", status: .completed)
                        }
                    }
                }

                Spacer()
            }
        }
        .padding(SilkaDesign.Spacing.lg)
        .background(SilkaDesign.Colors.surface)
        .cornerRadius(SilkaDesign.CornerRadius.lg)
        .silkaShadow()
    }
}

struct ModernTimerOverlay: View {
    @ObservedObject var sessionTimer: SessionTimer

    var body: some View {
        HStack(spacing: SilkaDesign.Spacing.md) {
            HStack(spacing: SilkaDesign.Spacing.sm) {
                Image(systemName: "stopwatch")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(SilkaDesign.Colors.accent)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Session Time")
                        .font(SilkaDesign.Typography.labelSmall)
                        .foregroundColor(SilkaDesign.Colors.textSecondary)
                    Text(timeString(from: sessionTimer.elapsedTime))
                        .font(SilkaDesign.Typography.monoMedium)
                        .foregroundColor(SilkaDesign.Colors.textPrimary)
                }
            }

            Spacer()

            Button(action: {
                if sessionTimer.isRunning {
                    sessionTimer.stop()
                } else {
                    sessionTimer.start()
                }
            }) {
                Image(systemName: sessionTimer.isRunning ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(sessionTimer.isRunning ? SilkaDesign.Colors.warning : SilkaDesign.Colors.accent)
            }
        }
    }

    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct ModernWarmupButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: SilkaDesign.Spacing.sm) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(SilkaDesign.Colors.warning)

                Text("Start Warmup")
                    .font(SilkaDesign.Typography.bodyMedium)
                    .fontWeight(.medium)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(SilkaDesign.Colors.textTertiary)
            }
            .padding(SilkaDesign.Spacing.md)
            .background(SilkaDesign.Colors.warning.opacity(0.1))
            .cornerRadius(SilkaDesign.CornerRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: SilkaDesign.CornerRadius.md)
                    .stroke(SilkaDesign.Colors.warning.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct ModernExerciseCard: View {
    @Bindable var exercise: Exercise
    let number: Int
    let onTap: () -> Void
    @State private var isPressed = false

    private func getLastUsedWeight(_ exercise: Exercise) -> Double? {
        let completedSets = exercise.setsData.filter { $0.value.isCompleted }
        return completedSets.values.compactMap { $0.weight }.last
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(alignment: .top, spacing: SilkaDesign.Spacing.md) {
                // Exercise number badge
                Text("\(number)")
                    .font(SilkaDesign.Typography.labelMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 24, height: 24)
                    .background(exercise.isCompleted ? SilkaDesign.Colors.success : SilkaDesign.Colors.accent)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: SilkaDesign.Spacing.xs) {
                    HStack {
                        Text(exercise.nameEn)
                            .font(SilkaDesign.Typography.headlineSmall)
                            .foregroundColor(SilkaDesign.Colors.textPrimary)
                            .lineLimit(2)

                        if exercise.isCompleted {
                            SilkaStatusBadge(text: "Done", status: .completed)
                        }
                    }

                    Text(exercise.namePl)
                        .font(SilkaDesign.Typography.bodyMedium)
                        .foregroundColor(SilkaDesign.Colors.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(SilkaDesign.Colors.textTertiary)
            }
            .padding(SilkaDesign.Spacing.md)

            // Exercise details
            VStack(spacing: SilkaDesign.Spacing.sm) {
                HStack {
                    // Sets & Reps
                    HStack(spacing: SilkaDesign.Spacing.xs) {
                        Image(systemName: "repeat")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(SilkaDesign.Colors.textSecondary)
                        Text(exercise.setsReps)
                            .font(SilkaDesign.Typography.labelMedium)
                            .foregroundColor(SilkaDesign.Colors.textSecondary)
                    }

                    Spacer()

                    // Progress indicator
                    Text("\(exercise.completedSets.count)/\(exercise.totalSets) sets")
                        .font(SilkaDesign.Typography.labelMedium)
                        .foregroundColor(SilkaDesign.Colors.textSecondary)
                }

                // Progress bar
                SilkaProgressBar(
                    progress: Double(exercise.completedSets.count),
                    total: Double(exercise.totalSets),
                    color: exercise.isCompleted ? SilkaDesign.Colors.success : SilkaDesign.Colors.accent,
                    height: 4
                )

                // Weight and additional info
                HStack {
                    if let lastWeight = getLastUsedWeight(exercise) {
                        HStack(spacing: SilkaDesign.Spacing.xs) {
                            Image(systemName: "scalemass")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(SilkaDesign.Colors.accent)
                            Text("\(String(format: "%.0f", lastWeight)) kg")
                                .font(SilkaDesign.Typography.labelSmall)
                                .foregroundColor(SilkaDesign.Colors.accent)
                        }
                        .padding(.horizontal, SilkaDesign.Spacing.xs)
                        .padding(.vertical, 2)
                        .background(SilkaDesign.Colors.accent.opacity(0.1))
                        .cornerRadius(SilkaDesign.CornerRadius.xs)
                    } else if let weight = exercise.startWeightKg {
                        HStack(spacing: SilkaDesign.Spacing.xs) {
                            Image(systemName: "scalemass")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(SilkaDesign.Colors.textTertiary)
                            Text("\(String(format: "%.0f", weight)) kg")
                                .font(SilkaDesign.Typography.labelSmall)
                                .foregroundColor(SilkaDesign.Colors.textTertiary)
                        }
                        .padding(.horizontal, SilkaDesign.Spacing.xs)
                        .padding(.vertical, 2)
                        .background(SilkaDesign.Colors.borderSubtle)
                        .cornerRadius(SilkaDesign.CornerRadius.xs)
                    } else if let weightPerHand = exercise.startWeightKgPerHand {
                        HStack(spacing: SilkaDesign.Spacing.xs) {
                            Image(systemName: "scalemass")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(SilkaDesign.Colors.textTertiary)
                            Text("\(String(format: "%.0f", weightPerHand)) kg/h")
                                .font(SilkaDesign.Typography.labelSmall)
                                .foregroundColor(SilkaDesign.Colors.textTertiary)
                        }
                        .padding(.horizontal, SilkaDesign.Spacing.xs)
                        .padding(.vertical, 2)
                        .background(SilkaDesign.Colors.borderSubtle)
                        .cornerRadius(SilkaDesign.CornerRadius.xs)
                    }

                    if let rir = exercise.rir {
                        HStack(spacing: SilkaDesign.Spacing.xs) {
                            Text("RIR")
                                .font(SilkaDesign.Typography.labelSmall)
                                .foregroundColor(SilkaDesign.Colors.textTertiary)
                            Text(rir)
                                .font(SilkaDesign.Typography.labelSmall)
                                .fontWeight(.medium)
                                .foregroundColor(SilkaDesign.Colors.textSecondary)
                        }
                        .padding(.horizontal, SilkaDesign.Spacing.xs)
                        .padding(.vertical, 2)
                        .background(SilkaDesign.Colors.borderSubtle)
                        .cornerRadius(SilkaDesign.CornerRadius.xs)
                    }

                    Spacer()
                }
            }
            .padding(.horizontal, SilkaDesign.Spacing.md)
            .padding(.bottom, SilkaDesign.Spacing.md)
        }
        .background(SilkaDesign.Colors.surface)
        .cornerRadius(SilkaDesign.CornerRadius.md)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .silkaShadow()
        .onTapGesture(perform: onTap)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct ModernCardioCard: View {
    let cardio: String

    var body: some View {
        HStack(spacing: SilkaDesign.Spacing.md) {
            HStack(spacing: SilkaDesign.Spacing.sm) {
                Image(systemName: "figure.run")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(SilkaDesign.Colors.warning)

                VStack(alignment: .leading, spacing: SilkaDesign.Spacing.xs) {
                    Text("Cardio")
                        .font(SilkaDesign.Typography.headlineSmall)
                        .foregroundColor(SilkaDesign.Colors.textPrimary)

                    Text(cardio)
                        .font(SilkaDesign.Typography.bodyMedium)
                        .foregroundColor(SilkaDesign.Colors.textSecondary)
                }
            }

            Spacer()

            SilkaStatusBadge(text: "Optional", status: .info)
        }
        .padding(SilkaDesign.Spacing.md)
        .background(SilkaDesign.Colors.warning.opacity(0.05))
        .cornerRadius(SilkaDesign.CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: SilkaDesign.CornerRadius.md)
                .stroke(SilkaDesign.Colors.warning.opacity(0.2), lineWidth: 1)
        )
    }
}

struct ModernCompleteSessionButton: View {
    @Bindable var session: TrainingSession
    let modelContext: ModelContext

    var allExercisesCompleted: Bool {
        session.exercises.allSatisfy { $0.isCompleted }
    }

    var body: some View {
        VStack(spacing: SilkaDesign.Spacing.sm) {
            // Complete Session Button
            Button(action: {
                session.isCompleted = true
                session.completedDate = Date()
                try? modelContext.save()
            }) {
                HStack(spacing: SilkaDesign.Spacing.sm) {
                    Image(systemName: session.isCompleted ? "checkmark.circle.fill" : "checkmark.circle")
                        .font(.system(size: 16, weight: .medium))

                    Text(session.isCompleted ? "Session Completed" : "Complete Session")
                        .font(SilkaDesign.Typography.bodyMedium)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding(SilkaDesign.Spacing.md)
                .background(
                    session.isCompleted ? SilkaDesign.Colors.success :
                    (allExercisesCompleted ? SilkaDesign.Colors.accent : SilkaDesign.Colors.textTertiary)
                )
                .foregroundColor(.white)
                .cornerRadius(SilkaDesign.CornerRadius.md)
            }
            .disabled(session.isCompleted || !allExercisesCompleted)
            .opacity((session.isCompleted || !allExercisesCompleted) ? 0.6 : 1.0)

            // Reset Session Button
            Button(action: {
                for exercise in session.exercises {
                    exercise.resetSets()
                }
                session.isCompleted = false
                session.completedDate = nil
                try? modelContext.save()
            }) {
                HStack(spacing: SilkaDesign.Spacing.sm) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 16, weight: .medium))

                    Text("Reset Session")
                        .font(SilkaDesign.Typography.bodyMedium)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .padding(SilkaDesign.Spacing.md)
                .background(SilkaDesign.Colors.surface)
                .foregroundColor(SilkaDesign.Colors.warning)
                .cornerRadius(SilkaDesign.CornerRadius.md)
                .overlay(
                    RoundedRectangle(cornerRadius: SilkaDesign.CornerRadius.md)
                        .stroke(SilkaDesign.Colors.warning.opacity(0.3), lineWidth: 1)
                )
            }

            // Progress indicator
            if !allExercisesCompleted && !session.isCompleted {
                HStack {
                    Text("Complete all exercises to finish session")
                        .font(SilkaDesign.Typography.labelMedium)
                        .foregroundColor(SilkaDesign.Colors.textSecondary)
                    Spacer()
                    Text("\(session.exercises.filter { $0.isCompleted }.count)/\(session.exercises.count)")
                        .font(SilkaDesign.Typography.labelMedium)
                        .foregroundColor(SilkaDesign.Colors.textSecondary)
                }
                .padding(.top, SilkaDesign.Spacing.xs)
            }
        }
        .padding(SilkaDesign.Spacing.lg)
        .background(SilkaDesign.Colors.surface)
        .cornerRadius(SilkaDesign.CornerRadius.lg)
        .silkaShadow()
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
