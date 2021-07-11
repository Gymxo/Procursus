ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += cegui
CEGUI_VERSION := 0.8.7
DEB_CEGUI_V   ?= $(CEGUI_VERSION)

cegui-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://iweb.dl.sourceforge.net/project/crayzedsgui/CEGUI%20Mk-2/0.8/cegui-0.8.7.tar.bz2
	$(call EXTRACT_TAR,cegui-$(CEGUI_VERSION).tar.bz2,cegui-$(CEGUI_VERSION),cegui)

ifneq ($(wildcard $(BUILD_WORK)/cegui/.build_complete),)
cegui:
	@echo "Using previously built cegui."
else
cegui: cegui-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/cegui && cmake . \
		$(DEFAULT_CMAKE_FLAGS) \
		.
	+$(MAKE) -C $(BUILD_WORK)/cegui
	+$(MAKE) -C $(BUILD_WORK)/cegui install \
		DESTDIR=$(BUILD_STAGE)/cegui
	+$(MAKE) -C $(BUILD_WORK)/cegui install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/cegui/.build_complete
endif

cegui-package: cegui-stage
	# cegui.mk Package Structure
	rm -rf $(BUILD_DIST)/cegui

	# cegui.mk Prep cegui
	cp -a $(BUILD_STAGE)/cegui $(BUILD_DIST)

	# cegui.mk Sign
	$(call SIGN,cegui,general.xml)

	# cegui.mk Make .debs
	$(call PACK,cegui,DEB_CEGUI_V)

	# cegui.mk Build cleanup
	rm -rf $(BUILD_DIST)/cegui

.PHONY: cegui cegui-package
