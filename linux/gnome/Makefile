UUID  := cursor-fatuus@vincent.codes
BUILD := build
ZIP   := $(BUILD)/$(UUID).shell-extension.zip

.PHONY: all pack install enable nested clean

all: pack

pack:
	@mkdir -p $(BUILD)
	gnome-extensions pack --force --out-dir=$(BUILD) --extra-source=halo.js --extra-source=indicator.js --extra-source=icons .

# Wayland sessions only pick up a newly installed extension after logging out and back in.
install: pack enable
	gnome-extensions install --force $(ZIP)

# Adds the extension to the enabled list directly: `gnome-extensions enable` asks the
# running shell, which reports a newly installed extension as missing until the next login.
enable:
	@gsettings get org.gnome.shell enabled-extensions | grep -q "'$(UUID)'" || \
	gsettings set org.gnome.shell enabled-extensions \
		"$$(gsettings get org.gnome.shell enabled-extensions | sed -e 's/^@as //' -e "s/]$$/, '$(UUID)']/" -e 's/^\[, /[/')"

# A GNOME Shell in a window, to try changes without logging out. GNOME 49 replaces --nested with --devkit.
nested: install
	dbus-run-session -- gnome-shell --nested --wayland

clean:
	/bin/rm -rf $(BUILD)
