# SwiftData Integration

## Overview
Modern persistence layer using SwiftData for offline-first data storage with automatic migrations and type safety.

## Architecture

### Model Container
- Created at app launch
- Shared across all views
- Automatic schema creation
- Migration handling on schema changes

### Schema Definition
```swift
Schema([
    TrainingPlan.self,
    Profile.self,
    WarmupExercise.self,
    TrainingSession.self,
    Exercise.self,
    ProgressionRules.self
])
```

### Relationships
- `@Relationship(deleteRule: .cascade)`
- Parent-child cascading deletes
- Automatic relationship management
- No manual foreign keys

## Data Storage Patterns

### Array Handling
**Problem**: SwiftData doesn't support `[String]` directly

**Solution**: Store as delimited strings
```swift
private var conditionsString: String = ""
var conditions: [String] {
    get { conditionsString.components(separatedBy: "|||") }
    set { conditionsString = newValue.joined(separator: "|||") }
}
```

### Complex Types
**Problem**: Need to store set-specific data

**Solution**: JSON encoding within string field
```swift
private var setsDataString: String = ""
var setsData: [Int: SetData] {
    get { /* JSON decode */ }
    set { /* JSON encode */ }
}
```

## Migration Strategy

### Automatic Migration
- Attempts automatic migration first
- Handles simple schema changes
- Preserves existing data

### Fallback Reset
```swift
catch {
    // Delete corrupted store
    FileManager.default.removeItem(at: storeURL)
    // Create fresh container
    // Re-import from JSON
}
```

## Query Patterns

### Fetching Data
```swift
@Query private var trainingPlans: [TrainingPlan]
```

### Fetch Descriptors
```swift
let descriptor = FetchDescriptor<TrainingPlan>()
let plans = try context.fetch(descriptor)
```

## Context Management

### Model Context
- Injected via environment
- Used for saves and deletes
- Automatic change tracking

### Save Operations
```swift
try? modelContext.save()
```

## Benefits
- Type-safe queries
- Automatic migrations
- Relationship management
- Observable models
- SwiftUI integration
- Offline-first design

## Challenges & Solutions

### Challenge: Array properties
**Solution**: String encoding with computed properties

### Challenge: Migration failures
**Solution**: Automatic reset with re-import

### Challenge: Complex nested data
**Solution**: JSON encoding for flexibility

## Performance
- Lazy loading of relationships
- Efficient queries with predicates
- Minimal memory footprint
- Fast local operations