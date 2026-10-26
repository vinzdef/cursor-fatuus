UUID  := cursor-fatuus@vincent.codes
BUILD := build
ZIP   := $(BUILD)/$(UUID).shell-extension.zip

.PHONY: all pack install nested clean

all: pack

pack:
	@mkdir -p $(BUILD)
	gnome-extensions pack --force --out-dir=$(BUILD) --extra-source=halo.js --extra-source=indicator.js --extra-source=icons .

# Wayland sessions only pick up a newly installed extension after logging out and back in.
install: pack
	gnome-extensions install --force $(ZIP)
	gnome-extensions enable $(UUID)

# A GNOME Shell in a window, to try changes without logging out. GNOME 49 replaces --nested with --devkit.
nested: install
	dbus-run-session -- gnome-shell --nested --wayland

clean:
	/bin/rm -rf $(BUILD)
