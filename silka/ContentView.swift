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
            NavigationStack {
                ScrollView {
                    VStack(spacing: 16) {
                        if let plan = currentTrainingPlan {
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
            .transition(.opacity.combined(with: .scale))
        }
    }
}

struct TrainingDayCard: View {
    let session: TrainingSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(session.day)
                        .font(.headline)
                    Text(session.focus)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if session.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label(session.location, systemImage: session.location == "siłownia" ? "dumbbell" : "house")
                    .font(.caption)
                Spacer()
                Text("\(session.exercises.count) exercises")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
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

#Preview {
    ContentView()
        .modelContainer(for: TrainingPlan.self, inMemory: true)
}
