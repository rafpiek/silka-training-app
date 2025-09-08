//
//  ExerciseStatsView.swift
//  silka
//
//  Created by Rafał Piekara on 08/09/2025.
//

import SwiftUI
import Charts

struct ExerciseStatsView: View {
    let exerciseStats: ExerciseStats
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    private var formattedLastPerformed: String {
        guard let date = exerciseStats.lastPerformed else { return "Never" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with exercise info
                    ExerciseStatsHeader(stats: exerciseStats)
                    
                    // Tab selector
                    Picker("Chart Type", selection: $selectedTab) {
                        Text("Weight").tag(0)
                        Text("Volume").tag(1)
                        Text("All Data").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
                    // Charts based on selected tab
                    switch selectedTab {
                    case 0:
                        WeightProgressionChart(exerciseStats: exerciseStats)
                    case 1:
                        VolumeProgressionChart(exerciseStats: exerciseStats)
                    case 2:
                        AllDataView(exerciseStats: exerciseStats)
                    default:
                        WeightProgressionChart(exerciseStats: exerciseStats)
                    }
                    
                    // Personal Records Section
                    PersonalRecordsSection(stats: exerciseStats)
                }
                .padding(.vertical)
            }
            .navigationTitle(exerciseStats.exerciseName)
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

struct ExerciseStatsHeader: View {
    let stats: ExerciseStats
    
    private var formattedLastPerformed: String {
        guard let date = stats.lastPerformed else { return "Never" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(stats.exerciseName)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(stats.exerciseNamePl)
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            HStack(spacing: 0) {
                StatMetric(
                    title: "Sessions",
                    value: "\(stats.totalSessions)",
                    color: .blue
                )
                
                Divider().frame(height: 40)
                
                StatMetric(
                    title: "Personal Record",
                    value: stats.personalRecord.map { "\(String(format: "%.0f", $0)) kg" } ?? "N/A",
                    color: .orange
                )
                
                Divider().frame(height: 40)
                
                StatMetric(
                    title: "Avg Weight",
                    value: "\(String(format: "%.1f", stats.averageWeight)) kg",
                    color: .green
                )
                
                Divider().frame(height: 40)
                
                StatMetric(
                    title: "Last Session",
                    value: formattedLastPerformed,
                    color: .purple
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct WeightProgressionChart: View {
    let exerciseStats: ExerciseStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Weight Progression")
                    .font(.headline)
                    .padding(.leading)
                Spacer()
            }
            
            if exerciseStats.weightProgression.isEmpty {
                ContentUnavailableView(
                    "No Weight Data",
                    systemImage: "chart.line.uptrend.xyaxis",
                    description: Text("Complete exercises with weight tracking to see progression")
                )
                .frame(height: 200)
            } else {
                Chart {
                    ForEach(Array(exerciseStats.weightProgression.enumerated()), id: \.offset) { index, point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Weight", point.weight)
                        )
                        .foregroundStyle(.blue)
                        .interpolationMethod(.catmullRom)
                        
                        PointMark(
                            x: .value("Date", point.date),
                            y: .value("Weight", point.weight)
                        )
                        .foregroundStyle(.blue)
                        .symbolSize(50)
                        
                        // Highlight personal record
                        if let pr = exerciseStats.personalRecord, point.weight == pr {
                            PointMark(
                                x: .value("Date", point.date),
                                y: .value("Weight", point.weight)
                            )
                            .foregroundStyle(.orange)
                            .symbolSize(80)
                            .symbol(.circle)
                        }
                    }
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            Text("\(value.as(Double.self) ?? 0, specifier: "%.0f") kg")
                                .font(.caption)
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    }
                }
                .padding(.horizontal)
                
                if let pr = exerciseStats.personalRecord {
                    HStack {
                        Circle()
                            .fill(.orange)
                            .frame(width: 8, height: 8)
                        Text("Personal Record (\(String(format: "%.0f", pr)) kg)")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct VolumeProgressionChart: View {
    let exerciseStats: ExerciseStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Volume Progression")
                    .font(.headline)
                    .padding(.leading)
                Spacer()
            }
            
            if exerciseStats.volumeProgression.isEmpty {
                ContentUnavailableView(
                    "No Volume Data",
                    systemImage: "chart.bar.fill",
                    description: Text("Complete exercises with weight and rep tracking to see volume")
                )
                .frame(height: 200)
            } else {
                Chart {
                    ForEach(Array(exerciseStats.volumeProgression.enumerated()), id: \.offset) { index, point in
                        BarMark(
                            x: .value("Date", point.date),
                            y: .value("Volume", point.volume)
                        )
                        .foregroundStyle(.green.gradient)
                        .cornerRadius(4)
                    }
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            Text("\(value.as(Double.self) ?? 0, specifier: "%.0f") kg")
                                .font(.caption)
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct AllDataView: View {
    let exerciseStats: ExerciseStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("All Sessions Data")
                    .font(.headline)
                    .padding(.leading)
                Spacer()
            }
            
            if exerciseStats.dataPoints.isEmpty {
                ContentUnavailableView(
                    "No Session Data",
                    systemImage: "list.bullet",
                    description: Text("Complete exercises to see detailed session data")
                )
                .frame(height: 200)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(Array(exerciseStats.dataPoints.enumerated().reversed()), id: \.offset) { index, dataPoint in
                        SessionDataRow(dataPoint: dataPoint, isPR: dataPoint.weight == exerciseStats.personalRecord)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct SessionDataRow: View {
    let dataPoint: ExerciseDataPoint
    let isPR: Bool
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: dataPoint.date)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(dataPoint.sessionDay)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(String(format: "%.0f", dataPoint.weight)) kg")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(isPR ? .orange : .primary)
                    Text("Weight")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(dataPoint.reps)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("Reps")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(String(format: "%.0f", dataPoint.volume)) kg")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    Text("Volume")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            if isPR {
                Image(systemName: "crown.fill")
                    .foregroundColor(.orange)
                    .font(.caption)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isPR ? Color.orange.opacity(0.1) : Color(.systemGray6))
        .cornerRadius(8)
    }
}

struct PersonalRecordsSection: View {
    let stats: ExerciseStats
    
    private var maxVolumeSession: ExerciseDataPoint? {
        stats.dataPoints.max(by: { $0.volume < $1.volume })
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Personal Records")
                    .font(.headline)
                    .padding(.leading)
                Spacer()
            }
            
            VStack(spacing: 8) {
                if let pr = stats.personalRecord {
                    PersonalRecordRow(
                        title: "Max Weight",
                        value: "\(String(format: "%.0f", pr)) kg",
                        icon: "dumbbell.fill",
                        color: .orange
                    )
                }
                
                if let maxVolume = maxVolumeSession {
                    PersonalRecordRow(
                        title: "Max Volume (Single Session)",
                        value: "\(String(format: "%.0f", maxVolume.volume)) kg",
                        icon: "chart.bar.fill",
                        color: .green
                    )
                }
                
                PersonalRecordRow(
                    title: "Total Sessions",
                    value: "\(stats.totalSessions)",
                    icon: "calendar",
                    color: .blue
                )
                
                PersonalRecordRow(
                    title: "Total Volume",
                    value: "\(String(format: "%.0f", stats.totalVolume)) kg",
                    icon: "sum",
                    color: .purple
                )
            }
        }
        .padding(.vertical)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct PersonalRecordRow: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview {
    let sampleStats = ExerciseStats(
        exerciseName: "Bench Press",
        exerciseNamePl: "Wyciskanie na ławce",
        totalSessions: 5,
        dataPoints: [],
        personalRecord: 80.0,
        averageWeight: 70.0,
        totalVolume: 1400.0,
        lastPerformed: Date(),
        weightProgression: [],
        volumeProgression: []
    )
    
    ExerciseStatsView(exerciseStats: sampleStats)
}