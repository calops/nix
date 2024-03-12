import Gtk from "types/@girs/gtk-3.0/gtk-3.0";

export function pillBox(children: Gtk.Widget[]) {
	return Widget.Box({
		vertical: true,
		className: "pill",
		children,
	});
}
