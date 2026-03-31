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
| `sortOrder` | Int | Position in the Cards view |
| `allowsMultiple` | Bool | If true, multiple check-ins per day are allowed. Default: false |
| `createdAt` | Date | Creation timestamp |

### StampEntry
| Field | Type | Description |
|-------|------|-------------|
| `id` | UUID | Primary key |
| `stampCard` | StampCard | Relationship to parent card |
| `date` | Date | The day this check-in is for (date only, no time) |
| `note` | String? | Optional short note, e.g. "leg day" |
| `createdAt` | Date | Creation timestamp |

**Implementation note:** `StampEntry.date` is stored as a `Date` normalized to midnight (start of day) in the device's local time zone. The uniqueness constraint is enforced at the application level by comparing normalized dates.

**Constraints:**
- For cards with `allowsMultiple = false`: one StampEntry per StampCard per date (enforced at app level)
- For cards with `allowsMultiple = true`: unlimited StampEntries per StampCard per date
- Deleting a StampCard deletes all its entries (cascade)
- `date` is normalized to midnight (00:00:00) in the device's current local time zone. All date comparisons use this normalized form. If the user travels across time zones, minor inconsistencies are acceptable — the device's local time is always the source of truth.

**Validation Rules:**
- `StampCard.name`: 1–30 characters, trimmed of whitespace. Duplicate names allowed.
- `StampEntry.note`: 0–200 characters.
- `StampCard.icon`: Must be a valid SF Symbol name from a curated set of ~40-50 icons covering common habit categories (fitness, food, learning, wellness, work, creative, social, etc.). The set is defined in the app and can be expanded in future versions.
- `StampCard.color`: Must be one of the preset palette values (TBD).

## App Structure

Two-tab navigation:

### Tab 1: Cards (Primary)
- Shows all stamp cards as tappable tiles in a 2-column grid
- Each tile shows the card's icon, name, color, and a **checkmark button** (top-right)
- **Checkmark button** → stamps the card for today (one tap, with animation)
- **Single-mode cards:** After stamping, card grays out and checkmark is disabled for the rest of the day
- **Multi-mode cards:** Checkmark stays active, shows a count badge with today's total
- **Tap card body** → navigates to card detail view
- **Add** new card via + button: pick name, icon (SF Symbol picker), color, single/multiple mode
- This is the screen you see on app launch — optimized for speed

### Card Detail View
- Total stamp count
- Full stamp history (date + note if present)
- Edit card (name, icon, color, mode) via ··· menu
- Delete card (with confirmation) via ··· menu

### Tab 2: Calendar
- Monthly calendar grid
- Each day cell shows small colored dots for stamps collected that day
- Prev/next buttons to navigate months (bounded: cannot navigate earlier than the month the app was first used)
- **Tap a day** → shows a detail sheet listing which cards were stamped and any notes
- Today is visually highlighted
- The calendar IS the analysis — seeing stamps fill up across the month is the reward

## Interaction Details

### Check-in Flow
1. Open app → lands on Cards tab
2. See your cards → tap the checkmark on the one you did
3. Checkmark fills in with celebration animation → done
4. For single-mode cards, the card grays out (done for the day)
5. For multi-mode cards, a count badge appears and you can keep tapping

### Card Management
- Tap card body → card detail view with history and stats
- From detail view: edit card or delete card via ··· menu

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
- TestFlight-ready (proper app icon, launch screen)

### Out of v1 (future)
- Backdating stamps (stamping past days)
- MCP server + Google Tasks integration (v1.5)
- Urban Sports Club integration (v2)
- Stats, streaks, analytics (v2)
- AI-generated or collectible stamp designs (v2)
- Rich food/coffee logging (v2)
- User accounts, sharing, social features
- Android / cross-platform
- Widget support
- Notifications / reminders
