# Notification Toast Features Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add interactive features to notification toasts — timer ring, action buttons, inline reply, progress bar, rich text body, and hover feedback.

**Architecture:** Enhance the existing ToastCard component in-place, Create new RichText component for rich body rendering, rename GlassIconButton to GlassButton, modify HoverBackdrop to support hover brightness, and update the notification service for progress-aware timer logic. A test script exercises all features end-to-end.

**Tech Stack:** QML (Qt 6), Quickshell notification service, freedesktop.org notification spec hints

---

### Task 1: Rename GlassIconButton to GlassButton

**Files:**
- Rename: `config/components/GlassIconButton.qml` → `config/components/GlassButton.qml`
- Modify: `config/widgets/MprisWidget.qml:263,291` (3 references)
- Modify: `config/widgets/Battery.qml:168` (1 reference)

- [ ] **Step 1: Rename the file**

```bash
mv config/components/GlassIconButton.qml config/components/GlassButton.qml
```

- [ ] **Step 2: Update all import references**

In `config/widgets/MprisWidget.qml`, change all instances of `GlassIconButton` to `GlassButton` (lines 263, 274, 291).

In `config/widgets/Battery.qml`, change `GlassIconButton` to `GlassButton` (line 168).

- [ ] **Step 3: Commit**

```bash
git add config/components/GlassButton.qml config/widgets/MprisWidget.qml config/widgets/Battery.qml
git commit -m "refactor: rename GlassIconButton to GlassButton"
```

---

### Task 2: Create RichText component

**Files:**
- Create: `config/components/RichText.qml`

- [ ] **Step 1: Create the RichText component**

```qml
// config/components/RichText.qml
import QtQuick
import "../services"

Text {
    id: root

    property string fontFamily: "Aporetic Sans"
    property int fontSize: 13
    property color textColor: Colors.palette.text

    font.family: root.fontFamily
    font.pixelSize: root.fontSize
    color: root.textColor
    textFormat: Text.RichText
    wrapMode: Text.WordWrap
}
```

- [ ] **Step 2: Commit**

```bash
git add config/components/RichText.qml
git commit -m "feat: add RichText component for notification body rendering"
```

---

### Task 3: Add hover brightness support to HoverBackdrop

**Files:**
- Modify: `config/components/HoverBackdrop.qml`

Add a `hovered` property to HoverBackdrop that increases the backdrop alpha when true. The baseColor is already aliased and controlled externally, so the hover brightness is handled by the consumer passing a higher-alpha baseColor when hovered.

No changes needed to HoverBackdrop itself — the ToastCard will pass a brighter baseColor to the HoverBackdrop based on its own hover state. This task is a no-op.

---

### Task 4: Add progress and timer suppression logic to Notifications service

**Files:**
- Modify: `config/services/Notifications.qml`

- [ ] **Step 1: Add `isInProgress` helper function**

Add after the `sendInlineReply` function (after line 221):

```qml
function isInProgress(hints) {
    if (!hints)
        return false;
    const value = hints["value"];
    if (value === undefined || value === null)
        return false;
    return value < 100;
}
```

- [ ] **Step 2: Update replacement logic to revive dismissed/expired notifications**

In `handleNewNotification()`, add `isDismissed` and `isExpired` resets to the replacement block (after line 114, before the timeout calculation):

```qml
notificationModel.setProperty(i, "isDismissed", false);
notificationModel.setProperty(i, "isExpired", false);
```

Add a comment above these lines:

```qml
// Revive dismissed/expired on replacement: the sender replaces a notification
// because they want the update the user. Revisit if this proves annoying.
```

- [ ] **Step 3: Update expiration timer to skip in-progress notifications**

In the `expirationCheckTimer.onTriggered` (after the critical urgency check at line 83), add:

```qml
if (root.isInProgress(notification.hints))
    continue;
```

- [ ] **Step 4: Commit**

```bash
git add config/services/Notifications.qml
git commit -m "feat: add progress-aware timer logic and notification service"
```

---

### Task 5: Create TimerRing component

**Files:**
- Create: `config/components/TimerRing.qml`

- [ ] **Step 1: Create the TimerRing component**

