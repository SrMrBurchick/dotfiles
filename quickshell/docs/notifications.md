## Quickshell Notification Server Setup

### Overview

The goal was to create a notification system that displays notifications in a simple popup window at the top-left corner of the active monitor when receiving notifications via `notify-send`.

Key features:
- Simple text-only notification popup
- Auto-destroy after 5 seconds timeout
- Positioned on the focused monitor

### Steps Completed

#### 1. Created Notification Popup Component

**File:** `Components/Notification/NotificationPopup.qml`

Created a simplified notification popup component:

```qml
Window {
    id: popupRoot
    required property var notification
    required property var screen

    width: 300
    height: 60
    color: "transparent"
    flags: Qt.Tool | Qt.FramelessWindowHint | Qt.WindowStaysOnTopWindow

    Timer {
        id: closeTimer
        interval: 5000  // Auto-close after 5 seconds
        running: true
        onTriggered: popupRoot.close()
    }
    // ... displays only summary text with close button
}
```

Features:
- Simple text-only display (summary only)
- Auto-destroy after 5 seconds via Timer
- Close button (×) to dismiss manually
- Positioned at top-left of active monitor

#### 2. Updated NotificationService

**File:** `Services/NotificationService.qml`

- Added `pragma ComponentBehavior: Bound` for proper QML component behavior
- Imported `Quickshell.Hyprland` to track focused monitor
- Added active screen tracking via `Hyprland.focusedMonitor`
- Created `showPopup()` function that positions popup on active monitor at top-left
- Simplified the notification handling (removed timeStr which required unavailable `Time` object)

#### 3. Fixed MainRender Reference

**File:** `Components/Render/MainRender.qml`

- Changed reference from `Notifs.list` (caelestia's service) to `NotificationService.list` (our own service)

#### 4. Fixed Import in shell.qml

**File:** `shell.qml`

- Added `import "./Services"` to ensure NotificationService singleton is loaded on startup

### Key Issues Fixed

1. **DBus service not registered** - Fixed by ensuring NotificationService is imported in shell.qml
2. **`Notifs` not defined** - Fixed by using `NotificationService` instead of caelestia's `Notifs`
3. **`Time` not defined** - Removed the `timeStr` property that referenced unavailable `Time` object
4. **`implicitHeight` not defined** - Changed to fixed height (120px)
5. **Signal connect error** - Removed the problematic `.connect()` call on non-signal

### How It Works

1. On Quickshell startup, `NotificationService` singleton loads and starts a D-Bus notification server
2. When `notify-send` sends a notification, the server receives it via D-Bus
3. The `onNotification` callback creates a popup window positioned at `(screen.x + 20, screen.y + 60)` on the active monitor
4. The popup displays the notification summary text
5. After 5 seconds, the Timer triggers and closes/destroys the popup automatically

### Files Modified

| File | Changes |
|------|---------|
| `Services/NotificationService.qml` | Created notification handling with monitor tracking |
| `Components/Notification/NotificationPopup.qml` | Created popup UI component |
| `Components/Render/MainRender.qml` | Fixed Notifs → NotificationService reference |
| `shell.qml` | Added Services import to load NotificationService |