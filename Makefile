BUILD   := build
APP     := $(BUILD)/Cursor Fatuus.app
DMG     := $(BUILD)/CursorFatuus.dmg
# Release builds pass ARCHS="--arch arm64 --arch x86_64" for a universal app.
ARCHS   ?=
SWIFT   := swift build -c release $(ARCHS)
# Stamped into Info.plist when set, e.g. VERSION=1.0.0.
VERSION ?=

.PHONY: all app dmg run clean

all: app

app:
	$(SWIFT)
	@mkdir -p "$(APP)/Contents/MacOS" "$(APP)/Contents/Resources"
	/bin/cp -f "$$($(SWIFT) --show-bin-path)/CursorFatuus" "$(APP)/Contents/MacOS/CursorFatuus"
	/bin/cp -f Resources/Info.plist "$(APP)/Contents/Info.plist"
	/bin/cp -f Resources/AppIcon.icns "$(APP)/Contents/Resources/AppIcon.icns"
ifneq ($(VERSION),)
	plutil -replace CFBundleShortVersionString -string "$(VERSION)" "$(APP)/Contents/Info.plist"
	plutil -replace CFBundleVersion -string "$(VERSION)" "$(APP)/Contents/Info.plist"
endif
	codesign --force --sign - "$(APP)"

dmg: app
	/bin/rm -rf $(BUILD)/dmg $(DMG)
	@mkdir -p $(BUILD)/dmg
	/bin/cp -R "$(APP)" $(BUILD)/dmg/
	ln -s /Applications $(BUILD)/dmg/Applications
	hdiutil create -volname "Cursor Fatuus" -srcfolder $(BUILD)/dmg -ov -format UDZO $(DMG)

run: app
	open "$(APP)"

clean:
	/bin/rm -rf $(BUILD) .build