```qml
// config/components/TimerRing.qml
import QtQuick
import "../services"

Item {
    id: root

    property real progress: 1.0
    property bool isInProgress: false
    property bool isCritical: false
    property color ringColor: Colors.palette.subtext0
    property color trackColor: Colors.palette.surface2

    readonly property int size: 22

    implicitWidth: size
    implicitHeight: size

    signal dismissed()

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            var centerX = width / 2;
            var centerY = height / 2;
            var radius = Math.max(1, Math.min(width, height) / 2 - 2);
            var lineWidth = 2.5;

            // Background track
            ctx.beginPath();
            ctx.arc(centerX, centerY, radius, 0, Math.PI * 2, false);
            ctx.strokeStyle = Qt.rgba(root.trackColor.r, root.trackColor.g, root.trackColor.b, 0.4);
            ctx.lineWidth = lineWidth;
            ctx.stroke();

            if (!root.isCritical && !root.isInProgress) {
                // Timer arc: counterclockwise drain from 12 o'clock
                var startAngle = -Math.PI / 2;
                var endAngle = startAngle + (Math.PI * 2 * root.progress);
                var arcColor = root.ringColor;

                ctx.beginPath();
                ctx.arc(centerX, centerY, radius, startAngle, endAngle, false);
                ctx.strokeStyle = Qt.rgba(arcColor.r, arcColor.g, arcColor.b, 1.0);
                ctx.lineWidth = lineWidth;
                ctx.lineCap = "round";
                ctx.stroke();
            }

            // Cross icon (normal + critical) or hourglass (in-progress)
            ctx.fillStyle = Qt.rgba(root.ringColor.r, root.ringColor.g, root.ringColor.b, 1.0);
            ctx.font = "bold 10px sans-serif";
            ctx.textAlign = "center";
            ctx.textBaseline = "middle";

            if (root.isInProgress) {
                ctx.fillText("\u23F3", centerX, centerY);
            } else if (root.isCritical) {
                ctx.fillText("!", centerX, centerY);
            } else {
                ctx.fillText("\u00D7", centerX, centerY);
            }
        }

        onProgressChanged: requestPaint()
        onIsInProgressChanged: requestPaint()
        onIsCriticalChanged: requestPaint()
        onRingColorChanged: requestPaint()
    }

    MouseArea {
        id: ringMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.dismissed()
        cursorShape: Qt.PointingHandCursor
    }

    HoverHandler {
        id: ringHover
        onHoveredChanged: canvas.requestPaint()
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add config/components/TimerRing.qml
git commit -m"feat: add TimerRing component for notification timer indicator"
```

---

### Task 6: Create NotificationProgressBar component

**Files:**
- Create: `config/components/NotificationProgressBar.qml`

Note: The existing `ProgressBar.qml` is a draggable slider for MPRIS/volume. We need a separate, simpler progress indicator.

- [ ] **Step 1: Create the notification progress bar component**

```qml
// config/components/NotificationProgressBar.qml
import QtQuick
import "../services"

Item {
    id: root

    property real value: 0.0
    property color fillColor: Theme.backdropTint
    readonly property int barHeight: 8

    implicitWidth: parent.width
    implicitHeight: barHeight + 16

    Column {
        id: column
        width: root.width
        spacing: 4

        Rectangle {
            width: root.width
            height: root.barHeight
            radius: root.barHeight / 2
            color: Colors.alpha("#ffffff", 0.08)

            Rectangle {
                id: fill
                width: Math.max(root.barHeight, root.width * (root.value / 100))
                height: root.barHeight
                radius: root.barHeight / 2
                clip: true

                Rectangle {
                    anchors.fill: parent
                    radius: root.barHeight / 2
                    color: root.fillColor

                    Canvas {
                        id: stripeCanvas
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.reset();
                            ctx.fillStyle = Qt.rgba(root.fillColor.r, root.fillColor.g, root.fillColor.b, 1.0);
                            ctx.fillRect(0, 0, width, height);

                            var lighter = Qt.rgba(
                                Math.min(1.0, root.fillColor.r + 0.15),
                                Math.min(1.0, root.fillColor.g + 0.15),
                                Math.min(1.0, root.fillColor.b + 0.15),
                                0.6
                            );
                            ctx.fillStyle = lighter;

                            var stripeWidth = 12;
                            var offset = (Date.now() / 80) % (stripeWidth * 2);
                            ctx.save();
                            ctx.beginPath();
                            for (var x = -stripeWidth * 2 + offset - width; x < width + stripeWidth * 2; x += stripeWidth) {
                                ctx.moveTo(x, 0);
                                ctx.lineTo(x + stripeWidth / 2, height);
                                ctx.lineTo(x + stripeWidth, 0);
                            }
                            ctx.fill();
                            ctx.restore();
                        }

                        Timer {
                            id: stripeAnimTimer
                            interval: 16
                            repeat: true
                            running: root.value > 0 && root.value < 100
                            onTriggered: stripeCanvas.requestPaint()
                        }
                    }
                }
            }
        }

        Row {
            width: root.width
            layoutDirection: Qt.RightToLeft

            StyledText {
                font.pixelSize: 11
                color: root.fillColor
                text: Math.round(root.value) + "%"
            }
        }
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add config/components/NotificationProgressBar.qml
git commit -m"feat: add NotificationProgressBar with candy stripe animation"
```

