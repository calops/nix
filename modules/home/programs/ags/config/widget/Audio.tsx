import AstalWp from "gi://AstalWp"
import { bind } from "astal"
import { Gtk, Widget } from "astal/gtk3"

const audio = AstalWp.get_default()?.audio

export default function Audio() {
	const speaker = audio?.defaultSpeaker!

	const revealer = <revealer transitionType={Gtk.RevealerTransitionType.SLIDE_UP}>
		<box className="sliderBox" halign={Gtk.Align.CENTER}>
			<slider
				vertical
				inverted
				onDragged={({ value }) => speaker.volume = value}
				value={bind(speaker, "volume")}
			/>
		</box>
	</revealer> as Widget.Revealer

	const audioBox = <box className="audio" vertical>
		{revealer}
		<icon icon={bind(speaker, "volumeIcon")} />
	</box> as Widget.Box

	return <eventbox
		onHover={() => {
			audioBox.set_state_flags(Gtk.StateFlags.FOCUSED, true)
			return revealer.set_reveal_child(true)
		}}
		onHoverLost={() => {
			audioBox.set_state_flags(Gtk.StateFlags.NORMAL, true)
			return revealer.set_reveal_child(false)
		}}
		onScroll={((_, event) => speaker.volume += event.delta_y * -0.05)}
		onClick={() => speaker.mute = !speaker.mute}
	>
		{audioBox}
	</eventbox >
}
