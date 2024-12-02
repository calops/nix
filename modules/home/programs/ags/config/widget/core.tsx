import { Gtk } from "astal/gtk3";

export function CenterBox(props: any) {
	return <box halign={Gtk.Align.CENTER} {...props} />
}