---

### Task 7: Rewrite ToastCard with all new features

**Files:**
- Modify: `config/components/ToastCard.qml`

This is the main task. The entire ToastCard gets restructured. The key changes:
1. Replace `MouseArea` body click handler with `HoverHandler` for hover-only detection
2. Replace X close button with `TimerRing` component
3. Replace body `StyledText` with `RichText`
4. Add action buttons section (`Flow` of `GlassButton` pills)
5. Add inline reply section (text input + send button with "Sent" confirmation)
6. Add `NotificationProgressBar` section
7. Hover backdrop brightens on hover
8. Timer freeze extends to cover reply focus

- [ ] **Step 1: Replace the entire ToastCard.qml**

```qml
// config/components/ToastCard.qml
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications
import "../services"

Item {
    id: root

    property var entry: null
    property bool isEntering: true
    property bool isExiting: false
    property real targetY: 0

    readonly property var notification: entry?.notification ?? null
    readonly property int cardWidth: 320
    readonly property int padding: 12

    implicitWidth: cardWidth
    implicitHeight: contentColumn.height + (padding * 2)
    opacity: 0.0
    x: cardWidth + 50
    y: targetY

    signal exited(string notificationId)

    readonly property color urgencyTint: {
        if (!notification)
            return Theme.backdropTint;
        if (notification.urgency === NotificationUrgency.Critical)
            return Colors.palette.red;
        return Theme.backdropTint;
    }

    readonly property bool hasProgress: {
        if (!notification || !notification.hints)
            return false;
        var v = notification.hints["value"];
        return v !== undefined && v !== null;
    }

    readonly property real progressValue: {
        if (!hasProgress)
            return 0;
        var v = notification.hints["value"];
        return v !== undefined ? v : 0;
    }

    readonly property bool isProgressDone: {
        if (!hasProgress)
            return false;
        return progressValue >= 100;
    }

    property bool replySent: false

    readonly property real timerProgress: {
        if (!entry)
            return 1.0;
        if (notification && notification.urgency === NotificationUrgency.Critical)
            return 1.0;
        if (hasProgress && !isProgressDone)
            return 1.0;

        var elapsed = entry.elapsedDisplayTime;
        if (entry.displayStartTime > 0)
            elapsed += Date.now() - entry.displayStartTime;
        var timeoutMs = entry.expireTimeout * 1000;
        if (timeoutMs <= 0)
            return 1.0;
        return Math.max(0, 1.0 - (elapsed / timeoutMs));
    }

    ParallelAnimation {
        id: enterAnimation
        running: root.isEntering && !root.isExiting

        NumberAnimation {
            target: root
            property: "opacity"
            to: 1.0
            duration: Theme.animationDuration
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            target: root
            property: "x"
            to: 0
            duration: Theme.animationDuration
            easing.type: Easing.OutQuad
        }

        onFinished: root.isEntering = false
    }

    ParallelAnimation {
        id: exitAnimation
        running: root.isExiting

        NumberAnimation {
            target: root
            property: "opacity"
            to: 0.0
            duration: Theme.animationDurationOut
            easing.type: Easing.InQuad
        }
        NumberAnimation {
            target: root
            property: "x"
            to: root.cardWidth + 50
            duration: Theme.animationDurationOut
            easing.type: Easing.InQuad
        }

        onFinished: {
            root.exited(root.entry?.notificationId ?? "");
            root.destroy();
        }
    }

    function startExit() {
        if (!root.isExiting) {
            root.isExiting = true;
        }
    }

    Behavior on y {
        enabled: !root.isEntering && !root.isExiting
        NumberAnimation {
            duration: Theme.animationDuration
            easing.type: Easing.OutQuad
        }
    }

    HoverBackdrop {
        id: backdrop
        anchors.fill: parent
        anchors.margins: -6
        radius: 12
        opacity: 1.0
        baseColor: Colors.alpha(root.urgencyTint, cardHoverHandler.hovered ? Theme.backdropOpacity + 0.05 : Theme.backdropOpacity)
    }

    HoverHandler {
        id: cardHoverHandler
        onHoveredChanged: {
            Notifications.setTimerFrozen(hovered);
        }
    }

    ColumnLayout {
        id: contentColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: padding
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Image {
                id: appIcon
                source: root.notification?.appIcon ?? ""
                sourceSize: Qt.size(20, 20)
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                fillMode: Image.PreserveAspectFit
                visible: source !== ""

                Image {
                    anchors.fill: parent
                    source: "image://icon/application-x-executable"
                    sourceSize: Qt.size(20, 20)
                    visible: appIcon.source === "" || appIcon.status !== Image.Ready
                }
            }

            StyledText {
                Layout.fillWidth: true
                text: root.notification?.appName ?? "Unknown"
                font.pixelSize: 12
                font.bold: true
                color: Colors.palette.subtext1
                elide: Text.ElideRight
            }

            TimerRing {
                progress: root.timerProgress
                isInProgress: root.hasProgress && !root.isProgressDone
                isCritical: root.notification && root.notification.urgency === NotificationUrgency.Critical
                ringColor: root.urgencyTint
                onDismissed: Notifications.dismissById(root.entry?.notificationId ?? "")
            }
        }

        StyledText {
            Layout.fillWidth: true
            text: root.notification?.summary ?? ""
            font.pixelSize: 14
            font.bold: true
            color: Colors.palette.text
            elide: Text.ElideRight
            visible: text !== ""
        }

        RichText {
            Layout.fillWidth: true
            text: root.notification?.body ?? ""
            fontSize: 13
            maximumLineCount: 15
            elide: Text.ElideRight
            visible: text !== ""
        }

        Image {
            id: contentImage
            Layout.fillWidth: true
            Layout.preferredHeight: status === Image.Ready ? Math.min(200, implicitHeight) : 0
            Layout.maximumHeight: 200
            source: root.notification?.image ?? ""
            sourceSize: Qt.size(contentColumn.width, contentColumn.width)
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            visible: source !== "" && status !== Image.Null
        }

        NotificationProgressBar {
            Layout.fillWidth: true
            value: root.progressValue
            fillColor: root.urgencyTint
            visible: root.hasProgress
        }

        Flow {
            Layout.fillWidth: true
            spacing: 6
            visible: root.notification && root.notification.actions && root.notification.actions.length > 0

            Repeater {
                model: (root.notification?.actions ?? []).length
                delegate: GlassButton {
                    required property int index
                    property var action: root.notification.actions[index]
                    icon: action.text
                    iconSize: 12
                    tintColor: Colors.palette.text
                    normalAlpha: 0.08
                    hoveredAlpha: 0.18
                    Layout.fillWidth: false
                    Layout.preferredHeight: 28
                    onClicked: Notifications.invokeAction(root.notification, index)
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: replyArea.height
            visible: root.notification && root.notification.hasInlineReply && !root.replySent

            clip: false

            Row {
                id: replyArea
                width: parent.width
                spacing: 6

                Rectangle {
                    id: replyInput
                    width: parent.width - sendButton.width - parent.spacing
                    height: 28
                    radius: 6
                    color: Colors.alpha("#ffffff", 0.06)
                    border.width: 1
                    border.color: replyInputMouseArea.containsMouse ? Colors.alpha("#ffffff", 0.15) : Colors.alpha("#ffffff", 0.06)

                    StyledText {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        verticalAlignment: Text.AlignVCenter
                        text: replyField.text === "" ? (root.notification?.inlineReplyPlaceholder || "Type a reply...") : ""
                        font.pixelSize: 12
                        color: Colors.palette.surface2
                        elide: Text.ElideRight
                        visible: replyField.text === ""
                    }

                    TextInput {
                        id: replyField
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        verticalAlignment: Text.AlignVCenter
                        font.family: "Aporetic Sans"
                        font.pixelSize: 12
                        color: Colors.palette.text
                        clip: true
                        onActiveFocusChanged: Notifications.setTimerFrozen(activeFocus)
                    }

                    MouseArea {
                        id: replyInputMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: replyField.forceActiveFocus()
                    }
                }

                GlassButton {
                    id: sendButton
                    icon: "Send"
                    iconSize: 12
                    tintColor: Colors.palette.blue
                    normalAlpha: 0.15
                    hoveredAlpha: 0.30
                    Layout.fillWidth: false
                    Layout.preferredHeight: 28
                    onClicked: {
                        if (replyField.text.trim() !== "") {
                            Notifications.sendInlineReply(root.notification, replyField.text.trim());
                            root.replySent = true;
                        }
                    }
                }
            }
        }

        StyledText {
            Layout.fillWidth: true
            text: "Sent"
            font.pixelSize: 12
            color: Colors.palette.green
            visible: root.replySent
        }
    }

    Connections {
        target: root.entry
        function onIsTransientChanged() {
            if (!root.entry?.isTransient && !root.isExiting) {
                root.startExit();
            }
        }
    }

    Connections {
        target: root.notification
        function onClosed() {
            root.startExit();
        }
    }

    Timer {
        id: progressTimer
        interval: 100
        repeat: true
        running: root.isDisplayed
        onTriggered: root.timerProgressChanged()
    }

    Component.onDestruction: {
        if (cardHoverHandler.hovered) {
            Notifications.setTimerFrozen(false);
        }
    }

    Component.onCompleted: {
        console.log("[ToastCard] Created for:", root.notification?.summary ?? "unknown");
    }
}
```

