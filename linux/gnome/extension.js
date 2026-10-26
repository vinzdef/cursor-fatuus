import {Extension} from 'resource:///org/gnome/shell/extensions/extension.js';
import * as Main from 'resource:///org/gnome/shell/ui/main.js';

import {Halo} from './halo.js';
import {Indicator} from './indicator.js';

export default class CursorFatuusExtension extends Extension {
    enable() {
        this._settings = this.getSettings();
        this._settingsId = this._settings.connect('changed', () => this._apply());
        this._tracker = global.backend.get_cursor_tracker();
        this._indicator = new Indicator(this, this._settings);
        Main.panel.statusArea.quickSettings.addExternalIndicator(this._indicator);
        this._apply();
    }

    disable() {
        this._settings.disconnect(this._settingsId);
        this._stop();
        this._indicator.destroy();
        this._indicator = null;
        this._tracker = null;
        this._settings = null;
    }

    _apply() {
        const settings = this._settings;
        const color = settings.get_value('color').deepUnpack();
        const options = {
            color: color.length === 3 ? color : null,
            opacity: settings.get_double('opacity'),
            blurRadius: settings.get_double('blur-radius'),
            invert: settings.get_boolean('invert'),
            radius: settings.get_double('radius'),
            softness: settings.get_double('softness'),
        };
        if (!settings.get_boolean('enabled') || options.opacity <= 0 ||
            !(options.color || options.blurRadius > 0 || options.invert)) {
            this._stop();
            return;
        }
        if (!this._halo)
            this._start();
        this._halo.configure(options);
        this._follow();
    }

    _start() {
        this._halo = new Halo();
        // Fires only when the pointer moves, so a still pointer costs nothing.
        this._trackerId = this._tracker.connect('position-invalidated', () => this._follow());
    }

    _stop() {
        if (!this._halo)
            return;
        this._tracker.disconnect(this._trackerId);
        this._halo.destroy();
        this._halo = null;
    }

    _follow() {
        const [x, y] = global.get_pointer();
        this._halo.moveTo(x, y);
    }
}
