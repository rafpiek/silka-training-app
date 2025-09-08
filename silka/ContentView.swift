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
            // RADICAL LINEAR-INSPIRED DESIGN: Full-width minimal layout
                NavigationStack {
                ZStack {
                    SilkaDesign.Colors.background
                        .ignoresSafeArea()

                    ScrollView {
                        LazyVStack(spacing: SilkaDesign.Spacing.xl) {
                            if let plan = currentTrainingPlan {
                                // Ultra-minimal header
                                LinearHeader(plan: plan)

                                // Linear-style session list
                                LinearSessionList(
                                    plan: plan,
                                    weekDays: weekDays,
                                    selectedSession: $selectedSession
                                )
                            } else {
                                LinearEmptyState()
                            }
                        }
                        .padding(.horizontal, SilkaDesign.Spacing.lg)
                        .padding(.vertical, SilkaDesign.Spacing.lg)
                    }
                }
                .navigationBarHidden(true)
                .navigationDestination(item: $selectedSession) { session in
                    TrainingSessionView(session: session)
                    }
            }
            .transition(.opacity.combined(with: .scale))
        }
    }
}

// MARK: - Modern Components

struct ModernTrainingDayCard: View {
    let session: TrainingSession
    @State private var isPressed = false

    private var completedExercises: Int {
        session.exercises.filter { $0.isCompleted }.count
    }

    private var completionPercentage: Double {
        guard session.exercises.count > 0 else { return 0 }
        return Double(completedExercises) / Double(session.exercises.count)
    }

