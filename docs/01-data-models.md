# Data Models

## Overview
The app uses SwiftData for local persistence with a comprehensive model structure that mirrors the JSON training plan format.

## Core Models

### TrainingPlan
- Root model containing all training data
- Stores version, profile, warmup exercises, training sessions, and progression rules
- Automatically imports from JSON on first launch

### Profile
- User's physical stats (age, sex, height, weight)
- Medical conditions and medications (stored as delimited strings for SwiftData compatibility)
- Training goals and preferences
- Equipment available at home and gym

### Exercise
- Bilingual names (Polish/English)
- Sets and reps specification
- Individual set tracking with `SetData` structure
- Weight tracking per set (not just per exercise)
- Automatic completion when all sets are done
- RIR (Reps in Reserve) and tempo specifications
- YouTube video URLs for form guidance

### SetData
- Tracks completion status for each set
- Stores weight used for each set
- Enables progressive overload tracking
- Persisted as JSON within Exercise model

### TrainingSession
- Day of week and location (gym/home)
- Focus area for the session
- Collection of exercises
- Cardio specifications
- Completion tracking with date stamps

### WarmupExercise
- Specialized warmup and knee rehab exercises
- Completion tracking
- Video demonstrations
- Sets and tempo specifications

## Data Flow
1. JSON file bundled with app contains complete training plan
2. On first launch, `TrainingPlanImporter` parses JSON and creates SwiftData models
3. All changes persist locally using SwiftData
4. Array properties use string encoding to work around SwiftData limitations