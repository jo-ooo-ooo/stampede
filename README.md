# Stampede

Daily habit tracker for iOS. Create stamp cards, check in with one tap, and track consistency over time through a calendar view.

> **Status:** In active development. Not yet available on the App Store.

## Overview

Stampede turns daily habits into collectible stamps. Each habit gets a card with a weekly stamp strip showing your progress at a glance. The calendar view provides a monthly overview using a color-coded dot grid — one fixed slot per habit, six habits visible per day.

### Key Features

- **Stamp cards** — Create cards for habits you want to track, each with a custom icon and color
- **One-tap check-in** — Tap today's slot on the stamp strip to log a habit
- **Single & multi mode** — Single-mode cards allow one check-in per day; multi-mode cards allow unlimited
- **Calendar view** — Monthly dot grid showing which habits were completed on each day
- **Optional notes** — Attach a short note to any check-in

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | SwiftUI |
| Persistence | SwiftData (on-device) |
| Min iOS | 17.0 |
| Project | XcodeGen |

No backend, no accounts, no network calls.

## Setup

```bash
brew install xcodegen   # if not installed
cd Stampede
xcodegen generate
open Stampede.xcodeproj
```

## License

All rights reserved.
