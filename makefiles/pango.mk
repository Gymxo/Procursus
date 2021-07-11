ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += pango
PANGO_VERSION := 1.48.4
DEB_PANGO_V   ?= $(PANGO_VERSION)

CROSS_LOAD := GI_CROSS_LAUNCHER=$(BUILD_TOOLS)/gi-cross-launcher-load.sh
CROSS_SAVE := GI_CROSS_LAUNCHER=$(BUILD_TOOLS)/gi-cross-launcher-save.sh
#### This will currently only build for the system you're building on.
# You need libffi-dev, libglib2.0-dev, libpython3.9-dev

pango-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://download.gnome.org/sources/pango/$(shell echo $(PANGO_VERSION) | cut -f-2 -d.)/pango-$(PANGO_VERSION).tar.xz
	$(call EXTRACT_TAR,pango-$(PANGO_VERSION).tar.xz,pango-$(PANGO_VERSION),pango)
	$(call DO_PATCH,pango,pango,-p1)
	mkdir -p $(BUILD_WORK)/pango/build

ifeq ($(MEMO_TARGET),iphoneos-arm64)
	echo -e "[host_machine]\n \
	cpu_family = '$(shell echo $(GNU_HOST_TRIPLE) | cut -d- -f1)'\n \
	cpu = '$(MEMO_ARCH)'\n \
	endian = 'little'\n \
	system = 'darwin'\n \
	[properties]\n \
	root = '$(BUILD_BASE)'\n \
	sys_root = '$(BUILD_BASE)'\n \
	needs_exe_wrapper = true\n \
	[paths]\n \
	prefix ='$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)'\n \
	[binaries]\n \
	c = '$(CC)'\n \
	objc = '$(CC)'\n \
	cpp = '$(CXX)'\n \
	pkgconfig = '$(shell which pkg-config)'\n" > $(BUILD_WORK)/pango/build/cross.txt
endif

ifneq ($(MEMO_TARGET),darwin-amd64)
else ifneq ($(MEMO_TARGET),darwin-arm64)
	echo -e "[paths]\n \
	prefix ='$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)'\n \
	[properties]\n \
	root = '$(BUILD_BASE)'\n \
	sys_root = '$(BUILD_BASE)'\n \
	[binaries]\n \
	pkgconfig = '$(shell which pkg-config)'\n" > $(BUILD_WORK)/pango/build/cross.txt
endif

ifneq ($(wildcard $(BUILD_WORK)/pango/.build_complete),)
pango:
	@echo "Using previously built pango."
else
pango: pango-setup glib2.0 libffi python3 harfbuzz fontconfig libfribidi
ifneq ($(MEMO_TARGET),darwin-amd64)
else ifneq ($(MEMO_TARGET),darwin-arm64)
	export GI_SCANNER_DISABLE_CACHE=true; \
	cd $(BUILD_WORK)/pango/build && meson \
		--cross-file cross.txt \
		-Dintrospection=enabled \
		..
	unset MACOSX_DEPLOYMENT_TARGET && export $(CROSS_SAVE) && ninja -C $(BUILD_WORK)/pango/build
	+DESTDIR="$(BUILD_STAGE)/pango" ninja -C $(BUILD_WORK)/pango/build install
	+DESTDIR="$(BUILD_BASE)" ninja -C $(BUILD_WORK)/pango/build install
	touch $(BUILD_WORK)/pango/.build_complete
endif
ifeq ($(MEMO_TARGET),iphoneos-arm64)
	export GI_SCANNER_DISABLE_CACHE=true; \
	cd $(BUILD_WORK)/pango/build && meson \
		--cross-file cross.txt \
		-Dintrospection=true \
		..
	$(SED) -i 's/--cflags-begin/--cflags-begin -arch $(MEMO_ARCH)/g' $(BUILD_WORK)/pango/build/build.ninja
	unset MACOSX_DEPLOYMENT_TARGET && export $(CROSS_LOAD) && ninja -C $(BUILD_WORK)/pango/build
	+DESTDIR="$(BUILD_STAGE)/pango" ninja -C $(BUILD_WORK)/pango/build install
	+DESTDIR="$(BUILD_BASE)" ninja -C $(BUILD_WORK)/pango/build install
	touch $(BUILD_WORK)/pango/.build_complete
	touch $(BUILD_WORK)/pango/.build_complete
