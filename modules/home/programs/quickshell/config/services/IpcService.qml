import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import "."

Item {
    id: root

    IpcHandler {
        target: "actions"

        function setBrightness(value: string) {
            const current = Brightness.percentage / 100.0;
            let target = 0;

            if (typeof value === "string") {
                if (value.startsWith("+") || value.startsWith("-")) {
                    target = current + parseFloat(value);
                } else {
                    target = parseFloat(value);
                }
            } else {
                target = value;
            }

            // Clamp and convert to 0-100
            const finalValue = Math.max(0, Math.min(100, Math.round(target * 100)));
            Brightness.setBrightness(finalValue);
        }

        function setVolume(value: string) {
            const sink = Pipewire.defaultAudioSink;
            if (!sink || !sink.audio) return;

            const current = sink.audio.volume;
            let target = 0;

            if (typeof value === "string") {
                if (value.startsWith("+") || value.startsWith("-")) {
                    target = current + parseFloat(value);
                } else {
                    target = parseFloat(value);
                }
            } else {
                target = value;
            }

            sink.audio.volume = Math.max(0, Math.min(1, target));
        }

        function setMuted(state: string) {
            const sink = Pipewire.defaultAudioSink;
            if (!sink || !sink.audio) return;

            if (state === "toggle") {
                sink.audio.muted = !sink.audio.muted;
            } else {
                sink.audio.muted = state === "true";
            }
        }
    }
}
