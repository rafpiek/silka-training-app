# JSON Import System

## Overview
Automatic import system that converts JSON training plan data into SwiftData models on first app launch.

## JSON Structure

### Root Level
- `version`: Plan version identifier
- `profile`: User demographics and goals
- `warmup_and_knee_rehab`: Warmup exercises array
- `variants`: Training plan variations
- `progression_rules`: Progression guidelines

### Profile Section
- Physical stats (age, sex, height, weight)
- Medical conditions array
- Medications array
- Training goals and preferences
- Equipment specifications
- Session time targets

### Exercise Format
```json
{
  "name_pl": "Polish name",
  "name_en": "English name",
  "sets_reps": "4×8-10",
  "start_weight_kg": 50,
  "rir": "2-3",
  "tempo": "3-1-1",
  "video_url": "YouTube link"
}
```

### Weight Handling
- Supports numeric values: `50`
- Handles ranges: `"50-55"`
- Per-hand weights: `start_weight_kg_per_hand`
- Automatic parsing of string ranges

## Import Process

### 1. Initial Check
- Runs on app launch
- Checks for existing data
- Only imports if database empty

### 2. Data Parsing
- `TrainingPlanImporter` class
- Codable structs for JSON mapping
- Error handling for malformed data
- String-to-number conversions

### 3. Model Creation
- Creates TrainingPlan root
- Builds Profile with arrays as strings
- Generates Exercise models
- Links relationships

### 4. Variant Handling
- Parses A and B variants
- Handles schedule references
- Copies referenced days
- Maintains session order

## Error Handling
- File not found handling
- JSON decode errors
- Migration failures trigger reset
- Fallback to fresh import

## Data Transformations

### Array Storage
- Arrays stored as delimited strings
- Separator: `"|||"`
- Workaround for SwiftData limitations

### Weight Parsing
- Extracts first number from ranges
- Handles both dash types (- and –)
- Defaults to 0 if unparseable

### Set Counting
- Regex pattern: `(\d+)(?:-\d+)?[×x]`
- Extracts set count from format
- Handles variations like "3-4×10"

## File Management
- JSON bundled in app resources
- Located in `/silka/data/`
- Added to Xcode project
- Copied to app bundle on build

## Benefits
- No network dependency
- Instant data availability
- Consistent initial state
- Easy plan updates via JSON