ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS         += at-spi2-atk
AT-SPI2-ATK_VERSION := 2.38.0
DEB_AT-SPI2-ATK_V   ?= $(AT-SPI2-ATK_VERSION)

at-spi2-atk-setup: setup
	wget -q -nc -P$(BUILD_SOURCE) https://download-fallback.gnome.org/sources/at-spi2-atk/$(shell echo $(AT-SPI2-ATK_VERSION) | cut -f-2 -d.)/at-spi2-atk-$(AT-SPI2-ATK_VERSION).tar.xz
	$(call EXTRACT_TAR,at-spi2-atk-$(AT-SPI2-ATK_VERSION).tar.xz,at-spi2-atk-$(AT-SPI2-ATK_VERSION),at-spi2-atk)
	mkdir -p $(BUILD_WORK)/at-spi2-atk/build
	echo -e "[host_machine]\n \
	cpu_family = '$(shell echo $(GNU_HOST_TRIPLE) | cut -d- -f1)'\n \
	cpu = '$(MEMO_ARCH)'\n \
	endian = 'little'\n \
	system = 'darwin'\n \
	[properties]\n \
	root = '$(BUILD_BASE)'\n \
	needs_exe_wrapper = true\n \
	[paths]\n \
	prefix ='$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)'\n \
	[binaries]\n \
	c = '$(CC)'\n \
	objc = '$(CC)'\n \
	cpp = '$(CXX)'\n \
	pkgconfig = '$(BUILD_TOOLS)/cross-pkg-config'\n" > $(BUILD_WORK)/at-spi2-atk/build/cross.txt

ifneq ($(wildcard $(BUILD_WORK)/at-spi2-atk/.build_complete),)
at-spi2-atk:
	@echo "Using previously built at-spi2-atk."
else
at-spi2-atk: at-spi2-atk-setup
	cd $(BUILD_WORK)/at-spi2-atk/build && meson \
	--cross-file cross.txt \
	-Dintrospection=false \
	..
	ninja -C $(BUILD_WORK)/at-spi2-atk/build
	+DESTDIR="$(BUILD_STAGE)/at-spi2-atk" ninja -C $(BUILD_WORK)/at-spi2-atk/build install
	touch $(BUILD_WORK)/at-spi2-atk/.build_complete
endif

at-spi2-atk-package: at-spi2-atk-stage
	# at-spi2-core.mk Package Structure
	rm -rf $(BUILD_DIST)/at-spi2-core $(BUILD_DIST)/libatspi2.0-{0,dev}
	mkdir -p $(BUILD_DIST)/at-spi2-core/$(MEMO_PREFIX){$(MEMO_SUB_PREFIX)/{share/dbus-1/{accessibility-services,services},libexec},/Library/LaunchDaemons} \
		$(BUILD_DIST)/libatspi2.0-0/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib \
		$(BUILD_DIST)/libatspi2.0-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/{lib/pkgconfig,include}

	# at-spi2-core.mk at-spi2-core glib2.0 dbus gettext libx11 libxi libxtst
	cp -a $(BUILD_MISC)/at-spi2-core/org.a11y.Bus.plist \
		$(BUILD_DIST)/at-spi2-core/$(MEMO_PREFIX)/Library/LaunchDaemons/org.a11y.Bus.plist
	cp -a $(BUILD_STAGE)/at-spi2-core/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/!(dbus-1) \
		$(BUILD_DIST)/at-spi2-core/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share
	cp -a $(BUILD_STAGE)/at-spi2-core/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/libexec \
		$(BUILD_DIST)/at-spi2-core/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/
	cp -a $(BUILD_STAGE)/at-spi2-core/$(MEMO_PREFIX)/etc \
		$(BUILD_DIST)/at-spi2-core/$(MEMO_PREFIX)/
	cp -a $(BUILD_MISC)/at-spi2-core/org.a11y.Bus.plist \
		$(BUILD_DIST)/at-spi2-core/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/dbus-1/services
	cp -a $(BUILD_MISC)/at-spi2-core/org.a11y.atspi.Registry.plist \
		$(BUILD_DIST)/at-spi2-core/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/share/dbus-1/accessibility-services

	# at-spi2-core.mk Prep libatspi2.0-0
	cp -a $(BUILD_STAGE)/at-spi2-core/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libatspi.0.dylib \
		$(BUILD_DIST)/libatspi2.0-0/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib

	# at-spi2-core.mk Prep libatspi2.0-dev
	cp -a $(BUILD_STAGE)/at-spi2-core/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/!(libatspi.0.dylib|systemd) \
		$(BUILD_DIST)/libatspi2.0-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib
	cp -a $(BUILD_STAGE)/at-spi2-core/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include/at-spi-2.0 \
		$(BUILD_DIST)/libatspi2.0-dev/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/include


	# at-spi2-core.mk Sign
	$(call SIGN,at-spi2-core,general.xml)
	$(call SIGN,libatspi2.0-0,general.xml)

	# at-spi2-core.mk Make .debs
	$(call PACK,at-spi2-core,DEB_AT-SPI2-CORE_V)
	$(call PACK,libatspi2.0-0,DEB_AT-SPI2-CORE_V)
	$(call PACK,libatspi2.0-dev,DEB_AT-SPI2-CORE_V)

	# at-spi2-core.mk Build cleanup
	rm -rf $(BUILD_DIST)/at-spi2-core $(BUILD_DIST)/libatspi2.0-{0,dev}

.PHONY: at-spi2-atk at-spi2-atk-package


