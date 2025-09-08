# Calendar View

## Overview
The main screen displays a weekly training calendar showing all scheduled sessions and rest days.

## Features

### Week Layout
- Shows all 7 days of the week in Polish (Poniedziałek through Niedziela)
- Scrollable vertical list for easy navigation
- Clean card-based design for each day

### Training Day Cards
- Display day name and training focus
- Show location icon (dumbbell for gym, house for home)
- Exercise count indicator
- Completion status with green checkmark
- Tap to navigate to session details

### Rest Day Cards
- Subdued styling to differentiate from training days
- Bed icon to indicate rest
- Non-interactive (no session to view)

### Visual Indicators
- **Green checkmark**: Session completed
- **Exercise count badge**: Quick overview of workout volume
- **Location icon**: At-a-glance venue information
- **Chevron arrow**: Indicates interactive navigation

## Navigation
- Tap any training day to open detailed session view
- Uses NavigationStack for smooth transitions
- Maintains scroll position when returning from details

## Data Integration
- Fetches training sessions from SwiftData
- Groups sessions by day of week
- Real-time updates when sessions are marked complete
- Persists completion status across app launches