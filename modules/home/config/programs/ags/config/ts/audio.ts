const audio = await Service.import('audio')

const volumeIndicator = Widget.Button({
	vexpand: false,
	on_clicked: () => audio.speaker.is_muted = !audio.speaker.is_muted,
	child: Widget.Icon().hook(audio.speaker, self => {
		const vol = audio.speaker.volume * 100;
		const icon = [
			[101, 'overamplified'],
			[67, 'high'],
			[34, 'medium'],
			[1, 'low'],
			[0, 'muted'],
		].find(([threshold]) => threshold <= vol)?.[1];

		self.icon = `audio-volume-${icon}-symbolic`;
		self.tooltip_text = `Volume ${Math.floor(vol)}%`;
	}),
})

export default {
	widgets: {
		volumeIndicator,
	},
}
