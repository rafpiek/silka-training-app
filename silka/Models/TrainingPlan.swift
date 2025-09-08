//
//  TrainingPlan.swift
//  silka
//
//  Created by Rafał Piekara on 08/09/2025.
//

import Foundation
import SwiftData

@Model
final class TrainingPlan {
    var version: String
    @Relationship(deleteRule: .cascade) var profile: Profile?
    @Relationship(deleteRule: .cascade) var warmupExercises: [WarmupExercise]
    @Relationship(deleteRule: .cascade) var trainingSessions: [TrainingSession]
    @Relationship(deleteRule: .cascade) var progressionRules: ProgressionRules?
    var createdAt: Date
    
    init(version: String = "1.0") {
        self.version = version
        self.warmupExercises = []
        self.trainingSessions = []
        self.createdAt = Date()
    }
}

@Model
final class Profile {
    var age: Int
    var sex: String
    var heightCm: Int
    var weightKg: Int
    private var conditionsString: String = ""
    private var medsString: String = ""
    var goal: String
    var split: String
    var intensity: String
    var cardio: String
    private var homeEquipmentString: String = ""
    var gymEquipment: String
    var sessionTimeMin: Int
    
    var conditions: [String] {
        get {
            conditionsString.isEmpty ? [] : conditionsString.components(separatedBy: "|||")
        }
        set {
            conditionsString = newValue.joined(separator: "|||")
        }
    }
    
    var meds: [String] {
        get {
            medsString.isEmpty ? [] : medsString.components(separatedBy: "|||")
        }
        set {
            medsString = newValue.joined(separator: "|||")
        }
    }
    
    var homeEquipment: [String] {
        get {
            homeEquipmentString.isEmpty ? [] : homeEquipmentString.components(separatedBy: "|||")
        }
        set {
            homeEquipmentString = newValue.joined(separator: "|||")
        }
    }
    
    init(age: Int, sex: String, heightCm: Int, weightKg: Int, goal: String) {
        self.age = age
        self.sex = sex
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.conditionsString = ""
        self.medsString = ""
        self.goal = goal
        self.split = ""
        self.intensity = ""
        self.cardio = ""
        self.homeEquipmentString = ""
        self.gymEquipment = ""
        self.sessionTimeMin = 60
    }
}

@Model
final class WarmupExercise {
    var namePl: String
    var nameEn: String
    var sets: String
    var tempo: String
    var videoUrl: String?
    var isCompleted: Bool
    var completedAt: Date?
    
    init(namePl: String, nameEn: String, sets: String, tempo: String, videoUrl: String? = nil) {
        self.namePl = namePl
        self.nameEn = nameEn
        self.sets = sets
        self.tempo = tempo
        self.videoUrl = videoUrl
        self.isCompleted = false
    }
}

@Model
final class TrainingSession {
    var day: String
    var location: String
    var focus: String
    @Relationship(deleteRule: .cascade) var exercises: [Exercise]
    var cardio: String?
    var isCompleted: Bool
    var completedDate: Date?
    var scheduledDate: Date?
    
    init(day: String, location: String, focus: String) {
        self.day = day
        self.location = location
        self.focus = focus
        self.exercises = []
        self.isCompleted = false
    }
}

struct SetData: Codable {
    var isCompleted: Bool = false
    var weight: Double?
    var reps: Int?
}

@Model
final class Exercise {
    var namePl: String
    var nameEn: String
    var setsReps: String
    var startWeightKg: Double?
    var startWeightKgPerHand: Double?
    var rir: String?
    var tempo: String?
    var notes: String?
    var videoUrl: String?
    var isCompleted: Bool
    var completedAt: Date?
    private var setsDataString: String = ""
    
    var setsData: [Int: SetData] {
        get {
            guard !setsDataString.isEmpty,
                  let data = setsDataString.data(using: .utf8),
                  let decoded = try? JSONDecoder().decode([String: SetData].self, from: data) else {
                return [:]
            }
            return decoded.compactMapKeys { Int($0) }
        }
        set {
            let stringKeyed = newValue.mapKeys { String($0) }
            if let encoded = try? JSONEncoder().encode(stringKeyed),
               let string = String(data: encoded, encoding: .utf8) {
                setsDataString = string
            }
            // Auto-complete exercise if all sets are done
            let completedCount = newValue.values.filter { $0.isCompleted }.count
            if completedCount == totalSets && totalSets > 0 {
                isCompleted = true
                completedAt = Date()
            } else {
                isCompleted = false
                completedAt = nil
            }
        }
    }
    
    var completedSets: Set<Int> {
        Set(setsData.compactMap { $0.value.isCompleted ? $0.key : nil })
    }
    
    var totalSets: Int {
        // Parse strings like "4×6-8", "3×10", "2-3×12-15"
        let pattern = #"(\d+)(?:-\d+)?[×x]"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: setsReps, range: NSRange(setsReps.startIndex..., in: setsReps)),
           let range = Range(match.range(at: 1), in: setsReps) {
            return Int(setsReps[range]) ?? 1
        }
        return 1
    }
    
    func toggleSet(_ setNumber: Int, weight: Double? = nil) {
        var data = setsData
        if var setInfo = data[setNumber] {
            setInfo.isCompleted.toggle()
            if let weight = weight {
                setInfo.weight = weight
            }
            data[setNumber] = setInfo
        } else {
            data[setNumber] = SetData(isCompleted: true, weight: weight ?? startWeightKg ?? startWeightKgPerHand)
        }
        setsData = data
    }
    
    func updateSetWeight(_ setNumber: Int, weight: Double?) {
        var data = setsData
        if var setInfo = data[setNumber] {
            setInfo.weight = weight
            data[setNumber] = setInfo
        } else {
            data[setNumber] = SetData(isCompleted: false, weight: weight)
        }
        setsData = data
    }
    
    func resetSets() {
        setsData = [:]
    }
    
    init(namePl: String, nameEn: String, setsReps: String) {
        self.namePl = namePl
        self.nameEn = nameEn
        self.setsReps = setsReps
        self.isCompleted = false
        self.setsDataString = ""
    }
}

extension Dictionary {
    func mapKeys<T: Hashable>(_ transform: (Key) -> T) -> [T: Value] {
        Dictionary<T, Value>(uniqueKeysWithValues: map { (transform($0.key), $0.value) })
    }
    
    func compactMapKeys<T: Hashable>(_ transform: (Key) -> T?) -> [T: Value] {
        compactMap { key, value in
            transform(key).map { ($0, value) }
        }.reduce(into: [:]) { $0[$1.0] = $1.1 }
    }
}

@Model
final class ProgressionRules {
    var t1: String
    var t2: String
    var t3: String
    var t4Deload: String
    
    init(t1: String, t2: String, t3: String, t4Deload: String) {
        self.t1 = t1
        self.t2 = t2
        self.t3 = t3
        self.t4Deload = t4Deload
    }
}