ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += xfce4-taskmanager
XFCE4-TASKMANAGER_VERSION := 1.5.2
DEB_XFCE4-TASKMANAGER_V   ?= $(XFCE4-TASKMANAGER_VERSION)

xfce4-taskmanager-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://archive.xfce.org/src/apps/xfce4-taskmanager/1.5/xfce4-taskmanager-1.5.2.tar.bz2
	$(call EXTRACT_TAR,xfce4-taskmanager-$(XFCE4-TASKMANAGER_VERSION).tar.bz2,xfce4-taskmanager-$(XFCE4-TASKMANAGER_VERSION),xfce4-taskmanager)

ifneq ($(wildcard $(BUILD_WORK)/xfce4-taskmanager/.build_complete),)
xfce4-taskmanager:
	find $(BUILD_STAGE)/xfce4-taskmanager -type f -exec codesign --remove {} \; &> /dev/null; \
	find $(BUILD_STAGE)/xfce4-taskmanager -type f -exec codesign --sign $(CODESIGN_IDENTITY) --force --preserve-metadata=entitlements,requirements,flags,runtime {} \; &> /dev/null
	@echo "Using previously built xfce4-taskmanager."
else
xfce4-taskmanager: xfce4-taskmanager-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xfce4-taskmanager && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-x \
		--x-libraries=$(BUILD_BASE)/usr/lib \
		--x-includes=$(BUILD_BASE)/usr/include \
		--enable-wnck3
	+$(MAKE) -C $(BUILD_WORK)/xfce4-taskmanager
	+$(MAKE) -C $(BUILD_WORK)/xfce4-taskmanager install \
		DESTDIR=$(BUILD_STAGE)/xfce4-taskmanager
	+$(MAKE) -C $(BUILD_WORK)/xfce4-taskmanager install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xfce4-taskmanager/.build_complete
endif

xfce4-taskmanager-package: xfce4-taskmanager-stage
	# xfce4-taskmanager.mk Package Structure
	rm -rf $(BUILD_DIST)/xfce4-taskmanager

	# xfce4-taskmanager.mk Prep xfce4-taskmanager
	cp -a $(BUILD_STAGE)/xfce4-taskmanager $(BUILD_DIST)

	# xfce4-taskmanager.mk Sign
	$(call SIGN,xfce4-taskmanager,general.xml)

	# xfce4-taskmanager.mk Make .debs
	$(call PACK,xfce4-taskmanager,DEB_XFCE4-TASKMANAGER_V)

	# xfce4-taskmanager.mk Build cleanup
	rm -rf $(BUILD_DIST)/xfce4-taskmanager

.PHONY: xfce4-taskmanager xfce4-taskmanager-package
