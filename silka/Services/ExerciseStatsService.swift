//
//  ExerciseStatsService.swift
//  silka
//
//  Created by Rafał Piekara on 08/09/2025.
//

import Foundation
import SwiftData

struct ExerciseDataPoint {
    let date: Date
    let weight: Double
    let reps: Int
    let volume: Double // weight × reps
    let sessionDay: String
}

struct ExerciseStats {
    let exerciseName: String
    let exerciseNamePl: String
    let totalSessions: Int
    let dataPoints: [ExerciseDataPoint]
    let personalRecord: Double?
    let averageWeight: Double
    let totalVolume: Double
    let lastPerformed: Date?
    let weightProgression: [(date: Date, weight: Double)]
    let volumeProgression: [(date: Date, volume: Double)]
}

struct ExerciseSummary {
    let exerciseName: String
    let exerciseNamePl: String
    let totalSessions: Int
    let personalRecord: Double?
    let lastWeight: Double?
    let lastPerformed: Date?
    let trend: ExerciseTrend
}

enum ExerciseTrend {
    case increasing
    case decreasing
    case stable
    case insufficient // not enough data
}

class ExerciseStatsService {
    
    static func getAllExerciseStats(from trainingPlan: TrainingPlan) -> [ExerciseStats] {
        var exerciseDataMap: [String: [ExerciseDataPoint]] = [:]
        
        // Collect data from all completed sessions
        for session in trainingPlan.trainingSessions.filter({ $0.isCompleted }) {
            guard let sessionDate = session.completedDate else { continue }
            
            for exercise in session.exercises.filter({ $0.isCompleted }) {
                let key = exercise.nameEn
                
                if exerciseDataMap[key] == nil {
                    exerciseDataMap[key] = []
                }
                
                // Extract data points from completed sets
                let completedSets = exercise.setsData.filter { $0.value.isCompleted }
                
                for (_, setData) in completedSets {
                    if let weight = setData.weight, let reps = setData.reps {
                        let dataPoint = ExerciseDataPoint(
                            date: sessionDate,
                            weight: weight,
                            reps: reps,
                            volume: weight * Double(reps),
                            sessionDay: session.day
                        )
                        exerciseDataMap[key]?.append(dataPoint)
                    }
                }
            }
        }
        
        // Convert to ExerciseStats
        var stats: [ExerciseStats] = []
        
        for (exerciseName, dataPoints) in exerciseDataMap {
            // Get the Polish name from any exercise with this English name
            let polishName = trainingPlan.trainingSessions
                .flatMap { $0.exercises }
                .first { $0.nameEn == exerciseName }?.namePl ?? exerciseName
            
            let sortedDataPoints = dataPoints.sorted { $0.date < $1.date }
            let personalRecord = dataPoints.map { $0.weight }.max()
            let averageWeight = dataPoints.map { $0.weight }.reduce(0, +) / Double(dataPoints.count)
            let totalVolume = dataPoints.map { $0.volume }.reduce(0, +)
            let lastPerformed = sortedDataPoints.last?.date
            
            // Calculate progressions
            let weightProgression = calculateWeightProgression(from: sortedDataPoints)
            let volumeProgression = calculateVolumeProgression(from: sortedDataPoints)
            
            // Count unique sessions
            let uniqueSessions = Set(sortedDataPoints.map { $0.sessionDay }).count
            
            let exerciseStats = ExerciseStats(
                exerciseName: exerciseName,
                exerciseNamePl: polishName,
                totalSessions: uniqueSessions,
                dataPoints: sortedDataPoints,
                personalRecord: personalRecord,
                averageWeight: averageWeight,
                totalVolume: totalVolume,
                lastPerformed: lastPerformed,
                weightProgression: weightProgression,
                volumeProgression: volumeProgression
            )
            
            stats.append(exerciseStats)
        }
        
        return stats.sorted { $0.totalSessions > $1.totalSessions }
    }
    
    static func getExerciseSummaries(from trainingPlan: TrainingPlan) -> [ExerciseSummary] {
        let allStats = getAllExerciseStats(from: trainingPlan)
        
        return allStats.map { stats in
            let trend = calculateTrend(from: stats.weightProgression)
            let lastWeight = stats.dataPoints.last?.weight
            
            return ExerciseSummary(
                exerciseName: stats.exerciseName,
                exerciseNamePl: stats.exerciseNamePl,
                totalSessions: stats.totalSessions,
                personalRecord: stats.personalRecord,
                lastWeight: lastWeight,
                lastPerformed: stats.lastPerformed,
                trend: trend
            )
        }
    }
    
    static func getStatsForExercise(_ exerciseName: String, from trainingPlan: TrainingPlan) -> ExerciseStats? {
        return getAllExerciseStats(from: trainingPlan).first { $0.exerciseName == exerciseName }
    }
    
    // MARK: - Private Helper Methods
    
    private static func calculateWeightProgression(from dataPoints: [ExerciseDataPoint]) -> [(date: Date, weight: Double)] {
        // Group by date and take the maximum weight for each session
        let groupedByDate = Dictionary(grouping: dataPoints) { Calendar.current.startOfDay(for: $0.date) }
        
        return groupedByDate.compactMap { date, points in
            guard let maxWeight = points.map({ $0.weight }).max() else { return nil }
            return (date: date, weight: maxWeight)
        }.sorted { $0.date < $1.date }
    }
    
    private static func calculateVolumeProgression(from dataPoints: [ExerciseDataPoint]) -> [(date: Date, volume: Double)] {
        // Group by date and sum volume for each session
        let groupedByDate = Dictionary(grouping: dataPoints) { Calendar.current.startOfDay(for: $0.date) }
        
        return groupedByDate.compactMap { date, points in
            let totalVolume = points.map({ $0.volume }).reduce(0, +)
            return (date: date, volume: totalVolume)
        }.sorted { $0.date < $1.date }
    }
    
    private static func calculateTrend(from weightProgression: [(date: Date, weight: Double)]) -> ExerciseTrend {
        guard weightProgression.count >= 3 else { return .insufficient }
        
        let recent = Array(weightProgression.suffix(3))
        let weights = recent.map { $0.weight }
        
        let firstWeight = weights.first!
        let lastWeight = weights.last!
        
        let changePercentage = (lastWeight - firstWeight) / firstWeight * 100
        
        if changePercentage > 5 {
            return .increasing
        } else if changePercentage < -5 {
            return .decreasing
        } else {
            return .stable
        }
    }
}