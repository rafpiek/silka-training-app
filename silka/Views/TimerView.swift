//
//  TimerView.swift
//  silka
//
//  Created by Rafał Piekara on 08/09/2025.
//

import SwiftUI

struct TimerView: View {
    @ObservedObject var sessionTimer: SessionTimer
    @State private var breakTimer = BreakTimer()
    @State private var showingBreakTimer = false
    
    var body: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Session Time")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(timeString(from: sessionTimer.elapsedTime))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .monospacedDigit()
            }
            
            Spacer()
            
            if showingBreakTimer {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Break Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(timeString(from: breakTimer.remainingTime))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(breakTimer.isRunning ? .orange : .primary)
                        .monospacedDigit()
                }
            }
            
            Button(action: {
                if showingBreakTimer {
                    if breakTimer.isRunning {
                        breakTimer.stop()
                    } else {
                        breakTimer.start()
                    }
                } else {
                    showingBreakTimer = true
                    breakTimer.start()
                }
            }) {
                Image(systemName: breakTimer.isRunning ? "pause.circle.fill" : "timer")
                    .font(.title2)
                    .foregroundColor(breakTimer.isRunning ? .orange : .blue)
            }
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

class BreakTimer: ObservableObject {
    @Published var remainingTime: TimeInterval = 60
    @Published var isRunning = false
    private var timer: Timer?
    var duration: TimeInterval = 60
    
    func start() {
        remainingTime = duration
        isRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                self.stop()
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
        remainingTime = duration
    }
    
    func setDuration(_ seconds: TimeInterval) {
        duration = seconds
        remainingTime = seconds
    }
}