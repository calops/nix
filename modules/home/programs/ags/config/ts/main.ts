import "./style";
import audio from "./audio";
import clock from "./clock";
import system from "./system";

const mainBar = Widget.CenterBox({
	name: "main",
	vertical: true,
	startWidget: Widget.Box({
		vertical: true,
		children: [
			// notifications.widget,
			// clipboard.widget,
			// tray.widget
		],
	}),
	centerWidget: Widget.Box({
		vertical: true,
		children: [
			// hyprland.widget,
		],
	}),
	endWidget: Widget.Box({
		vertical: true,
		children: [
			// audio.widgets.nowPlaying,
			audio.widgets.volumeIndicator,
			system.widget,
			clock.widget,
		],
	}),
});

function Bar(monitor = 0) {
	return Widget.Window({
		monitor,
		name: `bar${monitor}`,
		anchor: ["left", "top", "bottom"],
		child: mainBar,
		exclusivity: "exclusive",
	});
}

console.log("Instantiating bar");
App.config({
	windows: [Bar(0)],
});
