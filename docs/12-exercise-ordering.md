# Exercise Ordering System

## Overview
Ensures exercises maintain their exact order from the JSON training plan throughout the app lifecycle.

## Problem Addressed
SwiftData relationships might not guarantee order preservation, potentially causing exercises to appear in different order than defined in the training plan.

## Solution Implementation

### 1. Sort Order Field
Added `sortOrder: Int` field to Exercise model:
```swift
var sortOrder: Int = 0
```

### 2. Import Assignment
During JSON import, exercises receive sequential sort order:
```swift
for (index, jsonExercise) in exercises.enumerated() {
    exercise.sortOrder = index
    // ... rest of exercise setup
}
```

### 3. Display Sorting
When displaying exercises in session view:
```swift
session.exercises.sorted(by: { $0.sortOrder < $1.sortOrder })
```

## Benefits
- **Guaranteed Order**: Exercises always appear in training plan order
- **Persistence**: Order maintained across app launches
- **Flexibility**: Allows future reordering features if needed
- **Performance**: Minimal overhead with integer comparison

## Technical Details
- Sort order assigned during initial import (0-based index)
- Sorting happens at display time, not storage
- SwiftData array still maintains insertion order as backup
- Compatible with future drag-to-reorder features

## Example Flow
1. JSON: `[Bench Press, Rows, Deadlift]`
2. Import: Assigns sortOrder 0, 1, 2
3. Storage: SwiftData stores with sortOrder
4. Display: Sorts by sortOrder before showing
5. Result: Always shows in original order

## Migration Note
Existing data without sortOrder will default to 0, maintaining current behavior while new imports get proper ordering.