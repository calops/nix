#!/usr/bin/env bash
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
