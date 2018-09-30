
BUILD_DIR := build
XCODE_PROJECT := IcedHTTP.xcodeproj
XCODE_TARGET := IcedHTTP
XCODE_IOS_SCHEME := $(XCODE_TARGET)-iOS
XCODE_MACOS_SCHEME := $(XCODE_TARGET)-macOS
XCODE_IHTTPD_SCHEME := ihttpd
XCODE_CONFIGURATION := Deployment

DOCS_DIR := docs

.PHONY: build-ios
build-ios:
	xcodebuild -project $(XCODE_PROJECT) -scheme $(XCODE_IOS_SCHEME) -configuration $(XCODE_CONFIGURATION)

.PHONY: build-macos
build-macos:
	xcodebuild -project $(XCODE_PROJECT) -scheme $(XCODE_MACOS_SCHEME) -configuration $(XCODE_CONFIGURATION)

.PHONY: build-ihttpd
build-ihttpd:
	xcodebuild -project $(XCODE_PROJECT) -scheme $(XCODE_IHTTPD_SCHEME) -configuration $(XCODE_CONFIGURATION)

.PHONY: build
build: build-ios build-macos

.PHONY: clean-build
clean-build:
	if [ -d $(BUILD_DIR) ]; then rm -r $(BUILD_DIR); fi

.PHONY: headerdoc
headerdoc:
	find . -type f -name '*.h' | xargs headerdoc2html -o $(DOCS_DIR)
	gatherheaderdoc $(DOCS_DIR)
	if [ -x `which markdown` ]; then markdown README.md > $(DOCS_DIR)/index.html && open $(DOCS_DIR)/index.html; fi

.PHONY: clean-headerdoc
clean-headerdoc:
	if [ -d $(DOCS_DIR) ]; then rm -r $(DOCS_DIR); fi

.PHONY: clean
clean: clean-build clean-headerdoc

.PHONY: all
all: clean build headerdoc
