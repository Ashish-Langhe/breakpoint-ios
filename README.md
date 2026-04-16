<div align="center">

# 🔴 Breakpoint

### The wellness companion built for developers who forget they have a body.

[![Swift](https://img.shields.io/badge/Swift-6.2-orange?logo=swift)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-17%2B-blue?logo=apple)](https://developer.apple.com/ios/)
[![Xcode](https://img.shields.io/badge/Xcode-16-blue?logo=xcode)](https://developer.apple.com/xcode/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Build](https://img.shields.io/badge/Status-In%20Development-yellow)]()

<br/>

> **"The best debuggers know when to pause."**

<br/>

</div>

---

## 🧠 The Problem

Software engineers sit for 10–12 hours a day. The body's pain signals are slow —
you don't feel the damage until it accumulates over months. The real problem isn't
chronic illness. It's the **moment-to-moment forgetting**.

You're deep in a debugging session. Two hours pass. Your neck hurts.
You had zero awareness of time passing at all.

Existing break reminder apps fire on a **fixed timer** — every 45 minutes, forever,
regardless of whether you're in a standup, a focus block, or already walking.
Users snooze twice and delete the app in week two.

**Breakpoint is different.** It detects when you are *actually* stationary.

---

## 💡 The Solution

Breakpoint uses **CoreMotion** to detect real inactivity — not a countdown timer.
When you've been genuinely still for a threshold duration, it nudges you intelligently.
It respects your focus blocks, learns from your behaviour, and has an **AI Genie**
you can actually talk to when you need personalised guidance.
You've been sitting 67 minutes.
→ Breakpoint fires a nudge.
→ You tap "Ask Genie".
→ "My lower back is killing me, I have 45 seconds."
→ Genie gives you a specific, time-bounded stretch. Instantly.

No generic advice. No kitchen timer. A companion that knows your context.

---

## ✨ Features

### 🟢 Smart Inactivity Detection
- Uses `CMMotionActivityManager` + `CMPedometer` to detect genuine stillness
- Fires only when you are actually stationary — not on a fixed timer
- Resets automatically on any movement detected
- Respects **focus blocks** — deep work hours are never interrupted

### 🔔 Intelligent Nudges
- **5 nudge types** rotating: Stretch · Walk · Water · Eye rest (20-20-20) · Breathe
- Action buttons directly on lock screen: **Done** / **Snooze 10m** / **Ask Genie**
- Adaptive learning — suppresses nudge slots with high snooze rates after 7 days
- Resilient — reschedules on app restart or device reboot

### 🧞 Genie — AI Wellness Coach
- Powered by **Claude API** (Anthropic)
- Context-injected before every message: sitting time, last break, time of day
- Ask anything: *"My back hurts"* · *"I have 30 seconds"* · *"Motivate me"*
- Quick-reply chips for instant interaction
- Tap **Ask Genie** on any notification → deep links directly into chat
- API key secured in **Keychain** — never hardcoded, never in UserDefaults

### 📊 Today Dashboard
- Animated **activity ring** showing break completion vs daily goal
- Live **sitting streak counter** with urgency colour states
  - 🟢 Green — under 30 minutes
  - 🟡 Amber — 30 to 45 minutes
  - 🔴 Red — over 45 minutes (nudge imminent)
- Step count via `CMPedometer`
- Water intake log with separate 2hr reminder chain
- Next nudge countdown

### 📈 Weekly Insights
- **Swift Charts** bar chart — break score per day of week
- Best day of the week detection
- Longest sitting streak (the shame stat that actually motivates)
- **Genie weekly summary** — Claude generates a 2-line personalised observation every Sunday
- **Shareable weekly card** — rendered via `ImageRenderer`, share to LinkedIn or Twitter

### 🔲 Home Screen & Lock Screen Widget
- **WidgetKit** small + medium home screen widgets
- Lock screen widget (`accessoryCircular` + `accessoryRectangular`)
- Sitting streak always visible without opening the app
- Shared data via **App Group** between app and widget extension

---

## 🏗️ Architecture

Breakpoint follows **MVVM** (Model–View–ViewModel) with a dedicated **Service Layer**.

```
┌─────────────────────────────────────────────┐
│                 View Layer                  │
│        SwiftUI — pure rendering only        │
│    TodayView · GenieView · InsightsView     │
└──────────────────┬──────────────────────────┘
                   │  @StateObject / @Published
┌──────────────────▼──────────────────────────┐
│              ViewModel Layer                │
│         Business logic + UI state           │
│      TodayViewModel · GenieViewModel        │
└──────────────────┬──────────────────────────┘
                   │  Protocol injection
┌──────────────────▼──────────────────────────┐
│               Service Layer                 │
│          Framework interactions             │
│   InactivityService · GenieService          │
│   NotificationService · KeychainService     │
└──────────────────┬──────────────────────────┘
                   │  @Model queries
┌──────────────────▼──────────────────────────┐
│                Model Layer                  │
│           SwiftData persistence             │
│    BreakEvent · SittingSession              │
│    UserSettings                             │
└─────────────────────────────────────────────┘
```

**Why MVVM?**
Views never touch SwiftData or CoreMotion directly. ViewModels depend on
Service *protocols* — enabling full unit testing via mock injection without
a real device. Services own one responsibility each. Clean, testable, maintainable.

---

## 🎨 Design Patterns Used

| Pattern | Swift Implementation | Problem It Solves |
|---------|---------------------|-------------------|
| **Observer** | `@Published` + `ObservableObject` | Views react to data changes automatically |
| **Dependency Injection** | Protocol + `init` injection | Services are mockable in unit tests |
| **Strategy** | `NudgeStrategy` protocol | Each nudge type is interchangeable |
| **Repository** | `BreakRepository` wrapping SwiftData | ViewModels never write raw fetch descriptors |
| **Singleton** | `static let shared` | Stateless services like Analytics, Keychain |
| **Decorator** | `ViewModifier` | Reusable card styling across all screens |

---

## 🛠️ Tech Stack

| Technology | Version | Purpose |
|-----------|---------|---------|
| **SwiftUI** | iOS 17+ | All UI — screens, components, animations |
| **SwiftData** | iOS 17+ | Local persistence — sessions, events, settings |
| **CoreMotion** | CMMotionActivityManager | Inactivity detection, step count |
| **UserNotifications** | UNUserNotificationCenter | Smart nudge scheduling + action buttons |
| **Swift Charts** | iOS 16+ | Weekly insights bar chart |
| **WidgetKit** | iOS 16+ | Home screen + lock screen widgets |
| **Claude API** | claude-sonnet-4-5 | Genie AI wellness coach |
| **Keychain Services** | Security.framework | Secure API key storage |
| **Fastlane** | match + gym + pilot | Certificate management + TestFlight CD |
| **GitHub Actions** | macos-14 runner | CI — lint + build on every push |
| **Firebase Crashlytics** | Latest | Production crash reporting |
| **SwiftLint** | 0.54+ | Code style enforcement |

---

## 📁 Project Structure

```
Breakpoint/
├── App/
│   ├── BreakpointApp.swift          ← @main entry point
│   └── AppDelegate.swift            ← Notification delegate
│
├── Features/
│   ├── Today/
│   │   ├── TodayView.swift
│   │   ├── TodayViewModel.swift
│   │   └── Components/
│   │       ├── ActivityRing.swift
│   │       ├── StreakCounter.swift
│   │       └── WaterCounter.swift
│   ├── Genie/
│   │   ├── GenieView.swift
│   │   ├── GenieViewModel.swift
│   │   └── ChatBubble.swift
│   ├── Insights/
│   │   ├── InsightsView.swift
│   │   └── InsightsViewModel.swift
│   └── Settings/
│       └── SettingsView.swift
│
├── Core/
│   ├── Models/
│   │   ├── BreakEvent.swift
│   │   ├── SittingSession.swift
│   │   └── UserSettings.swift
│   ├── Services/
│   │   ├── InactivityService.swift
│   │   ├── NotificationService.swift
│   │   ├── GenieService.swift
│   │   └── KeychainService.swift
│   └── Extensions/
│       ├── Date+Helpers.swift
│       └── Color+DS.swift
│
├── DesignSystem/
│   └── DS.swift                     ← All tokens — colour, font, spacing
│
└── Resources/
    ├── Assets.xcassets
    └── Localizable.strings
```
---

## ⚙️ CI/CD Pipeline

```
Every push to any branch
          │
          ▼
┌─────────────────────┐
│   GitHub Actions    │
│   macos-14 runner   │
├─────────────────────┤
│  1. Checkout code   │
│  2. SwiftLint       │  ← fails on any violation
│  3. Build Debug     │  ← iPhone 16 simulator
│  4. Unit Tests      │  ← XCTest suite
└──────────┬──────────┘
           │
     ✅ Green → safe to merge
     ❌ Red   → fix before PR
           │
     Merge to develop
           │
           ▼
┌─────────────────────┐
│   Fastlane beta     │
├─────────────────────┤
│  1. Bump build no.  │
│  2. match certs     │
│  3. Build Release   │
│  4. Upload to TF ✈️ │
└─────────────────────┘
```

---

## 🧪 Testing Strategy

Tests live in `BreakpointTests/`. Target: **70%+ coverage on Services/ + Core/**.

```swift
// Example — focus block suppression test
func test_nudge_suppressed_during_focus_block() {
    let scheduler = NudgeScheduler()
    let block = FocusBlock(startHour: 14, endHour: 16)

    XCTAssertFalse(scheduler.shouldNudge(at: hour(15), focusBlocks: [block]))
    XCTAssertTrue(scheduler.shouldNudge(at: hour(17), focusBlocks: [block]))
}
```

CoreMotion is mocked via `InactivityServiceProtocol` — no real device needed for tests.

---

## 🚀 Getting Started
 
```bash
# Clone the repo
git clone https://github.com/Ashish-Langhe/breakpoint-ios.git
cd breakpoint-ios

# Open in Xcode
open Breakpoint.xcodeproj
```

**Requirements:**
- Xcode 16+
- iOS 17+ device or simulator
- Claude API key from [console.anthropic.com](https://console.anthropic.com)
  *(add to Keychain — never hardcode)*

---


## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

<div align="center">

**Built by a developer, for developers who forget they have a body.**

⭐ Star this repo if you find it useful — it helps more developers discover it.

</div>
