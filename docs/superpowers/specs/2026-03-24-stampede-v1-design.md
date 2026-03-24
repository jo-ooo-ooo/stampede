# Stampede v1 — Design Spec

## Overview

Stampede is an iOS app for simple daily habit check-ins. Users create "stamp cards" for activities they want to track (e.g., Workout, Learn German, Cook at Home), then tap to stamp each day they do it. Optionally, they can attach a short note to any check-in.

The app is motivated by the idea that collecting stamps is a small but effective incentive — especially for people who need a little extra push to maintain habits. The calendar view doubles as the primary analysis tool: seeing your stamps fill up over time tells the story.

## Target User

The app is built for personal use first, with the intention of publishing to the App Store later. v1 is iOS only.

## Tech Stack

- **UI:** SwiftUI
- **Persistence:** SwiftData (local, on-device)
- **Language:** Swift
- **Min iOS version:** 17.0 (for SwiftData support)
- **No backend, no accounts, no network calls in v1**

## Data Model

### StampCard
| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `name` | String | User-facing name, e.g. "Workout" |
| `icon` | String | SF Symbol name, e.g. "dumbbell" |
| `color` | String | Hex color code, e.g. "#FF6B6B" |
| `sortOrder` | Int | Position in the Today view |
| `createdAt` | Date | Creation timestamp |

### StampEntry
| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `stampCard` | StampCard | Relationship to parent card |
| `date` | Date | The day this check-in is for (date only, no time) |
| `note` | String? | Optional short note, e.g. "leg day" |
| `createdAt` | Date | Creation timestamp |

**Constraints:**
- One StampEntry per StampCard per date (unique on `stampCard` + `date`)
- Deleting a StampCard deletes all its entries (cascade)

## App Structure

Three-tab navigation:

### Tab 1: Today (Primary)
- Shows all stamp cards as tappable tiles in a grid or list
- Each tile shows the card's icon, name, and color
- **Not stamped today:** Tile appears muted/outlined
- **Stamped today:** Tile appears filled/highlighted with its color
- **Tap** an unstamped tile → creates a StampEntry for today (instant, one tap)
- **Tap** a stamped tile → shows option to add/edit note or unstamp
- This is the screen you see on app launch — optimized for speed

### Tab 2: Calendar
- Monthly calendar grid
- Each day cell shows small colored dots or mini-icons for stamps collected that day
- Swipe left/right to navigate months
- **Tap a day** → shows a detail sheet listing which cards were stamped and any notes
- Today is visually highlighted
- The calendar IS the analysis — seeing stamps fill up across the month is the reward

### Tab 3: Cards
- List of all stamp cards
- **Add** new card: pick name, icon (SF Symbol picker), color
- **Edit** existing card: change name, icon, color
- **Delete** card (with confirmation — deletes all entries)
- **Reorder** cards (drag to rearrange, affects Today view order)

## Interaction Details

### Check-in Flow
1. Open app → lands on Today tab
2. See your cards → tap the one you did
3. Card visually fills in → done
4. Optionally: tap the stamped card to add a note like "45 min, legs"

### Undo/Edit Flow
- Tapping a stamped card opens a small sheet with:
  - Note field (add or edit)
  - "Remove stamp" button
- This prevents accidental unstamping from a simple tap

### Calendar Day Detail
- Tapping a day on the calendar shows a bottom sheet with:
  - Date header
  - List of stamps for that day (icon + name + note if present)
  - Empty state if no stamps that day

## Visual Design Principles

- Clean, minimal, playful but not childish
- Each stamp card has a user-chosen color — this color is used consistently (tile, calendar dot, detail views)
- SF Symbols for icons — large library, consistent style, no custom assets needed
- Muted/outlined state for "not done" vs filled/vibrant for "done" creates a satisfying visual contrast
- The calendar should feel like a sticker collection — the more filled in, the better it feels

## Scope Boundaries

### In v1
- Create/edit/delete stamp cards (name, icon, color)
- One-tap daily check-in with optional note
- Monthly calendar view with stamp indicators
- Day detail view showing stamps + notes
- All data local on device
- App Store ready (proper app icon, launch screen, etc.)

### Out of v1 (future)
- MCP server + Google Tasks integration (v1.5)
- Urban Sports Club integration (v2)
- Stats, streaks, analytics (v2)
- AI-generated or collectible stamp designs (v2)
- Rich food/coffee logging (v2)
- User accounts, sharing, social features
- Android / cross-platform
- Widget support
- Notifications / reminders
