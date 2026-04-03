# Notification Toast Feature Enhancement

## Overview

Enhance the notification toast system to support interactive features: action buttons, inline replies, progress bars, rich text body rendering, timer ring indicator, and improved hover feedback. All features are already declared as supported by the notification server but lack UI implementation in the toast cards.

## Files Involved

| File | Role |
|------|------|
| `config/components/ToastCard.qml` | Toast card UI — primary target for changes |
| `config/components/GlassIconButton.qml` | Rename to `GlassButton.qml`, update all references |
| `config/components/RichText.qml` | New — thin rich text wrapper component |
| `config/components/HoverBackdrop.qml` | Modify to support hover brightness state |
| `config/services/Notifications.qml` | Service — progress detection, replacement revival |
| `config/widgets/NotificationToasts.qml` | Toast container — no major changes expected |
| `scripts/test-notifications.sh` | New — test script for all notification features |

## Design Decisions

### 1. Timer Ring (Close Button)

Replace the current X close button with a circular timer ring indicator:

- **Visual**: A ring with a cross (✕) centered inside it
- **Timer animation**: The ring arc drains counterclockwise from the 12 o'clock position, showing remaining time before auto-expiry. Starts as a full ring, gap grows counterclockwise until the ring disappears and the notification expires
- **Color**: Uses `Colors.palette.subtext0` — no color change as time runs out (notifications are not urgent by nature)
- **Click behavior**: Clicking the ring dismisses the notification immediately
- **Hover**: Independent hover feedback via `HoverHandler` — the ring area brightens on hover
- **Size**: 22x22px, large enough to be a reasonable click target

**Non-timed notifications** show alternative indicators instead of the draining ring:

- **Critical urgency** (no timeout): Display a `!` icon inside the ring track, using the urgency tint color
- **In-progress** (progress bar active, value < 100): Display an hourglass nerd font icon inside the ring track. Still clickable to dismiss

### 2. Hover Feedback

- **Card backdrop**: When the mouse hovers over the toast, the `HoverBackdrop` base color opacity increases slightly (brighter). Animated with `ColorAnimation` via `Behavior`
- **Close button**: Independent hover state on top of card hover
- **All hover handling** uses `HoverHandler` exclusively — no `MouseArea` for hover detection. `MouseArea` is only used where click handling is needed (close button, action buttons, reply send). This avoids the exclusive-grab issue where hovering a child element would unregister hover on the parent
- **Timer freeze**: The expiration timer freezes when the card is hovered, when the reply text field has active focus, or while a button is being pressed

### 3. Action Buttons

- **Layout**: Compact pill buttons in a `Flow` layout, wrapping to multiple lines if needed
- **Component**: Use `GlassButton` (renamed from `GlassIconButton`) — the `icon` property is just a string passed to `StyledText`, so it works for text labels as-is
- **All actions rendered**: No special casing for any action index. Every action in `notification.actions` gets a pill button showing `action.text`
- **Click behavior**: Clicking an action button calls `Notifications.invokeAction(notification, actionIndex)`
- **Visibility**: Only shown when `notification.actions` is non-empty

### 4. Inline Reply

- **Condition**: Shown when `notification.hasInlineReply` is `true`
- **Layout**: A text input field with the `notification.inlineReplyPlaceholder` as placeholder text, alongside a "Send" `GlassButton`
- **Focus**: Never auto-focus. Waits for user click. Keyboard focus is never grabbed automatically
- **Timer freeze**: While the reply field has active focus, the notification timer is frozen
- **Send flow**:
  1. User types reply and clicks Send
  2. The input area animates to show a "Sent" confirmation message (replacing the text field and send button)
  3. The timer resumes and the notification dismisses naturally when time runs out
- **Implementation**: Calls `Notifications.sendInlineReply(notification, text)`

### 5. Rich Text Body