- [ ] **Step 2: Commit**

```bash
git add config/components/ToastCard.qml
git commit -m"feat: enhance ToastCard with timer ring, actions, reply, progress bar, rich text"
```

---

### Task 8: Create test notification script

**Files:**
- Create: `scripts/test-notifications.sh`

- [ ] **Step 1: Create the test script**

```bash
#!/usr/bin/env bash
# scripts/test-notifications.sh
set -euo pipefail

echo "=== Basic notification ==="
notify-send "Test App" "This is a basic notification with a summary and body."

sleep 1

echo "=== Critical notification ==="
notify-send -u critical "Battery Monitor" "Battery critically low (5%)!\nConnect a charger immediately."
sleep 1

echo "=== Notification with actions ==="
notify-send --action="open=Open" --action="mark-read=Mark as Read" --action="archive=Archive" \
    "Email Client" "You have received a new email from Alice.\nSubject: Meeting tomorrow"
sleep 1

echo "=== Notification with body markup ==="
notify-send "Chat App" "This is <b>bold</b>, <i>italic</i>, and <a href='https://example.com'>a link</a>."
sleep 1

echo "=== Notification with image ==="
notify-send --icon="application-x-executable" "Image Test" "This notification has an app icon."
sleep 1

echo "=== Long body notification ==="
notify-send "Long Text" "$(printf '%s\n' {1..20}.This is a long notification body line to test the maximum line count of fifteen lines.)"
sleep 1

echo "=== Progress notification (0-100%) ==="
NOTIF_ID="progress-test-$$"
for i in $(seq 0 5 100); do
    notify-send -h string:sync:progress-test -h int:value:$i -h string:value-type:ongoing \
        "Package Manager" "Downloading updates... ${i}%"
    sleep 0.15
done
notify-send -h string:sync:progress-test \
    "Package Manager" "All updates installed successfully."
sleep 1

echo "=== Inline reply notification ==="
notify-send --action="inline-reply=Reply" \
    -h string:x-kde-reply-placeholder-text="Type a reply..." \
    "Messenger" "New message from Bob:\nHey, are you free this weekend?"
sleep 1

echo "=== Notification replacement ==="
notify-send -h string:x-kde-sync:replace-test "Replace Test" "First version of the notification."
sleep 2
notify-send -h string:x-kde-sync:replace-test "Replace Test" "Second version — replaced!"
sleep 2
notify-send -h string:x-kde-sync:replace-test "Replace Test" "Third version — replaced again!"

echo ""
echo "All test notifications sent."
```

