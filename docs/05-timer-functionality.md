# Timer Functionality

## Overview
Dual timer system for tracking workout duration and managing rest periods between sets.

## Session Timer

### Features
- Tracks total workout duration
- Starts/stops on demand
- Displays elapsed time in MM:SS format
- Persists during navigation between views
- Observable object pattern for real-time updates

### Display
- Located in navigation toolbar
- Toggle visibility with timer button
- Blue color when active
- Shows in header bar for constant visibility

### Implementation
- `SessionTimer` class with ObservableObject
- Updates every second using Timer
- Calculates elapsed time from start date
- Supports pause/resume functionality

## Break Timer

### Features
- Preset durations: 30s, 60s, 90s, 120s
- One-tap quick start buttons
- Countdown display
- Auto-stop at zero
- Manual stop option

### Visual Design
- Orange color scheme for breaks
- Prominent countdown display
- Stop button when active
- Compact button grid for duration selection

### Use Cases
- Rest between sets
- Recovery periods
- Timed stretches
- Cardio intervals

## Integration Points

### Exercise Detail View
- Break timer section below exercise info
- Quick access during set execution
- Visual feedback for active breaks

### Session View
- Session timer in toolbar
- Tracks entire workout duration
- Helps monitor training density

## Technical Details
- Timer.scheduledTimer for accurate timing
- @Published properties for UI updates
- TimeInterval for duration calculations
- Date-based timing for accuracy