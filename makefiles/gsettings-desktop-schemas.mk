ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += gsettings-desktop-schemas
GSETTINGS-DESKTOP-SCHEMAS_VERSION := 40.0
DEB_GSETTINGS-DESKTOP-SCHEMAS_V   ?= $(GSETTINGS-DESKTOP-SCHEMAS_VERSION)

gsettings-desktop-schemas-setup: setup
	wget -q -nc -P$(BUILD_SOURCE) https://download-fallback.gnome.org/sources/gsettings-desktop-schemas/40/gsettings-desktop-schemas-40.0.tar.xz
	$(call EXTRACT_TAR,gsettings-desktop-schemas-$(GSETTINGS-DESKTOP-SCHEMAS_VERSION).tar.xz,gsettings-desktop-schemas-$(GSETTINGS-DESKTOP-SCHEMAS_VERSION),gsettings-desktop-schemas)
	mkdir -p $(BUILD_WORK)/gsettings-desktop-schemas/build
	echo -e "[host_machine]\n \
	system = 'darwin'\n \
	cpu_family = '$(shell echo $(GNU_HOST_TRIPLE) | cut -d- -f1)'\n \
	cpu = '$(MEMO_ARCH)'\n \
	endian = 'little'\n \
	[properties]\n \
	root = '$(BUILD_BASE)'\n \
	[paths]\n \
	prefix ='$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)'\n \
	sysconfdir='$(MEMO_PREFIX)/etc'\n \
	localstatedir='$(MEMO_PREFIX)/var'\n \
	[binaries]\n \
	c = '$(CC)'\n \
	cpp = '$(CXX)'\n" > $(BUILD_WORK)/gsettings-desktop-schemas/build/cross.txt

ifneq ($(wildcard $(BUILD_WORK)/gsettings-desktop-schemas/.build_complete),)
gsettings-desktop-schemas:
	@echo "Using previously built gsettings-desktop-schemas."
else
gsettings-desktop-schemas: gsettings-desktop-schemas-setup
	cd $(BUILD_WORK)/gsettings-desktop-schemas/build && PKG_CONFIG="pkg-config" meson \
		--cross-file cross.txt \
		..
	ninja -C $(BUILD_WORK)/gsettings-desktop-schemas/build
	+DESTDIR="$(BUILD_STAGE)/gsettings-desktop-schemas" ninja -C $(BUILD_WORK)/gsettings-desktop-schemas/build install
	+DESTDIR="$(BUILD_BASE)" ninja -C $(BUILD_WORK)/gsettings-desktop-schemas/build install
	touch $(BUILD_WORK)/gsettings-desktop-schemas/.build_complete
endif

gsettings-desktop-schemas-package: gsettings-desktop-schemas-stage
	# gtk+.mk Package Structure
	rm -rf $(BUILD_DIST)/gsettings-desktop-schemas

	# gtk+.mk Prep gsettings-desktop-schemas
	cp -a $(BUILD_STAGE)/gsettings-desktop-schemas $(BUILD_DIST)

	# gtk+.mk Sign
	$(call SIGN,gsettings-desktop-schemas,general.xml)

	# gtk+.mk Make .debs
	$(call PACK,gsettings-desktop-schemas,DEB_GSETTINGS-DESKTOP-SCHEMAS_V)

	# gtk+.mk Build cleanup
	rm -rf $(BUILD_DIST)/gsettings-desktop-schemas

.PHONY: gsettings-desktop-schemas gsettings-desktop-schemas-package
