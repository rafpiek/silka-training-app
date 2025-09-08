# Completion Tracking System

## Overview
Multi-level completion tracking from individual sets to entire training sessions with visual feedback and data persistence.

## Tracking Levels

### 1. Individual Sets
- Each set tracked independently
- Marked complete with weight used
- Visual green background when done
- Disabled after completion
- Contributes to exercise completion

### 2. Exercise Completion
- Auto-completes when all sets done
- Manual override available
- Timestamp recorded
- Visual indicators:
  - Green checkmark icon
  - Green background tint
  - Progress badge (e.g., "4/4")

### 3. Session Completion
- Requires all exercises complete
- Records completion date/time
- Updates calendar view
- Visual feedback on main screen
- Cannot complete with pending exercises

### 4. Warmup Completion
- Separate from main exercises
- Individual warmup tracking
- Persistent across sessions
- Reset option available

## Visual Indicators

### Colors
- **Green**: Completed items
- **Orange**: In-progress/partial
- **Gray**: Not started
- **Blue**: Active/current weight

### Icons
- ✓ Checkmark circle (filled): Complete
- ○ Empty circle: Not started
- Progress badges: "2/4" format
- Chevron arrows: Navigation available

## Reset Functionality

### Exercise Reset
- Clears all set completions
- Resets weight data
- Available per exercise

### Session Reset
- Resets all exercises
- Clears session completion
- Maintains weight history
- One-tap action

### Warmup Reset
- Clears all warmup completions
- "Reset All Warmups" button
- Preserves exercise data

## Data Persistence
- All completion states saved to SwiftData
- Timestamps for audit trail
- Survives app restarts
- Offline-first architecture

## Business Rules
- Sessions require 100% exercise completion
- Exercises auto-complete at 100% sets
- Weights locked after set completion
- Reset available anytime
- No partial session saves