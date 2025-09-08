# Weight Management System

## Overview
Comprehensive weight tracking system supporting progressive overload with per-set granularity and historical tracking.

## Features

### Starting Weights
- Imported from JSON training plan
- Separate tracking for:
  - Standard weights (kg)
  - Per-hand weights (dumbbells)
- Suggested weights displayed
- Smart defaults based on exercise type

### Per-Set Weight Tracking
- Individual weight for each set
- Supports training variations:
  - Drop sets (decreasing weight)
  - Pyramid sets (varying weight)
  - Straight sets (same weight)
  - Progressive overload

### Weight Input Methods
1. **Manual Entry**
   - Text field with decimal support
   - Keyboard type: decimal pad
   - Format: XX.X kg

2. **Quick Adjustment**
   - Plus button: +2.5kg
   - Minus button: -2.5kg
   - Instant save on adjustment
   - Minimum weight: 0kg

3. **Auto-Population**
   - Uses last session's weight
   - Falls back to suggested weight
   - Pre-fills for convenience

### Visual Feedback
- **Blue badge**: Active/tracked weight
- **Gray badge**: Suggested weight
- **Green background**: Set completed with weight
- Weight displays in exercise list
- "kg" or "kg/h" (per hand) indicators

### Data Structure
```
SetData {
  isCompleted: Bool
  weight: Double?
  reps: Int? (future use)
}
```

### Weight History
- Persisted across sessions
- Available for progression analysis
- Shows last used weight
- Supports weight progression tracking

### Smart Features
- Auto-saves on weight change
- Locks weight after set completion
- Maintains weight during resets
- Suggests based on previous performance

## Use Cases
- **Linear Progression**: Add weight each week
- **Drop Sets**: Reduce weight each set
- **Pyramid Training**: Increase then decrease
- **Deload Weeks**: Temporary reduction
- **Testing**: Track 1RM attempts

## Integration
- Stored in SwiftData as JSON
- Syncs with exercise completion
- Updates session view badges
- Preserves historical data