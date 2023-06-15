APP_NAME = xkcdviewer
PROJECT_NAME = $(APP_NAME).xcodeproj
SCHEME_NAME = $(APP_NAME)
CONFIGURATION = Release
ARCH = arm64
SDK = iphoneos

BUILD_DIR = build
PAYLOAD_DIR = $(BUILD_DIR)/Payload
LAYOUT_DIR = $(BUILD_DIR)/layout

IPA_NAME = $(APP_NAME).ipa
DEB_NAME = $(APP_NAME).deb

all: build_ipa build_deb

build_ipa:
	xcodebuild -quiet -jobs $(shell sysctl -n hw.ncpu) -project $(PROJECT_NAME) -scheme $(SCHEME_NAME) -configuration $(CONFIGURATION) -arch $(ARCH) -sdk $(SDK) CODE_SIGNING_ALLOWED=NO DSTROOT=$(PAYLOAD_DIR)/install
	ldid -Sentitlements.plist $(PAYLOAD_DIR)/$(APP_NAME).app/$(APP_NAME)
	mkdir -p $(BUILD_DIR)
	cd $(PAYLOAD_DIR) && zip -r9 ../$(IPA_NAME) . && cd ..
	rm -rf $(PAYLOAD_DIR)

build_deb:
	cp -R $(BUILD_DIR)/$(APP_NAME).ipa $(LAYOUT_DIR)/Applications/$(APP_NAME).app
	dpkg-deb --build $(LAYOUT_DIR)
	mv $(LAYOUT_DIR).deb $(BUILD_DIR)/$(DEB_NAME)
	rm -rf $(LAYOUT_DIR)

clean:
	xcodebuild clean -project $(PROJECT_NAME) -scheme $(SCHEME_NAME) -configuration $(CONFIGURATION)

.PHONY: all build_ipa build_deb clean
