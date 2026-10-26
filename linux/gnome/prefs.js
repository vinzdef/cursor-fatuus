import Adw from 'gi://Adw';
import Gdk from 'gi://Gdk';
import Gio from 'gi://Gio';
import GLib from 'gi://GLib';
import Gtk from 'gi://Gtk';

import {ExtensionPreferences} from 'resource:///org/gnome/Shell/Extensions/js/extensions/prefs.js';

export default class CursorFatuusPreferences extends ExtensionPreferences {
    fillPreferencesWindow(window) {
        const settings = this.getSettings();
        const page = new Adw.PreferencesPage();

        const general = new Adw.PreferencesGroup();
        const enabled = new Adw.SwitchRow({title: 'Enabled'});
        settings.bind('enabled', enabled, 'active', Gio.SettingsBindFlags.DEFAULT);
        general.add(enabled);
        page.add(general);

        const look = new Adw.PreferencesGroup();
        look.add(colorRow(settings));
        look.add(sliderRow(settings, 'opacity', 'Opacity', 0, 1));
        look.add(sliderRow(settings, 'radius', 'Radius', 1, 300));
        look.add(sliderRow(settings, 'softness', 'Softness', 0, 1));
        page.add(look);

        const effects = new Adw.PreferencesGroup();
        effects.add(sliderRow(settings, 'blur-radius', 'Blur', 0, 10));
        const invert = new Adw.SwitchRow({title: 'Invert'});
        settings.bind('invert', invert, 'active', Gio.SettingsBindFlags.DEFAULT);
        effects.add(invert);
        page.add(effects);

        window.add(page);
    }
}

function sliderRow(settings, key, title, lower, upper) {
    const adjustment = new Gtk.Adjustment({lower, upper, step_increment: (upper - lower) / 100});
    settings.bind(key, adjustment, 'value', Gio.SettingsBindFlags.DEFAULT);
    const scale = new Gtk.Scale({adjustment, draw_value: false, hexpand: true, width_request: 200, valign: Gtk.Align.CENTER});
    const row = new Adw.ActionRow({title});
    row.add_suffix(scale);
    return row;
}

// Switch turns the tint off by storing no color; the button keeps the last one.
function colorRow(settings) {
    const button = new Gtk.ColorDialogButton({dialog: new Gtk.ColorDialog({with_alpha: false}), valign: Gtk.Align.CENTER});
    const toggle = new Gtk.Switch({valign: Gtk.Align.CENTER});
    const row = new Adw.ActionRow({title: 'Color', activatable_widget: toggle});
    row.add_suffix(button);
    row.add_suffix(toggle);

    const color = settings.get_value('color').deepUnpack();
    toggle.active = color.length === 3;
    if (toggle.active)
        button.rgba = new Gdk.RGBA({red: color[0], green: color[1], blue: color[2], alpha: 1});
    button.sensitive = toggle.active;

    const save = () => {
        const {red, green, blue} = button.rgba;
        button.sensitive = toggle.active;
        settings.set_value('color', new GLib.Variant('ad', toggle.active ? [red, green, blue] : []));
    };
    toggle.connect('notify::active', save);
    button.connect('notify::rgba', save);
    return row;
}
