import Gio from 'gi://Gio';
import GObject from 'gi://GObject';

import {QuickMenuToggle, SystemIndicator} from 'resource:///org/gnome/shell/ui/quickSettings.js';

const FatuusToggle = GObject.registerClass(
class FatuusToggle extends QuickMenuToggle {
    constructor(extension, settings) {
        const gicon = Gio.icon_new_for_string(`${extension.path}/icons/cursor-fatuus-symbolic.svg`);
        super({title: 'Cursor Fatuus', gicon, toggleMode: true});
        settings.bind('enabled', this, 'checked', Gio.SettingsBindFlags.DEFAULT);

        this.menu.setHeader(gicon, 'Cursor Fatuus');
        this.menu.addAction('Settings', () => extension.openPreferences());
    }
});

// Quick Settings toggle; the GNOME counterpart of the macOS menu bar item.
export const Indicator = GObject.registerClass(
class Indicator extends SystemIndicator {
    constructor(extension, settings) {
        super();
        this.quickSettingsItems.push(new FatuusToggle(extension, settings));
    }

    destroy() {
        this.quickSettingsItems.forEach(item => item.destroy());
        super.destroy();
    }
});
