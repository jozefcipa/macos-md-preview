APP          := build/MDPreview.app
EXT          := $(APP)/Contents/PlugIns/MDPreviewExtension.appex
ENTITLEMENTS := MDPreview.entitlements
SIGNATURE    := $(APP)/Contents/_CodeSignature/CodeResources
INPUTS       := $(shell find Sources Assets -type f) $(ENTITLEMENTS)

INSTALLED  := $(HOME)/Applications/MDPreview.app
LSREGISTER := /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister

.PHONY: all install uninstall reload clean

all: $(SIGNATURE)

# Rebuilds the whole bundle when anything changes; the signature is written last,
# so a failed build leaves no target and the next run starts over
$(SIGNATURE): $(INPUTS)
	rm -rf $(APP)
	mkdir -p $(APP)/Contents/MacOS $(EXT)/Contents/MacOS $(EXT)/Contents/Resources
	swiftc -O -module-name MDPreviewExtension -application-extension \
		-Xlinker -e -Xlinker _NSExtensionMain \
		Sources/MDPreviewExtension/*.swift -o $(EXT)/Contents/MacOS/MDPreviewExtension
	swiftc -O Sources/MDPreview/*.swift -o $(APP)/Contents/MacOS/MDPreview
	cp Sources/MDPreviewExtension/Info.plist $(EXT)/Contents/
	cp Sources/MDPreview/Info.plist $(APP)/Contents/
	cp Assets/* $(EXT)/Contents/Resources/
	codesign -f -s - --entitlements $(ENTITLEMENTS) $(EXT)
	codesign -f -s - --entitlements $(ENTITLEMENTS) $(APP)

install: all
	rm -rf $(INSTALLED)
	mkdir -p $(dir $(INSTALLED))
	cp -R $(APP) $(INSTALLED)
	$(LSREGISTER) -f -R $(INSTALLED)
	pluginkit -a $(INSTALLED)/Contents/PlugIns/MDPreviewExtension.appex
	@$(MAKE) --no-print-directory reload
	@echo "Installed to $(INSTALLED)"

uninstall:
	-pluginkit -r $(INSTALLED)/Contents/PlugIns/MDPreviewExtension.appex
	rm -rf $(INSTALLED)
	@$(MAKE) --no-print-directory reload

reload:
	qlmanage -r >/dev/null
	qlmanage -r cache >/dev/null

clean:
	rm -rf build