endif
endif

pango-package: pango-stage
	# pango.mk Package Structure
	rm -rf $(BUILD_DIST)/libgirepository-1.0-{1,dev} $(BUILD_DIST)/pango $(BUILD_DIST)/gir1.2-{freedesktop,glib-2.0}
	mkdir -p $(BUILD_DIST)/libgirepository-1.0-1/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib \
		$(BUILD_DIST)/libgirepository-1.0-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/{lib,share} \
		$(BUILD_DIST)/pango/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/{lib,share} \
		$(BUILD_DIST)/gir1.2-{freedesktop,glib-2.0}/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/girepository-1.0

	# pango.mk Prep libgirepository-1.0-1
	cp -a $(BUILD_STAGE)/pango/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libgirepository-1.0.1.dylib $(BUILD_DIST)/libgirepository-1.0-1/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# pango.mk Prep libgirepository-1.0-dev
	cp -a $(BUILD_STAGE)/pango/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/{libgirepository-1.0.dylib,pkgconfig} $(BUILD_DIST)/libgirepository-1.0-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib
	cp -a $(BUILD_STAGE)/pango/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include $(BUILD_DIST)/libgirepository-1.0-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)
	cp -a $(BUILD_STAGE)/pango/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/gir-1.0 $(BUILD_DIST)/libgirepository-1.0-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share

	# pango.mk Prep pango
	cp -a $(BUILD_STAGE)/pango/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/bin $(BUILD_DIST)/pango/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)
	cp -a $(BUILD_STAGE)/pango/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/pango $(BUILD_DIST)/pango/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib
	cp -a $(BUILD_STAGE)/pango/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/!(gir-1.0) $(BUILD_DIST)/pango/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share

	# pango.mk Prep gir1.2-glib-2.0
	cp -a $(BUILD_STAGE)/pango/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/girepository-1.0/{GIRepository,GLib,GModule,GObject,Gio}-2.0.typelib $(BUILD_DIST)/gir1.2-glib-2.0/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/girepository-1.0

	# pango.mk Prep gir1.2-freedesktop
	cp -a $(BUILD_STAGE)/pango/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/girepository-1.0/cairo-1.0.typelib \
		$(BUILD_STAGE)/pango/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/girepository-1.0/DBus-1.0.typelib \
		$(BUILD_STAGE)/pango/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/girepository-1.0/DBusGLib-1.0.typelib \
		$(BUILD_STAGE)/pango/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/girepository-1.0/fontconfig-2.0.typelib \
		$(BUILD_STAGE)/pango/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/girepository-1.0/freetype2-2.0.typelib \
		$(BUILD_STAGE)/pango/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/girepository-1.0/GL-1.0.typelib \
		$(BUILD_STAGE)/pango/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/girepository-1.0/libxml2-2.0.typelib \
		$(BUILD_STAGE)/pango/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/girepository-1.0/Vulkan-1.0.typelib \
		$(BUILD_STAGE)/pango/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/girepository-1.0/xfixes-4.0.typelib \
		$(BUILD_STAGE)/pango/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/girepository-1.0/xft-2.0.typelib \
		$(BUILD_STAGE)/pango/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/girepository-1.0/xlib-2.0.typelib \
		$(BUILD_STAGE)/pango/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/girepository-1.0/xrandr-1.3.typelib $(BUILD_DIST)/gir1.2-freedesktop/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/girepository-1.0

	# pango.mk Sign
	$(call SIGN,libgirepository-1.0-1,general.xml)
	$(call SIGN,pango,general.xml)

	# pango.mk Make .debs
	$(call PACK,libgirepository-1.0-1,DEB_PANGO_V)
	$(call PACK,libgirepository-1.0-dev,DEB_PANGO_V)
	$(call PACK,pango,DEB_PANGO_V)
	$(call PACK,gir1.2-glib-2.0,DEB_PANGO_V)
	$(call PACK,gir1.2-freedesktop,DEB_PANGO_V)

	# pango.mk Build cleanup
	rm -rf $(BUILD_DIST)/libgirepository-1.0-{1,dev} $(BUILD_DIST)/pango $(BUILD_DIST)/gir1.2-{freedesktop,glib-2.0}

.PHONY: pango pango-package
