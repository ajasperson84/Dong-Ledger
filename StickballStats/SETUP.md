# Stickball Stats - Setup Guide

A retro 1980s Tron-themed iPhone app for tracking stickball league statistics with real-time cloud sync.

## Features

- **Weekly Stats Tracking**: Track Dongs, Drops, Double Plays, Salamies, and Wins for each player
- **Year-Long Leaderboard**: See cumulative stats and rankings across the season
- **Multi-User Cloud Sync**: All league managers can update stats in real-time via Firebase
- **Quick Batch Entry**: Update all players' stats for a week in one screen
- **Retro Tron Aesthetic**: Neon colors, glowing effects, and dark grid backgrounds

## Prerequisites

- Xcode 15.0 or later
- iOS 17.0+ device or simulator
- Apple Developer account (for device testing)
- Firebase account (free tier works fine)

## Firebase Setup

### 1. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project" (or use an existing one)
3. Enter project name: "Stickball Stats" (or your preferred name)
4. Enable/disable Google Analytics as you prefer
5. Click "Create project"

### 2. Add iOS App to Firebase

1. In Firebase Console, click the iOS icon to add an iOS app
2. Enter the bundle ID: `com.stickball.stats`
3. Enter app nickname: "Stickball Stats"
4. Skip the App Store ID for now
5. Click "Register app"
6. **Download `GoogleService-Info.plist`**
7. Replace the placeholder file at `StickballStats/GoogleService-Info.plist` with the downloaded file

### 3. Set Up Firestore Database

1. In Firebase Console, go to "Build" → "Firestore Database"
2. Click "Create database"
3. Choose "Start in production mode" (we'll set up rules next)
4. Select a Cloud Firestore location closest to your users
5. Click "Enable"

### 4. Configure Firestore Security Rules

In Firestore, go to "Rules" tab and replace with:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // Players collection - anyone can read, authenticated or not
    // For production, you may want to add authentication
    match /players/{playerId} {
      allow read, write: if true;
    }

    // Weekly stats collection
    match /weeklyStats/{statsId} {
      allow read, write: if true;
    }
  }
}
```

> **Note**: These rules allow anyone to read/write. For a production app with many users, you should add Firebase Authentication and restrict access to authenticated users.

### 5. Create Firestore Indexes (Optional but Recommended)

For better query performance, create these composite indexes:

1. Go to Firestore → "Indexes" tab
2. Click "Create index"
3. Create these indexes:

**Index 1 - Players by active status and name:**
- Collection: `players`
- Fields: `isActive` (Ascending), `name` (Ascending)

**Index 2 - Weekly stats by year:**
- Collection: `weeklyStats`
- Fields: `year` (Ascending), `weekNumber` (Ascending)

**Index 3 - Weekly stats lookup:**
- Collection: `weeklyStats`
- Fields: `playerId` (Ascending), `weekNumber` (Ascending), `year` (Ascending)

## Building the App

### 1. Open in Xcode

```bash
cd StickballStats
open StickballStats.xcodeproj
```

### 2. Wait for Swift Package Manager

Xcode will automatically fetch the Firebase SDK. This may take a few minutes the first time.

### 3. Select Target Device

Choose your iOS device or simulator from the device dropdown.

### 4. Build and Run

Press `Cmd+R` or click the Play button to build and run.

## Using the App

### Adding Players

1. Go to the "PLAYERS" tab
2. Tap the + button or "ADD NEW PLAYER"
3. Enter player name (required)
4. Optionally add jersey number and team name
5. Tap "ADD PLAYER"

### Recording Weekly Stats

**Individual Entry:**
1. Go to "WEEKLY" tab
2. Tap on any player row
3. Use +/- buttons to adjust each stat
4. Tap "SAVE STATS"

**Batch Entry (Recommended for game day):**
1. Go to "WEEKLY" tab
2. Tap the pencil icon in the top right
3. Tap any player to expand their stats editor
4. Update all players quickly
5. Tap "SAVE ALL" when done

### Viewing Leaderboard

1. Go to "RANKINGS" tab
2. Use left/right arrows to change year
3. Tap category pills to sort by different stats
4. Top 3 players get special highlighting

### Week Navigation

- Use the left/right arrows on the Weekly tab to navigate between weeks
- Stats are automatically organized by week and year

## Stat Categories

| Stat | Description |
|------|-------------|
| **Dongs** | Home runs / big hits |
| **Drops** | Dropped catches (negative) |
| **Double Plays** | Double plays turned (negative for batter) |
| **Salamies** | Grand slams |
| **Wins** | Games won |

## Troubleshooting

### Firebase Connection Issues

- Verify `GoogleService-Info.plist` is properly configured
- Check Firebase Console for any service outages
- Ensure Firestore security rules allow access

### Build Errors

- Clean build folder: `Cmd+Shift+K`
- Reset package caches: File → Packages → Reset Package Caches
- Ensure Xcode 15+ is installed

### Stats Not Syncing

- Check internet connection
- Pull to refresh on any list
- Check Firebase Console → Firestore to see if data exists

## Customization

### Changing Colors

Edit `Theme/TronTheme.swift` to customize the color palette:

```swift
struct TronColors {
    static let cyan = Color(red: 0.0, green: 0.95, blue: 0.95)
    static let orange = Color(red: 1.0, green: 0.6, blue: 0.2)
    // ... modify as needed
}
```

### Adding Stat Categories

1. Add new property to `WeeklyStats` in `Models/WeeklyStats.swift`
2. Add to `YearlyStats` aggregation
3. Add color in `TronTheme.swift` → `colorForStat()`
4. Add UI controls in entry views

## Architecture

```
StickballStats/
├── Models/
│   ├── Player.swift          # Player data model
│   └── WeeklyStats.swift     # Weekly and yearly stats models
├── Views/
│   ├── WeeklyStatsView.swift      # Weekly stats list
│   ├── PlayerStatsEntryView.swift # Individual stat entry
│   ├── BatchStatsEntryView.swift  # Batch stat entry
│   ├── LeaderboardView.swift      # Year rankings
│   ├── PlayersView.swift          # Player management
│   └── AddEditPlayerView.swift    # Add/edit player form
├── Components/
│   ├── StatCounter.swift     # +/- stat controls
│   └── PlayerRow.swift       # Player list row
├── Services/
│   └── StatsService.swift    # Firebase/Firestore service
├── Theme/
│   └── TronTheme.swift       # Colors and styling
└── ContentView.swift         # Main tab navigation
```

## License

MIT License - Feel free to use and modify for your league!