    private var statusBadge: SilkaStatusBadge {
        if session.isCompleted {
            return SilkaStatusBadge(text: "Done", status: .completed)
        } else if completedExercises > 0 {
            return SilkaStatusBadge(text: "In Progress", status: .inProgress)
        } else {
            return SilkaStatusBadge(text: "Pending", status: .pending)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: SilkaDesign.Spacing.md) {
                VStack(alignment: .leading, spacing: SilkaDesign.Spacing.xs) {
                    Text(session.day)
                        .font(SilkaDesign.Typography.headlineMedium)
                        .foregroundColor(SilkaDesign.Colors.textPrimary)

                    Text(session.focus)
                        .font(SilkaDesign.Typography.bodyMedium)
                        .foregroundColor(SilkaDesign.Colors.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: SilkaDesign.Spacing.xs) {
                    statusBadge

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(SilkaDesign.Colors.textTertiary)
                }
            }
            .padding(SilkaDesign.Spacing.md)

            // Progress section
            VStack(spacing: SilkaDesign.Spacing.sm) {
                HStack {
                    HStack(spacing: SilkaDesign.Spacing.xs) {
                        Image(systemName: session.location == "siłownia" ? "dumbbell" : "house")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(SilkaDesign.Colors.textSecondary)
                        Text(session.location.capitalized)
                            .font(SilkaDesign.Typography.labelMedium)
                            .foregroundColor(SilkaDesign.Colors.textSecondary)
                    }

                    Spacer()

                    Text("\(completedExercises)/\(session.exercises.count) exercises")
                        .font(SilkaDesign.Typography.labelMedium)
                        .foregroundColor(SilkaDesign.Colors.textSecondary)
                }

                SilkaProgressBar(
                    progress: Double(completedExercises),
                    total: Double(session.exercises.count),
                    color: session.isCompleted ? SilkaDesign.Colors.success : SilkaDesign.Colors.accent,
                    height: 6
                )
            }
            .padding(.horizontal, SilkaDesign.Spacing.md)
            .padding(.bottom, SilkaDesign.Spacing.md)
        }
        .background(SilkaDesign.Colors.surface)
        .cornerRadius(SilkaDesign.CornerRadius.md)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .silkaShadow()
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct ModernRestDayCard: View {
    let day: String

    var body: some View {
        HStack(spacing: SilkaDesign.Spacing.md) {
            VStack(alignment: .leading, spacing: SilkaDesign.Spacing.xs) {
                Text(day)
                    .font(SilkaDesign.Typography.headlineMedium)
                    .foregroundColor(SilkaDesign.Colors.textPrimary)

                Text("Rest Day")
                    .font(SilkaDesign.Typography.bodyMedium)
                    .foregroundColor(SilkaDesign.Colors.textSecondary)
            }

            Spacer()

            HStack(spacing: SilkaDesign.Spacing.sm) {
                Image(systemName: "bed.double.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(SilkaDesign.Colors.textTertiary)

                SilkaStatusBadge(text: "Rest", status: .info)
            }
        }
        .padding(SilkaDesign.Spacing.md)
        .background(SilkaDesign.Colors.surface.opacity(0.6))
        .cornerRadius(SilkaDesign.CornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: SilkaDesign.CornerRadius.md)
                .stroke(SilkaDesign.Colors.borderSubtle, lineWidth: 1)
        )
    }
}

struct ModernWeeklyProgressSummary: View {
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
        let weekDays = ["Poniedziałek", "Wtorek", "Środa", "Czwartek", "Piątek", "Sobota", "Niedziela"]
        let sortedSessions = trainingPlan.trainingSessions.sorted { session1, session2 in
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
        VStack(spacing: SilkaDesign.Spacing.lg) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: SilkaDesign.Spacing.xs) {
                    Text("Week Overview")
                        .font(SilkaDesign.Typography.displaySmall)
                        .foregroundColor(SilkaDesign.Colors.textPrimary)

                    Text("Your training progress this week")
                        .font(SilkaDesign.Typography.bodyMedium)
                        .foregroundColor(SilkaDesign.Colors.textSecondary)
                }

                Spacer()

                if currentStreak > 0 {
                    VStack(alignment: .trailing, spacing: SilkaDesign.Spacing.xs) {
                        HStack(spacing: SilkaDesign.Spacing.xs) {
                        Image(systemName: "flame.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(SilkaDesign.Colors.warning)
                        Text("\(currentStreak)")
                                .font(SilkaDesign.Typography.monoMedium)
                                .foregroundColor(SilkaDesign.Colors.textPrimary)
                        }
                        Text("day streak")
                            .font(SilkaDesign.Typography.labelSmall)
                            .foregroundColor(SilkaDesign.Colors.textSecondary)
                    }
                }
            }

            // Metrics Grid
            HStack(spacing: 0) {
                SilkaMetric(
                    title: "Sessions",
                    value: "\(completedSessions)/\(totalSessions)",
                    color: completionPercentage == 1.0 ? SilkaDesign.Colors.success : SilkaDesign.Colors.textPrimary,
                    alignment: .center
                )

                Rectangle()
                    .fill(SilkaDesign.Colors.borderSubtle)
                    .frame(width: 1, height: 40)

                SilkaMetric(
                    title: "Exercises",
                    value: "\(totalExercisesCompleted)/\(totalExercises)",
                    color: SilkaDesign.Colors.accent,
                    alignment: .center
                )

                Rectangle()
                    .fill(SilkaDesign.Colors.borderSubtle)
                    .frame(width: 1, height: 40)

                SilkaMetric(
                    title: "Complete",
                    value: "\(Int(completionPercentage * 100))%",
                    color: completionPercentage >= 0.8 ? SilkaDesign.Colors.success :
                           (completionPercentage >= 0.5 ? SilkaDesign.Colors.warning : SilkaDesign.Colors.error),
                    alignment: .center
                )
            }

            // Progress Bar
            VStack(spacing: SilkaDesign.Spacing.sm) {
                HStack {
                    Text("Weekly Progress")
                        .font(SilkaDesign.Typography.labelMedium)
                        .foregroundColor(SilkaDesign.Colors.textSecondary)

                    Spacer()

                    Text("\(Int(completionPercentage * 100))% complete")
                        .font(SilkaDesign.Typography.labelMedium)
                        .foregroundColor(SilkaDesign.Colors.textSecondary)
                }

                SilkaProgressBar(
                    progress: Double(completedSessions),
                    total: Double(totalSessions),
                    color: completionPercentage >= 0.8 ? SilkaDesign.Colors.success : SilkaDesign.Colors.accent,
                    height: 8
                )
            }
        }
        .padding(SilkaDesign.Spacing.lg)
        .background(
            LinearGradient(
                colors: [
                    SilkaDesign.Colors.surface,
                    SilkaDesign.Colors.surface.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(SilkaDesign.CornerRadius.lg)
        .silkaShadow(SilkaDesign.Shadows.medium)
    }
}

struct ModernEmptyState: View {
    var body: some View {
        VStack(spacing: SilkaDesign.Spacing.lg) {
            Image(systemName: "dumbbell")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(SilkaDesign.Colors.textTertiary)

            VStack(spacing: SilkaDesign.Spacing.sm) {
                Text("No Training Plan")
                    .font(SilkaDesign.Typography.displaySmall)
                    .foregroundColor(SilkaDesign.Colors.textPrimary)

                Text("Your training plan is loading or not available")
                    .font(SilkaDesign.Typography.bodyMedium)
                    .foregroundColor(SilkaDesign.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(SilkaDesign.Spacing.xl)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TrainingPlan.self, inMemory: true)
}
