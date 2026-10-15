BUILD := build
APP   := $(BUILD)/Cursor Fatuus.app

.PHONY: all app run clean

all: app

app:
	swift build -c release
	@mkdir -p "$(APP)/Contents/MacOS" "$(APP)/Contents/Resources"
	/bin/cp -f "$$(swift build -c release --show-bin-path)/CursorFatuus" "$(APP)/Contents/MacOS/CursorFatuus"
	/bin/cp -f Resources/Info.plist "$(APP)/Contents/Info.plist"
	/bin/cp -f Resources/AppIcon.icns "$(APP)/Contents/Resources/AppIcon.icns"
	codesign --force --sign - "$(APP)"

run: app
	open "$(APP)"

clean:
	/bin/rm -rf $(BUILD) .build
