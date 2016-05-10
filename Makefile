
BUILD_DIR := build
XCODE_PROJECT := IcedHTTP.xcodeproj
XCODE_TARGET := IcedHTTP
XCODE_CONFIGURATION := Deployment

DOCS_DIR := docs

.PHONY: build
build:
	xcodebuild -project $(XCODE_PROJECT) -target $(XCODE_TARGET) -configuration $(XCODE_CONFIGURATION)

.PHONY: build-clean
build-clean:
	rm -r $(BUILD_DIR)

.PHONY: headerdoc
headerdoc:
	find . -type f -name '*.h' | xargs headerdoc2html -o $(DOCS_DIR)
	gatherheaderdoc $(DOCS_DIR)
	markdown README.md > $(DOCS_DIR)/index.html
	open $(DOCS_DIR)/index.html

.PHONY: headerdoc-clean
headerdoc-clean:
	rm -r $(DOCS_DIR)

.PHONY: clean
clean: build-clean headerdoc-clean
