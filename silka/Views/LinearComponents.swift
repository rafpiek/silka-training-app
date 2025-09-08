//
//  LinearComponents.swift
//  silka
//
//  RADICAL Linear-inspired components
//  Created by Rafał Piekara on 08/09/2025.
//

import SwiftUI

// MARK: - Main View Components

struct LinearHeader: View {
    let plan: TrainingPlan

    private var completedSessions: Int {
        plan.trainingSessions.filter { $0.isCompleted }.count
    }

    private var totalSessions: Int {
        plan.trainingSessions.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SilkaDesign.Spacing.lg) {
            // App title - Linear style
            HStack {
                VStack(alignment: .leading, spacing: SilkaDesign.Spacing.xs) {
                    Text("SILKA")
                        .font(SilkaDesign.Typography.displayMedium)
                        .fontWeight(.light)
                        .foregroundColor(SilkaDesign.Colors.textPrimary)
                        .tracking(1)

                    Text("Training Plan")
                        .font(SilkaDesign.Typography.bodyMedium)
                        .foregroundColor(SilkaDesign.Colors.textSecondary)
                }

                Spacer()
            }

            // Ultra-minimal progress indicator
            VStack(alignment: .leading, spacing: SilkaDesign.Spacing.sm) {
                HStack {
                    Text("\(completedSessions) of \(totalSessions) sessions completed")
                        .font(SilkaDesign.Typography.bodyMedium)
                        .foregroundColor(SilkaDesign.Colors.textSecondary)

                    Spacer()

                    Text("\(Int(Double(completedSessions) / Double(max(totalSessions, 1)) * 100))%")
                        .font(SilkaDesign.Typography.monoMedium)
                        .foregroundColor(SilkaDesign.Colors.accent)
                }

                // Minimal progress line
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(SilkaDesign.Colors.borderSubtle)
                            .frame(height: 1)

                        Rectangle()
                            .fill(SilkaDesign.Colors.accent)
                            .frame(
                                width: geometry.size.width * (Double(completedSessions) / Double(max(totalSessions, 1))),
                                height: 1
                            )
                            .animation(.easeInOut(duration: 0.4), value: completedSessions)
                    }
                }
                .frame(height: 1)
            }
        }
    }
}

struct LinearSessionList: View {
    let plan: TrainingPlan
    let weekDays: [String]
    @Binding var selectedSession: TrainingSession?

    var body: some View {
        LazyVStack(spacing: SilkaDesign.Spacing.sm) {
            ForEach(weekDays, id: \.self) { day in
                if let session = plan.trainingSessions.first(where: { $0.day == day }) {
                    LinearTrainingRow(
                        session: session,
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedSession = session
                            }
                        }
                    )
                } else {
                    LinearRestRow(day: day)
                }
            }
        }
    }
}

