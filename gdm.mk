ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += gdm
GDM_VERSION := 3.16.4
DEB_GDM_V   ?= $(GDM_VERSION)

gdm-setup: setup
	wget -q -nc -P$(BUILD_SOURCE) https://download-fallback.gnome.org/sources/gdm/3.16/gdm-3.16.4.tar.xz
	$(call EXTRACT_TAR,gdm-$(GDM_VERSION).tar.xz,gdm-$(GDM_VERSION),gdm)

ifneq ($(wildcard $(BUILD_WORK)/gdm/.build_complete),)
gdm:
	find $(BUILD_STAGE)/gdm -type f -exec codesign --remove {} \; &> /dev/null; \
	find $(BUILD_STAGE)/gdm -type f -exec codesign --sign $(CODESIGN_IDENTITY) --force --preserve-metadata=entitlements,requirements,flags,runtime {} \; &> /dev/null
	@echo "Using previously built gdm."
else
gdm: gdm-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/gdm && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--without-systemd \
		--with-x \
		--x-libraries=$(BUILD_BASE)/usr/lib \
		--x-includes=$(BUILD_BASE)/usr/include \
		--with-xdmcp \
		--with-xinerama \
		--enable-introspection=no \
		--without-plymouth \
		--with-default-pam-config=none
	+$(MAKE) -i -C $(BUILD_WORK)/gdm
	+$(MAKE) -i -C $(BUILD_WORK)/gdm install \
		DESTDIR=$(BUILD_STAGE)/gdm
	+$(MAKE) -i -C $(BUILD_WORK)/gdm install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/gdm/.build_complete
endif

gdm-package: gdm-stage
	# gdm.mk Package Structure
	rm -rf $(BUILD_DIST)/gdm

	# gdm.mk Prep gdm
	cp -a $(BUILD_STAGE)/gdm $(BUILD_DIST)

	# gdm.mk Sign
	$(call SIGN,gdm,general.xml)

	# gdm.mk Make .debs
	$(call PACK,gdm,DEB_GDM_V)

	# gdm.mk Build cleanup
	rm -rf $(BUILD_DIST)/gdm

.PHONY: gdm gdm-package

