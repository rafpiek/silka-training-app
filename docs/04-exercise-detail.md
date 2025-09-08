# Exercise Detail View

## Overview
Comprehensive exercise management with individual set tracking, weight logging, video demonstrations, and timer integration.

## Core Features

### Exercise Information
- Exercise name in English and Polish
- Sets × Reps specification
- Starting weight suggestions
- RIR (Reps in Reserve) guidance
- Tempo specifications
- Special notes or modifications

### YouTube Video Integration
- Embedded video player for form demonstrations
- Extracts video ID from various YouTube URL formats
- Non-scrollable player for better UX
- Modal presentation for full-screen viewing

### Individual Set Tracking
- **Per-Set Management**: Each set tracked independently
- **Weight Input**: 
  - Text field for manual entry
  - Quick +/- buttons (±2.5kg increments)
  - Suggested weight from training plan
  - Weight persists per set
- **Visual States**:
  - Gray background: Not started
  - Green background: Completed
  - Disabled inputs after completion
- **Progress Bar**: Visual completion percentage
- **Auto-completion**: Exercise marks complete when all sets done

### Weight Tracking Features
- Default weight from JSON plan
- Individual weight per set for:
  - Drop sets
  - Pyramid training
  - Progressive overload
- Weight history preserved
- Shows last used weight in session view

### Timer Integration
- Break timer with preset durations (30s, 60s, 90s, 120s)
- Visual countdown display
- Orange color coding for active breaks
- Stop button for early termination

### Exercise Actions
- **Reset Sets**: Clear all completions and weights
- **Skip**: Close without saving
- **Delete**: Remove exercise from session
- Confirmation dialog for destructive actions

## Data Persistence
- All set data saved to SwiftData
- Weight history maintained across sessions
- Completion timestamps recorded
- Supports offline usage