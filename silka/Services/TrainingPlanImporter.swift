//
//  TrainingPlanImporter.swift
//  silka
//
//  Created by Rafał Piekara on 08/09/2025.
//

import Foundation
import SwiftData

struct JSONTrainingPlan: Codable {
    let version: String
    let profile: JSONProfile
    let warmupAndKneeRehab: [JSONWarmupExercise]
    let variants: JSONVariants
    let progressionRules: JSONProgressionRules
    
    private enum CodingKeys: String, CodingKey {
        case version
        case profile
        case warmupAndKneeRehab = "warmup_and_knee_rehab"
        case variants
        case progressionRules = "progression_rules"
    }
}

struct JSONProfile: Codable {
    let age: Int
    let sex: String
    let heightCm: Int
    let weightKg: Int
    let conditions: [String]
    let meds: [String]
    let goal: String
    let split: String
    let intensity: String
    let cardio: String
    let homeEquipment: [String]
    let gymEquipment: String
    let sessionTimeMin: Int
    
    private enum CodingKeys: String, CodingKey {
        case age, sex, conditions, meds, goal, split, intensity, cardio
        case heightCm = "height_cm"
        case weightKg = "weight_kg"
        case homeEquipment = "home_equipment"
        case gymEquipment = "gym_equipment"
        case sessionTimeMin = "session_time_min"
    }
}

struct JSONWarmupExercise: Codable {
    let namePl: String
    let nameEn: String
    let sets: String
    let tempo: String
    let videoUrl: String?
    
    private enum CodingKeys: String, CodingKey {
        case namePl = "name_pl"
        case nameEn = "name_en"
        case sets, tempo
        case videoUrl = "video_url"
    }
}

struct JSONVariants: Codable {
    let a2xGym1xHome: JSONVariant
    let b3xGym: JSONVariant
    
    private enum CodingKeys: String, CodingKey {
        case a2xGym1xHome = "A_2x_gym_1x_home"
        case b3xGym = "B_3x_gym"
    }
}

struct JSONVariant: Codable {
    let schedule: [JSONScheduleDay]
}

struct JSONScheduleDay: Codable {
    let day: String?
    let location: String?
    let focus: String?
    let exercises: [JSONExercise]?
    let cardio: String?
    let copyOfVariantADay: String?
    
    private enum CodingKeys: String, CodingKey {
        case day, location, focus, exercises, cardio
        case copyOfVariantADay = "copy_of_variantA_day"
    }
}

struct JSONExercise: Codable {
    let namePl: String
    let nameEn: String
    let setsReps: String
    let startWeightKg: Double?
    let startWeightKgPerHand: Double?
    let rir: String?
    let tempo: String?
    let notes: String?
    let videoUrl: String?
    
    private enum CodingKeys: String, CodingKey {
        case namePl = "name_pl"
        case nameEn = "name_en"
        case setsReps = "sets_reps"
        case startWeightKg = "start_weight_kg"
        case startWeightKgPerHand = "start_weight_kg_per_hand"
        case rir, tempo, notes
        case videoUrl = "video_url"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        namePl = try container.decode(String.self, forKey: .namePl)
        nameEn = try container.decode(String.self, forKey: .nameEn)
        setsReps = try container.decode(String.self, forKey: .setsReps)
        rir = try container.decodeIfPresent(String.self, forKey: .rir)
        tempo = try container.decodeIfPresent(String.self, forKey: .tempo)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        videoUrl = try container.decodeIfPresent(String.self, forKey: .videoUrl)
        
        // Handle both Double and String for weight fields
        if let weightValue = try? container.decode(Double.self, forKey: .startWeightKg) {
            startWeightKg = weightValue
        } else if let weightString = try? container.decode(String.self, forKey: .startWeightKg) {
            // Extract first number from string like "50-55" or "50–55"
            let numbers = weightString.components(separatedBy: CharacterSet(charactersIn: "–-"))
            startWeightKg = numbers.first.flatMap { Double($0.trimmingCharacters(in: .whitespaces)) }
        } else {
            startWeightKg = nil
        }
        
        if let weightValue = try? container.decode(Double.self, forKey: .startWeightKgPerHand) {
            startWeightKgPerHand = weightValue
        } else if let weightString = try? container.decode(String.self, forKey: .startWeightKgPerHand) {
            let numbers = weightString.components(separatedBy: CharacterSet(charactersIn: "–-"))
            startWeightKgPerHand = numbers.first.flatMap { Double($0.trimmingCharacters(in: .whitespaces)) }
        } else {
            startWeightKgPerHand = nil
        }
    }
}

