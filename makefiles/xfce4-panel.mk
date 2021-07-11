ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += xfce4-panel
XFCE4-PANEL_VERSION := 4.16.3
DEB_XFCE4-PANEL_V   ?= $(XFCE4-PANEL_VERSION)

xfce4-panel-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://archive.xfce.org/src/xfce/xfce4-panel/4.16/xfce4-panel-4.16.3.tar.bz2
	$(call EXTRACT_TAR,xfce4-panel-$(XFCE4-PANEL_VERSION).tar.bz2,xfce4-panel-$(XFCE4-PANEL_VERSION),xfce4-panel)

ifneq ($(wildcard $(BUILD_WORK)/xfce4-panel/.build_complete),)
xfce4-panel:
	find $(BUILD_STAGE)/xfce4-panel -type f -exec codesign --remove {} \; &> /dev/null; \
	find $(BUILD_STAGE)/xfce4-panel -type f -exec codesign --sign $(CODESIGN_IDENTITY) --force --preserve-metadata=entitlements,requirements,flags,runtime {} \; &> /dev/null
	@echo "Using previously built xfce4-panel."
else
xfce4-panel: xfce4-panel-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xfce4-panel && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-x \
		--x-libraries=$(BUILD_BASE)/usr/lib \
		--x-includes=$(BUILD_BASE)/usr/include \
		--enable-introspection=no \
		--disable-visibility
	+$(MAKE) -C $(BUILD_WORK)/xfce4-panel
	+$(MAKE) -C $(BUILD_WORK)/xfce4-panel install \
		DESTDIR=$(BUILD_STAGE)/xfce4-panel
	+$(MAKE) -C $(BUILD_WORK)/xfce4-panel install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xfce4-panel/.build_complete
endif

xfce4-panel-package: xfce4-panel-stage
	# xfce4-panel.mk Package Structure
	rm -rf $(BUILD_DIST)/xfce4-panel

	# xfce4-panel.mk Prep xfce4-panel
	cp -a $(BUILD_STAGE)/xfce4-panel $(BUILD_DIST)

	# xfce4-panel.mk Sign
	$(call SIGN,xfce4-panel,general.xml)

	# xfce4-panel.mk Make .debs
	$(call PACK,xfce4-panel,DEB_XFCE4-PANEL_V)

	# xfce4-panel.mk Build cleanup
	rm -rf $(BUILD_DIST)/xfce4-panel

.PHONY: xfce4-panel xfce4-panel-package
