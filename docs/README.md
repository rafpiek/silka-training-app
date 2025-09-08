# Silka Training App - Documentation

## Overview
Comprehensive documentation for the Silka Training App, an iOS application for tracking muscle gain workouts with progressive overload support.

## Documentation Structure

### Core Features
1. **[Data Models](01-data-models.md)** - SwiftData models and relationships
2. **[Calendar View](02-calendar-view.md)** - Weekly training schedule interface
3. **[Session View](03-session-view.md)** - Training day management
4. **[Exercise Detail](04-exercise-detail.md)** - Individual exercise tracking
5. **[Timer Functionality](05-timer-functionality.md)** - Session and break timers
6. **[Warmup Exercises](06-warmup-exercises.md)** - Pre-workout routine management
7. **[Completion Tracking](07-completion-tracking.md)** - Multi-level progress system
8. **[Weight Management](08-weight-management.md)** - Progressive overload tracking
9. **[JSON Import](09-json-import.md)** - Training plan data import
10. **[SwiftData Integration](10-swiftdata-integration.md)** - Persistence layer details
11. **[UI Architecture](11-ui-architecture.md)** - SwiftUI design patterns

## Key Features Summary

### Training Management
- ✅ Weekly calendar view with all sessions
- ✅ Detailed session view with exercise list
- ✅ Individual exercise tracking with video demos
- ✅ Warmup and knee rehab exercises
- ✅ Rest day indicators

### Progress Tracking
- ✅ Individual set completion
- ✅ Per-set weight tracking
- ✅ Exercise auto-completion
- ✅ Session completion tracking
- ✅ Visual progress indicators

### Weight & Progressive Overload
- ✅ Weight input per set (not just per exercise)
- ✅ Quick weight adjustments (±2.5kg)
- ✅ Weight history preservation
- ✅ Suggested weights from plan
- ✅ Support for drop sets and pyramids

### Timer Features
- ✅ Session duration timer
- ✅ Break timer with presets
- ✅ Visual countdown display
- ✅ Persistent timers during navigation

### Data Management
- ✅ Offline-first with SwiftData
- ✅ Automatic JSON import
- ✅ Data persistence across launches
- ✅ Reset functionality for sessions

### User Experience
- ✅ Clean, modern SwiftUI design
- ✅ Polish/English bilingual support
- ✅ YouTube video integration
- ✅ Intuitive navigation
- ✅ Visual feedback for all actions

## Technical Stack
- **Language**: Swift 5.0
- **UI Framework**: SwiftUI
- **Data**: SwiftData
- **Video**: WebKit (YouTube embed)
- **Architecture**: MVVM-style with SwiftData
- **Minimum iOS**: 17.0

## App Structure
```
silka/
├── Models/          # Data models
├── Services/        # Import and utilities
├── Views/           # UI components
├── data/           # JSON training plan
└── docs/           # Documentation
```

## Development Principles
1. **Simplicity**: Clean, focused features
2. **Offline-First**: No network dependency
3. **User-Centric**: Designed for gym use
4. **Progressive**: Supports advancement
5. **Maintainable**: Well-documented code

## Future Considerations
- Export workout history
- Multiple training plans
- Progress charts/analytics
- Social sharing features
- Apple Watch companion
- CloudKit sync

## Usage Flow
1. Launch app → Auto-imports training plan
2. View weekly calendar
3. Tap training day
4. Complete warmups
5. Track sets with weights
6. Use break timer between sets
7. Mark exercises complete
8. Complete full session
9. Reset for next workout

## Support
For issues or questions, refer to individual documentation files or check the source code for implementation details.