- **New `RichText` component**: A thin wrapper around Qt's `Text` element with `textFormat: Text.RichText`
- **Styling**: "Aporetic Sans" font family, `Colors.palette.text` color
- **Layout**: `maximumLineCount: 15`, `Text.WordWrap`, elide on overflow
- **Replaces** the current `StyledText` body in ToastCard
- **Supports**: Bold, italic, hyperlinks, and inline images (per `bodyMarkupSupported`, `bodyHyperlinksSupported`, `bodyImagesSupported` server capabilities)
- **Does not** use `FadeReduceAnimation` (that's specific to `StyledText` for dynamic text updates)

### 6. Progress Bar

- **Condition**: Shown when `notification.hints["value"]` is present (integer 0-100)
- **Layout**: Rendered below the body text. Rounded bar, ~8px height
- **Visual**: The filled portion uses the accent tint color with animated diagonal candy stripes moving rightward. The unfilled track uses a subtle background. Percentage shown at the right end
- **Reactive**: Updates when `hints` change (via `onHintsChanged` signal)
- **Timer suppression**:
  - While `hints["value"]` exists and is < 100: no timeout, timer ring shows hourglass icon
  - When `hints["value"]` reaches 100: normal timeout starts, timer ring shows draining animation
  - When `hints["value-type"]` signals "no progress ongoing": normal timeout starts immediately
  - When the notification is replaced without a `value` hint: normal timed notification behavior

### 7. Notification Replacement

- **Revival**: When a notification is replaced (same ID), reset `isDismissed` and `isExpired` to `false` so it re-appears as a toast
- **Comment**: Add an inline comment explaining this choice — notifications are replaced because the sender wants to update the user, so suppressed notifications should resurface. This can be revisited if it proves annoying

### 8. Click Behavior

- **Body area**: No action on click. Non-interactive
- **Close ring**: Click to dismiss
- **Action buttons**: Click to invoke action
- **Reply send**: Click to send reply
- This provides explicitness — the user always knows what will happen when they click something

### 9. Test Script

`scripts/test-notifications.sh` uses `notify-send` to exercise all features:

- Basic notification (summary + body)
- Critical urgency notification
- Notification with action buttons
- Notification with inline reply (via hints)
- Notification with progress bar (value hint, loop updating 0-100%)
- Notification with body markup (bold, italic, links)
- Notification with an image
- Notification that replaces a previous one (same app name / ID behavior)
- Long body text to test the 15-line max

## Service Changes (Notifications.qml)

- **`handleNewNotification()`**: On replacement, also reset `isDismissed` and `isExpired` to `false` (with explanatory comment)
- **Expiration timer**: Skip notifications that are in-progress (have `value` hint < 100) alongside existing skip for critical urgency
- **Helper function**: Add `isInProgress(notification)` that checks `hints["value"]` presence and value
- **Progress completion detection**: Monitor `hintsChanged` to detect when progress completes and start normal timeout behavior

## Component Changes Summary

### GlassIconButton.qml → GlassButton.qml

- Rename file and all references
- No functional changes — the `icon` property already accepts arbitrary text strings

### HoverBackdrop.qml

- Accept a `hovered` property (boolean)
- When hovered, increase the `baseColor` alpha slightly (e.g. from `Theme.backdropOpacity` to `Theme.backdropOpacity + 0.05`)
- Animated via existing `Behavior on baseColor`

### ToastCard.qml

- Replace `MouseArea` card body with `HoverHandler` for hover-only detection
- Replace X close button with timer ring component
- Add action buttons section (`Flow` of `GlassButton` pills)
- Add inline reply section (text input + send button)
- Add progress bar section
- Replace body `StyledText` with `RichText`
- Timer freeze logic expands to cover reply field focus and button presses

### New: RichText.qml

- Wraps `Text` with `textFormat: Text.RichText`
- Default font: "Aporetic Sans", `Colors.palette.text` color
- Exposes standard Text properties for customization

### New: scripts/test-notifications.sh

- Shell script exercising all notification features via `notify-send`
