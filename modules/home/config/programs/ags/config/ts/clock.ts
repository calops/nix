const widget = Widget.Button({
	child: Widget.Label({
		label: Variable('', { poll: [1000, ['date', '+%H\n%M']] }).bind(),
	})
})

export default {
	widget,
}
