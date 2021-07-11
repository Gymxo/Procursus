ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += thunar
THUNAR_VERSION := 4.17.3
DEB_THUNAR_V   ?= $(THUNAR_VERSION)

thunar-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://archive.xfce.org/src/xfce/thunar/4.17/thunar-4.17.3.tar.bz2
	$(call EXTRACT_TAR,thunar-$(THUNAR_VERSION).tar.bz2,thunar-$(THUNAR_VERSION),thunar)

ifneq ($(wildcard $(BUILD_WORK)/thunar/.build_complete),)
thunar:
	find $(BUILD_STAGE)/thunar -type f -exec codesign --remove {} \; &> /dev/null; \
	find $(BUILD_STAGE)/thunar -type f -exec codesign --sign $(CODESIGN_IDENTITY) --force --preserve-metadata=entitlements,requirements,flags,runtime {} \; &> /dev/null
	@echo "Using previously built thunar."
else
thunar: thunar-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/thunar && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-x \
		--x-libraries=$(BUILD_BASE)/usr/lib \
		--x-includes=$(BUILD_BASE)/usr/include \
		--disable-notifications \
		--enable-introspection=no
	+$(MAKE) -C $(BUILD_WORK)/thunar
	+$(MAKE) -C $(BUILD_WORK)/thunar install \
		DESTDIR=$(BUILD_STAGE)/thunar
	+$(MAKE) -C $(BUILD_WORK)/thunar install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/thunar/.build_complete
endif

thunar-package: thunar-stage
	# thunar.mk Package Structure
	rm -rf $(BUILD_DIST)/thunar

	# thunar.mk Prep thunar
	cp -a $(BUILD_STAGE)/thunar $(BUILD_DIST)

	# thunar.mk Sign
	$(call SIGN,thunar,general.xml)

	# thunar.mk Make .debs
	$(call PACK,thunar,DEB_THUNAR_V)

	# thunar.mk Build cleanup
	rm -rf $(BUILD_DIST)/thunar

.PHONY: thunar thunar-package
