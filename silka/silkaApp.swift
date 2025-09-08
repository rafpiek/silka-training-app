//
//  silkaApp.swift
//  silka
//
//  Created by Rafał Piekara on 08/09/2025.
//

import SwiftUI
import SwiftData

@main
struct silkaApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TrainingPlan.self,
            Profile.self,
            WarmupExercise.self,
            TrainingSession.self,
            Exercise.self,
            ProgressionRules.self
        ])
        
        // Try with automatic migration first
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            let context = container.mainContext
            let descriptor = FetchDescriptor<TrainingPlan>()
            let existingPlans = try context.fetch(descriptor)
            
            if existingPlans.isEmpty {
                try TrainingPlanImporter.importFromJSON(context: context)
            }
            
            return container
        } catch {
            // If migration fails, delete the store and create a new one
            print("Failed to load container, recreating: \(error)")
            
            let storeURL = URL.applicationSupportDirectory.appending(path: "default.store")
            try? FileManager.default.removeItem(at: storeURL)
            
            // Try again with a fresh store
            do {
                let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
                let context = container.mainContext
                try TrainingPlanImporter.importFromJSON(context: context)
                return container
            } catch {
                fatalError("Could not create ModelContainer even after reset: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
