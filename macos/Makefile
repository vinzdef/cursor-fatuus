BUILD   := build
APP     := $(BUILD)/Cursor Fatuus.app
DMG     := $(BUILD)/CursorFatuus.dmg
# Release builds pass ARCHS="--arch arm64 --arch x86_64" for a universal app.
ARCHS   ?=
SWIFT   := swift build -c release $(ARCHS)
# Stamped into Info.plist when set, e.g. VERSION=1.0.0.
VERSION ?=
# Developer ID identity for distribution builds; ad-hoc signing when left as "-".
SIGN_ID ?= -
# notarytool credentials: a stored keychain profile locally, API key flags in CI.
NOTARY_ARGS ?= --keychain-profile cf-notary

.PHONY: all app dmg notarize require-sign-id run clean

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
ifeq ($(SIGN_ID),-)
	codesign --force --sign - "$(APP)"
else
	codesign --force --options runtime --timestamp --sign "$(SIGN_ID)" "$(APP)"
endif

dmg: app
	/bin/rm -rf $(BUILD)/dmg $(DMG)
	@mkdir -p $(BUILD)/dmg
	/bin/cp -R "$(APP)" $(BUILD)/dmg/
	ln -s /Applications $(BUILD)/dmg/Applications
	hdiutil create -volname "Cursor Fatuus" -srcfolder $(BUILD)/dmg -ov -format UDZO $(DMG)

notarize: require-sign-id dmg
	codesign --force --timestamp --sign "$(SIGN_ID)" $(DMG)
	xcrun notarytool submit $(DMG) $(NOTARY_ARGS) --wait
	xcrun stapler staple $(DMG)

require-sign-id:
	@test "$(SIGN_ID)" != "-" || { echo "notarize needs SIGN_ID set to a Developer ID identity"; exit 1; }

run: app
	open "$(APP)"

clean:
	/bin/rm -rf $(BUILD) .build