- [ ] **Step 2: Make executable and commit**

```bash
chmod +x scripts/test-notifications.sh
git add scripts/test-notifications.sh
git commit -m "feat: add test notification script for all features"
```

---

## Self-Review

**1. Spec coverage:**
- Timer ring: Task 5 + Task 7 ✓
- Critical indicator: Task 5 (isCritical) + Task 7 ✓
- In-progress indicator: Task 5 (isInProgress) + Task 7 ✓
- Hover feedback: Task 7 (HoverHandler + backdrop brightness) ✓
- Action buttons: Task 7 (Flow + GlassButton Repeater) ✓
- Inline reply: Task 7 (TextInput + send + "Sent") ✓
- Rich text body: Task 2 (RichText) + Task 7 ✓
- Progress bar: Task 6 (NotificationProgressBar) + Task 7 ✓
- Notification replacement revival: Task 4 ✓
- Timer suppression for progress: Task 4 + Task 7 ✓
- Test script: Task 8 ✓
- GlassButton rename: Task 1 ✓

**2. Placeholder scan:** No TBDs, TODOs, or vague instructions.

**3. Type consistency:**
- `GlassButton.icon` property used for action text labels ✓
- `TimerRing.progress` is `real` (0-1), `NotificationProgressBar.value` is `real` (0-100) ✓
- `Notifications.invokeAction(notification, index)` matches existing API ✓
- `Notifications.sendInlineReply(notification, text)` matches existing API ✓
- `Notifications.isInProgress(hints)` returns `bool`, used in expiration timer ✓
