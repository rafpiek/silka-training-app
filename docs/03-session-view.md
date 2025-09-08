# Training Session View

## Overview
Detailed view for managing and tracking individual training sessions with exercises, timers, and completion tracking.

## Layout Structure

### Session Header
- Training focus/theme for the day
- Location indicator (gym or home)
- Overall completion status
- Visual styling with background card

### Warmup Section
- Button to access warmup exercises
- Opens modal sheet with knee rehab exercises
- Separate completion tracking for warmups

### Exercise List
- Numbered exercises in execution order
- Each exercise shows:
  - English and Polish names
  - Sets × Reps specification
  - Progress indicator (e.g., "2/4" sets completed)
  - Weight being used (blue) or suggested (gray)
  - RIR (Reps in Reserve) if specified
- Tap to open detailed exercise view

### Cardio Section
- Displays LISS cardio duration
- Orange-tinted card for visual distinction
- Typically shows "LISS 8-12 min" format

### Session Controls
- **Complete Session**: Enabled when all exercises done
- **Reset Session**: Clears all exercise completions

## Timer Integration
- Session timer in toolbar
- Tracks total workout duration
- Shows/hides timer display with toggle
- Persists during session navigation

## Visual Feedback
- Green background for completed exercises
- Progress badges show completion status
- Disabled complete button until all exercises done
- Real-time updates as exercises are marked complete

## Data Management
- Saves completion status to SwiftData
- Tracks completion date/time
- Updates calendar view automatically
- Preserves state across app launches