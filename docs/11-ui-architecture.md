# UI Architecture

## Overview
SwiftUI-based architecture with reactive updates, navigation patterns, and modern iOS design principles.

## View Hierarchy

### Root Level
```
silkaApp
└── ContentView (Calendar)
    └── TrainingSessionView
        ├── WarmupView (Modal)
        └── ExerciseDetailView (Navigation)
```

### Navigation Pattern
- `NavigationStack` for main navigation
- `.navigationDestination` for push transitions
- `.sheet` for modal presentations
- `@State` for view-local state
- `@Bindable` for model mutations

## Component Design

### Card Components
- `TrainingDayCard`: Session preview
- `RestDayCard`: Rest day indicator
- `ExerciseCard`: Exercise in list
- `WarmupExerciseCard`: Warmup item
- `CardioCard`: Cardio section

### Reusable Elements
- Progress bars with tint colors
- Badge labels for counts/weights
- Consistent button styles
- Icon system for visual cues

## State Management

### View State
```swift
@State private var selectedSession: TrainingSession?
@State private var showingTimer = false
@State private var breakTimer = BreakTimer()
```

### Model Binding
```swift
@Bindable var exercise: Exercise
@Environment(\.modelContext) private var modelContext
```

### Observable Objects
```swift
@ObservedObject var sessionTimer: SessionTimer
```

## Design System

### Colors
- **Primary**: System default
- **Green**: Completion/success
- **Orange**: In-progress/breaks
- **Blue**: Active/information
- **Gray**: Inactive/disabled

### Typography
- `.title`: Screen headers
- `.headline`: Section titles
- `.subheadline`: Secondary info
- `.caption`: Metadata
- `.monospacedDigit()`: Timers

### Spacing
- Card padding: 16pt
- Section spacing: 16pt
- Inline spacing: 8-12pt
- Corner radius: 12pt

## Responsive Design

### Device Support
- iPhone optimization
- iPad compatibility
- Dynamic type support
- Dark mode ready

### Layout Adaptation
- ScrollView for long content
- LazyVGrid for set buttons
- HStack/VStack combinations
- Spacer() for flexibility

## Interaction Patterns

### Gestures
- Tap to navigate
- Tap to toggle completion
- Long press (not used)
- Swipe (system back)

### Feedback
- Visual state changes
- Color transitions
- Disabled states
- Progress indicators

## Animation
- `withAnimation` for state changes
- Smooth color transitions
- Progress bar animations
- Sheet presentations

## Accessibility
- System font scaling
- Color contrast compliance
- Button tap targets (44pt)
- Semantic labels

## Performance
- Lazy loading with LazyVGrid
- Conditional rendering
- Efficient redraws
- Minimal view updates