struct LinearTrainingRow: View {
    let session: TrainingSession
    let onTap: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: SilkaDesign.Spacing.lg) {
                // Status dot
                Circle()
                    .fill(session.isCompleted ? SilkaDesign.Colors.success : SilkaDesign.Colors.textTertiary)
                    .frame(width: 8, height: 8)

                // Day info
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

                // Exercise count and location
                VStack(alignment: .trailing, spacing: SilkaDesign.Spacing.xs) {
                    HStack(spacing: SilkaDesign.Spacing.xs) {
                        Text("\(session.exercises.count)")
                            .font(SilkaDesign.Typography.monoSmall)
                            .foregroundColor(SilkaDesign.Colors.textSecondary)
                        Text("exercises")
                            .font(SilkaDesign.Typography.labelSmall)
                            .foregroundColor(SilkaDesign.Colors.textTertiary)
                    }

                    HStack(spacing: SilkaDesign.Spacing.xs) {
                        Image(systemName: session.location == "siłownia" ? "dumbbell" : "house")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(SilkaDesign.Colors.textTertiary)
                        Text(session.location.capitalized)
                            .font(SilkaDesign.Typography.labelSmall)
                            .foregroundColor(SilkaDesign.Colors.textTertiary)
                    }
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(SilkaDesign.Colors.textTertiary)
            }
            .padding(.vertical, SilkaDesign.Spacing.md)
            .padding(.horizontal, SilkaDesign.Spacing.lg)
            .background(isPressed ? SilkaDesign.Colors.accentLight : Color.clear)
            .cornerRadius(SilkaDesign.CornerRadius.sm)
            .overlay(
                Rectangle()
                    .fill(SilkaDesign.Colors.borderSubtle)
                    .frame(height: 1),
                alignment: .bottom
            )
            .scaleEffect(isPressed ? 0.99 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct LinearRestRow: View {
    let day: String

    var body: some View {
        HStack(spacing: SilkaDesign.Spacing.lg) {
            // Status dot
            Circle()
                .fill(SilkaDesign.Colors.info.opacity(0.5))
                .frame(width: 8, height: 8)

            // Day info
            VStack(alignment: .leading, spacing: SilkaDesign.Spacing.xs) {
                Text(day)
                    .font(SilkaDesign.Typography.headlineMedium)
                    .foregroundColor(SilkaDesign.Colors.textSecondary)

                Text("Rest Day")
                    .font(SilkaDesign.Typography.bodyMedium)
                    .foregroundColor(SilkaDesign.Colors.textTertiary)
            }

            Spacer()

            Image(systemName: "bed.double")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(SilkaDesign.Colors.textTertiary)
        }
        .padding(.vertical, SilkaDesign.Spacing.md)
        .padding(.horizontal, SilkaDesign.Spacing.lg)
        .overlay(
            Rectangle()
                .fill(SilkaDesign.Colors.borderSubtle)
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

struct LinearEmptyState: View {
    var body: some View {
        VStack(spacing: SilkaDesign.Spacing.xl) {
            Spacer()

            VStack(spacing: SilkaDesign.Spacing.lg) {
                Image(systemName: "dumbbell")
                    .font(.system(size: 48, weight: .ultraLight))
                    .foregroundColor(SilkaDesign.Colors.textTertiary)

                VStack(spacing: SilkaDesign.Spacing.md) {
                    Text("No Training Plan")
                        .font(SilkaDesign.Typography.displayMedium)
                        .fontWeight(.light)
                        .foregroundColor(SilkaDesign.Colors.textPrimary)

                    Text("Your training plan is loading or not available.")
                        .font(SilkaDesign.Typography.bodyMedium)
                        .foregroundColor(SilkaDesign.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(SilkaDesign.Spacing.lg)
    }
}

// MARK: - RADICAL LINEAR-INSPIRED COMPONENTS

struct LinearSidebar: View {
    @Binding var selectedSession: TrainingSession?
    let currentPlan: TrainingPlan?

    var body: some View {
        VStack(spacing: 0) {
            // SIDEBAR HEADER - Linear style
            VStack(alignment: .leading, spacing: SilkaDesign.Spacing.lg) {
                HStack {
                    VStack(alignment: .leading, spacing: SilkaDesign.Spacing.xs) {
                        Text("SILKA")
                            .font(SilkaDesign.Typography.displaySmall)
                            .fontWeight(.light)
                            .foregroundColor(SilkaDesign.Colors.textPrimary)

                        Text("Training Plan")
                            .font(SilkaDesign.Typography.labelMedium)
                            .foregroundColor(SilkaDesign.Colors.textSecondary)
                    }
                    Spacer()
                }

                // Quick stats - Linear style
                if let plan = currentPlan {
                    LinearQuickStats(plan: plan)
                }
            }
            .padding(SilkaDesign.Spacing.lg)
            .background(SilkaDesign.Colors.surface)

            // SESSIONS LIST - Command palette style
            ScrollView {
                LazyVStack(spacing: 2) {
                    if let plan = currentPlan {
                        ForEach(plan.trainingSessions.sorted(by: { session1, session2 in
                            let weekDays = ["Poniedziałek", "Wtorek", "Środa", "Czwartek", "Piątek", "Sobota", "Niedziela"]
                            let index1 = weekDays.firstIndex(of: session1.day) ?? 0
                            let index2 = weekDays.firstIndex(of: session2.day) ?? 0
                            return index1 < index2
                        }), id: \.id) { session in
                            LinearSessionRow(
                                session: session,
                                isSelected: selectedSession?.id == session.id,
                                onTap: {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        selectedSession = session
                                    }
                                }
                            )
                        }
                    }
                }
                .padding(.vertical, SilkaDesign.Spacing.sm)
            }

            Spacer()
        }
        .background(SilkaDesign.Colors.surface)
        .overlay(
            Rectangle()
                .fill(SilkaDesign.Colors.border)
                .frame(width: 1),
            alignment: .trailing
        )
    }
}

struct LinearMainContent: View {
    @Binding var selectedSession: TrainingSession?
    let currentPlan: TrainingPlan?
    let weekDays: [String]

    var body: some View {
        VStack(spacing: 0) {
            // MAIN HEADER
            LinearMainHeader()

            // MAIN CONTENT
            if let session = selectedSession {
                LinearSessionDetail(session: session)
            } else {
                LinearWelcomeView(currentPlan: currentPlan)
            }
        }
        .background(SilkaDesign.Colors.background)
    }
}

struct LinearQuickStats: View {
    let plan: TrainingPlan

    private var completedSessions: Int {
        plan.trainingSessions.filter { $0.isCompleted }.count
    }

    private var totalSessions: Int {
        plan.trainingSessions.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SilkaDesign.Spacing.sm) {
            HStack(spacing: SilkaDesign.Spacing.lg) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(completedSessions)")
                        .font(SilkaDesign.Typography.monoMedium)
                        .foregroundColor(SilkaDesign.Colors.success)
                    Text("Complete")
                        .font(SilkaDesign.Typography.labelSmall)
                        .foregroundColor(SilkaDesign.Colors.textTertiary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(totalSessions - completedSessions)")
                        .font(SilkaDesign.Typography.monoMedium)
                        .foregroundColor(SilkaDesign.Colors.textSecondary)
                    Text("Remaining")
                        .font(SilkaDesign.Typography.labelSmall)
                        .foregroundColor(SilkaDesign.Colors.textTertiary)
                }
            }

            // Ultra-minimal progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(SilkaDesign.Colors.borderSubtle)
                        .frame(height: 2)

                    Rectangle()
                        .fill(SilkaDesign.Colors.accent)
                        .frame(
                            width: geometry.size.width * (Double(completedSessions) / Double(max(totalSessions, 1))),
                            height: 2
                        )
                        .animation(.easeInOut(duration: 0.3), value: completedSessions)
                }
            }
            .frame(height: 2)
        }
    }
}

struct LinearSessionRow: View {
    let session: TrainingSession
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: SilkaDesign.Spacing.sm) {
                // Status indicator
                Circle()
                    .fill(session.isCompleted ? SilkaDesign.Colors.success : SilkaDesign.Colors.textTertiary)
                    .frame(width: 6, height: 6)

                VStack(alignment: .leading, spacing: 2) {
                    Text(session.day)
                        .font(SilkaDesign.Typography.bodyMedium)
                        .foregroundColor(isSelected ? SilkaDesign.Colors.accent : SilkaDesign.Colors.textPrimary)

                    Text(session.focus)
                        .font(SilkaDesign.Typography.labelSmall)
                        .foregroundColor(SilkaDesign.Colors.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                // Exercise count
                Text("\(session.exercises.count)")
                    .font(SilkaDesign.Typography.monoSmall)
                    .foregroundColor(SilkaDesign.Colors.textTertiary)
            }
            .padding(.horizontal, SilkaDesign.Spacing.md)
            .padding(.vertical, SilkaDesign.Spacing.sm)
            .background(
                isSelected ? SilkaDesign.Colors.accentLight : Color.clear
            )
            .cornerRadius(SilkaDesign.CornerRadius.sm)
        }
        .buttonStyle(.plain)
    }
}

struct LinearMainHeader: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: SilkaDesign.Spacing.xs) {
                Text("Training Session")
                    .font(SilkaDesign.Typography.displayMedium)
                    .fontWeight(.light)
                    .foregroundColor(SilkaDesign.Colors.textPrimary)

                Text("Select a session from the sidebar to begin")
                    .font(SilkaDesign.Typography.bodyMedium)
                    .foregroundColor(SilkaDesign.Colors.textSecondary)
            }

            Spacer()
        }
        .padding(SilkaDesign.Spacing.xl)
        .background(SilkaDesign.Colors.surface)
        .overlay(
            Rectangle()
                .fill(SilkaDesign.Colors.border)
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

struct LinearWelcomeView: View {
    let currentPlan: TrainingPlan?

    var body: some View {
        VStack(spacing: SilkaDesign.Spacing.massive) {
            Spacer()

            VStack(spacing: SilkaDesign.Spacing.xl) {
                // Large icon
                Image(systemName: "dumbbell")
                    .font(.system(size: 64, weight: .ultraLight))
                    .foregroundColor(SilkaDesign.Colors.textTertiary)

                VStack(spacing: SilkaDesign.Spacing.md) {
                    Text("Ready to Train")
                        .font(SilkaDesign.Typography.displayLarge)
                        .fontWeight(.light)
                        .foregroundColor(SilkaDesign.Colors.textPrimary)

                    Text("Choose a training session from the sidebar to get started with your workout.")
                        .font(SilkaDesign.Typography.bodyLarge)
                        .foregroundColor(SilkaDesign.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(SilkaDesign.Spacing.xl)
    }
}

struct LinearSessionDetail: View {
    let session: TrainingSession

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: SilkaDesign.Spacing.xl) {
                    // Session info card
                    LinearSessionCard(session: session)

                    // Exercises list
                    LazyVStack(spacing: SilkaDesign.Spacing.md) {
                        ForEach(Array(session.exercises.sorted(by: { $0.sortOrder < $1.sortOrder }).enumerated()), id: \.element) { index, exercise in
                            LinearExerciseRow(exercise: exercise, number: index + 1)
                        }
                    }
                }
                .padding(SilkaDesign.Spacing.xl)
            }
            .navigationDestination(for: Exercise.self) { exercise in
                ExerciseDetailView(exercise: exercise, sessionTimer: SessionTimer())
            }
        }
    }
}

struct LinearSessionCard: View {
    let session: TrainingSession

    var body: some View {
        VStack(alignment: .leading, spacing: SilkaDesign.Spacing.lg) {
            HStack {
                VStack(alignment: .leading, spacing: SilkaDesign.Spacing.xs) {
                    Text(session.focus)
                        .font(SilkaDesign.Typography.displaySmall)
                        .fontWeight(.medium)
                        .foregroundColor(SilkaDesign.Colors.textPrimary)

                    Text(session.day)
                        .font(SilkaDesign.Typography.bodyMedium)
                        .foregroundColor(SilkaDesign.Colors.textSecondary)
                }

                Spacer()

                if session.isCompleted {
                    LinearStatusBadge(text: "Completed", type: .success)
                }
            }

            HStack(spacing: SilkaDesign.Spacing.lg) {
                LinearMetricSmall(
                    label: "Exercises",
                    value: "\(session.exercises.count)"
                )

                LinearMetricSmall(
                    label: "Location",
                    value: session.location.capitalized
                )

                LinearMetricSmall(
                    label: "Completed",
                    value: "\(session.exercises.filter { $0.isCompleted }.count)"
                )
            }
        }
        .padding(SilkaDesign.Spacing.xl)
        .background(SilkaDesign.Colors.surface)
        .cornerRadius(SilkaDesign.CornerRadius.lg)
        .silkaShadow(SilkaDesign.Shadows.subtle)
    }
}

struct LinearExerciseRow: View {
    let exercise: Exercise
    let number: Int
    @State private var isPressed = false

    var body: some View {
        NavigationLink(value: exercise) {
            HStack(spacing: SilkaDesign.Spacing.md) {
                // Number badge
                Text("\(number)")
                    .font(SilkaDesign.Typography.monoSmall)
                    .foregroundColor(SilkaDesign.Colors.textTertiary)
                    .frame(width: 24, alignment: .trailing)

                VStack(alignment: .leading, spacing: SilkaDesign.Spacing.xs) {
                    Text(exercise.nameEn)
                        .font(SilkaDesign.Typography.bodyMedium)
                        .foregroundColor(SilkaDesign.Colors.textPrimary)

                    Text(exercise.setsReps)
                        .font(SilkaDesign.Typography.labelMedium)
                        .foregroundColor(SilkaDesign.Colors.textSecondary)
                }

                Spacer()

                HStack(spacing: SilkaDesign.Spacing.sm) {
                    if exercise.isCompleted {
                        LinearStatusBadge(text: "Done", type: .success)
                    } else {
                        LinearStatusBadge(text: "Pending", type: .pending)
                    }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(SilkaDesign.Colors.textTertiary)
                }
            }
            .padding(.vertical, SilkaDesign.Spacing.md)
            .padding(.horizontal, SilkaDesign.Spacing.md)
            .background(isPressed ? SilkaDesign.Colors.accentLight : Color.clear)
            .cornerRadius(SilkaDesign.CornerRadius.sm)
            .overlay(
                Rectangle()
                    .fill(SilkaDesign.Colors.borderSubtle)
                    .frame(height: 1),
                alignment: .bottom
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct LinearStatusBadge: View {
    let text: String
    let type: BadgeType

    enum BadgeType {
        case success, pending, warning

        var color: Color {
            switch self {
            case .success: return SilkaDesign.Colors.success
            case .pending: return SilkaDesign.Colors.textTertiary
            case .warning: return SilkaDesign.Colors.warning
            }
        }
    }

    var body: some View {
        Text(text.uppercased())
            .font(SilkaDesign.Typography.labelSmall)
            .foregroundColor(type.color)
            .padding(.horizontal, SilkaDesign.Spacing.sm)
            .padding(.vertical, SilkaDesign.Spacing.xs)
            .background(type.color.opacity(0.1))
            .cornerRadius(SilkaDesign.CornerRadius.sm)
    }
}

struct LinearMetricSmall: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(SilkaDesign.Typography.bodyMedium)
                .foregroundColor(SilkaDesign.Colors.textPrimary)

            Text(label.uppercased())
                .font(SilkaDesign.Typography.labelSmall)
                .foregroundColor(SilkaDesign.Colors.textTertiary)
        }
    }
}