struct JSONProgressionRules: Codable {
    let t1: String
    let t2: String
    let t3: String
    let t4Deload: String
    
    private enum CodingKeys: String, CodingKey {
        case t1 = "T1"
        case t2 = "T2"
        case t3 = "T3"
        case t4Deload = "T4_deload"
    }
}

class TrainingPlanImporter {
    static func importFromJSON(context: ModelContext) throws {
        guard let url = Bundle.main.url(forResource: "Training Plan for Muscle Gain", withExtension: "json") else {
            throw ImportError.fileNotFound
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let jsonPlan = try decoder.decode(JSONTrainingPlan.self, from: data)
        
        let trainingPlan = TrainingPlan(version: jsonPlan.version)
        
        let profile = Profile(
            age: jsonPlan.profile.age,
            sex: jsonPlan.profile.sex,
            heightCm: jsonPlan.profile.heightCm,
            weightKg: jsonPlan.profile.weightKg,
            goal: jsonPlan.profile.goal
        )
        profile.conditions = jsonPlan.profile.conditions
        profile.meds = jsonPlan.profile.meds
        profile.split = jsonPlan.profile.split
        profile.intensity = jsonPlan.profile.intensity
        profile.cardio = jsonPlan.profile.cardio
        profile.homeEquipment = jsonPlan.profile.homeEquipment
        profile.gymEquipment = jsonPlan.profile.gymEquipment
        profile.sessionTimeMin = jsonPlan.profile.sessionTimeMin
        trainingPlan.profile = profile
        
        for jsonWarmup in jsonPlan.warmupAndKneeRehab {
            let warmup = WarmupExercise(
                namePl: jsonWarmup.namePl,
                nameEn: jsonWarmup.nameEn,
                sets: jsonWarmup.sets,
                tempo: jsonWarmup.tempo,
                videoUrl: jsonWarmup.videoUrl
            )
            trainingPlan.warmupExercises.append(warmup)
        }
        
        var variantADays: [String: JSONScheduleDay] = [:]
        
        for scheduleDay in jsonPlan.variants.a2xGym1xHome.schedule {
            if let day = scheduleDay.day {
                variantADays[day] = scheduleDay
                let session = createTrainingSession(from: scheduleDay)
                trainingPlan.trainingSessions.append(session)
            }
        }
        
        for scheduleDay in jsonPlan.variants.b3xGym.schedule {
            if let copyDay = scheduleDay.copyOfVariantADay,
               let originalDay = variantADays[copyDay] {
                let session = createTrainingSession(from: originalDay)
                trainingPlan.trainingSessions.append(session)
            } else if scheduleDay.day != nil {
                let session = createTrainingSession(from: scheduleDay)
                trainingPlan.trainingSessions.append(session)
            }
        }
        
        let progressionRules = ProgressionRules(
            t1: jsonPlan.progressionRules.t1,
            t2: jsonPlan.progressionRules.t2,
            t3: jsonPlan.progressionRules.t3,
            t4Deload: jsonPlan.progressionRules.t4Deload
        )
        trainingPlan.progressionRules = progressionRules
        
        context.insert(trainingPlan)
        try context.save()
    }
    
    private static func createTrainingSession(from scheduleDay: JSONScheduleDay) -> TrainingSession {
        let session = TrainingSession(
            day: scheduleDay.day ?? "",
            location: scheduleDay.location ?? "",
            focus: scheduleDay.focus ?? ""
        )
        session.cardio = scheduleDay.cardio
        
        if let exercises = scheduleDay.exercises {
            for jsonExercise in exercises {
                let exercise = Exercise(
                    namePl: jsonExercise.namePl,
                    nameEn: jsonExercise.nameEn,
                    setsReps: jsonExercise.setsReps
                )
                exercise.startWeightKg = jsonExercise.startWeightKg
                exercise.startWeightKgPerHand = jsonExercise.startWeightKgPerHand
                exercise.rir = jsonExercise.rir
                exercise.tempo = jsonExercise.tempo
                exercise.notes = jsonExercise.notes
                exercise.videoUrl = jsonExercise.videoUrl
                session.exercises.append(exercise)
            }
        }
        
        return session
    }
    
    enum ImportError: Error {
        case fileNotFound
        case decodingError
    }
}