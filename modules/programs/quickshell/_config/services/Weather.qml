pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real temp: 0
    property int humidity: 0
    property string icon: ""
    property string condition: "Loading..."
    property int weatherCode: 0

    // Paris coordinates
    readonly property real lat: 48.8566
    readonly property real lon: 2.3522

    Component.onCompleted: refresh()

    Timer {
        interval: 1800000 // 30 minutes
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    function refresh() {
        fetchProcess.running = true
    }

    Process {
        id: fetchProcess
        command: [
            "curl", "-s", 
            `https://api.open-meteo.com/v1/forecast?latitude=${root.lat}&longitude=${root.lon}&current=temperature_2m,relative_humidity_2m,weather_code&timezone=auto`
        ]
        stdout: SplitParser {
            onRead: data => {
                try {
                    const json = JSON.parse(data);
                    const current = json.current;
                    root.temp = current.temperature_2m;
                    root.humidity = current.relative_humidity_2m;
                    root.weatherCode = current.weather_code;
                    root.icon = _mapCodeToIcon(root.weatherCode);
                    root.condition = _mapCodeToCondition(root.weatherCode);
                } catch (e) {
                    console.error("Weather Service: Failed to parse JSON", e);
                }
            }
        }
    }

    function _mapCodeToIcon(code) {
        // Font Awesome Nerd Font icons
        if (code === 0) return ""; // Sun (uf185)
        if (code >= 1 && code <= 3) return ""; // Cloud (uf0c2)
        if (code === 45 || code === 48) return ""; // Smog/Fog (uf75f)
        if (code >= 51 && code <= 65) return ""; // Cloud-Rain (uf0e9)
        if (code >= 71 && code <= 77) return ""; // Snowflake (uf2dc)
        if (code >= 80 && code <= 82) return ""; // Cloud-Rain
        if (code >= 85 && code <= 86) return ""; // Snowflake
        if (code >= 95 && code <= 99) return ""; // Bolt/Thunder (uf0e7)
        return "";
    }

    function _mapCodeToCondition(code) {
        if (code === 0) return "Clear sky";
        if (code === 1) return "Mainly clear";
        if (code === 2) return "Partly cloudy";
        if (code === 3) return "Overcast";
        if (code === 45) return "Fog";
        if (code === 48) return "Depositing rime fog";
        if (code >= 51 && code <= 55) return "Drizzle";
        if (code >= 61 && code <= 65) return "Rain";
        if (code >= 71 && code <= 75) return "Snow fall";
        if (code === 77) return "Snow grains";
        if (code >= 80 && code <= 82) return "Rain showers";
        if (code >= 85 && code <= 86) return "Snow showers";
        if (code >= 95 && code <= 99) return "Thunderstorm";
        return "Unknown";
    }
}
