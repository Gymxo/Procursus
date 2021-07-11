ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += xfce4-settings
XFCE4-SETTINGS_VERSION := 4.16.1
DEB_XFCE4-SETTINGS_V   ?= $(XFCE4-SETTINGS_VERSION)

xfce4-settings-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://archive.xfce.org/src/xfce/xfce4-settings/4.16/xfce4-settings-4.16.1.tar.bz2
	$(call EXTRACT_TAR,xfce4-settings-$(XFCE4-SETTINGS_VERSION).tar.bz2,xfce4-settings-$(XFCE4-SETTINGS_VERSION),xfce4-settings)

ifneq ($(wildcard $(BUILD_WORK)/xfce4-settings/.build_complete),)
xfce4-settings:
	find $(BUILD_STAGE)/xfce4-settings -type f -exec codesign --remove {} \; &> /dev/null; \
	find $(BUILD_STAGE)/xfce4-settings -type f -exec codesign --sign $(CODESIGN_IDENTITY) --force --preserve-metadata=entitlements,requirements,flags,runtime {} \; &> /dev/null
	@echo "Using previously built xfce4-settings."
else
xfce4-settings: xfce4-settings-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xfce4-settings && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-x \
		--x-libraries=$(BUILD_BASE)/usr/lib \
		--x-includes=$(BUILD_BASE)/usr/include
	+$(MAKE) -C $(BUILD_WORK)/xfce4-settings
	+$(MAKE) -C $(BUILD_WORK)/xfce4-settings install \
		DESTDIR=$(BUILD_STAGE)/xfce4-settings
	+$(MAKE) -C $(BUILD_WORK)/xfce4-settings install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xfce4-settings/.build_complete
endif

xfce4-settings-package: xfce4-settings-stage
	# xfce4-settings.mk Package Structure
	rm -rf $(BUILD_DIST)/xfce4-settings

	# xfce4-settings.mk Prep xfce4-settings
	cp -a $(BUILD_STAGE)/xfce4-settings $(BUILD_DIST)

	# xfce4-settings.mk Sign
	$(call SIGN,xfce4-settings,general.xml)

	# xfce4-settings.mk Make .debs
	$(call PACK,xfce4-settings,DEB_XFCE4-SETTINGS_V)

	# xfce4-settings.mk Build cleanup
	rm -rf $(BUILD_DIST)/xfce4-settings

.PHONY: xfce4-settings xfce4-settings-package
