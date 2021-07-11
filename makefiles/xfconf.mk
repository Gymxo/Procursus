ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += xfconf
XFCONF_VERSION := 4.16.0
DEB_XFCONF_V   ?= $(XFCONF_VERSION)

xfconf-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://archive.xfce.org/src/xfce/xfconf/4.16/xfconf-$(XFCONF_VERSION).tar.bz2
	$(call EXTRACT_TAR,xfconf-$(XFCONF_VERSION).tar.bz2,xfconf-$(XFCONF_VERSION),xfconf)

ifneq ($(wildcard $(BUILD_WORK)/xfconf/.build_complete),)
xfconf:
	find $(BUILD_STAGE)/xfconf -type f -exec codesign --remove {} \; &> /dev/null; \
	find $(BUILD_STAGE)/xfconf -type f -exec codesign --sign $(CODESIGN_IDENTITY) --force --preserve-metadata=entitlements,requirements,flags,runtime {} \; &> /dev/null
	@echo "Using previously built xfconf."
else
xfconf: xfconf-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xfconf && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-x \
		--x-libraries=$(BUILD_BASE)/usr/lib \
		--x-includes=$(BUILD_BASE)/usr/include \
		--disable-visibility \
		--enable-introspection=no
	+$(MAKE) -C $(BUILD_WORK)/xfconf
	+$(MAKE) -C $(BUILD_WORK)/xfconf install \
		DESTDIR=$(BUILD_STAGE)/xfconf
	+$(MAKE) -C $(BUILD_WORK)/xfconf install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xfconf/.build_complete
endif

xfconf-package: xfconf-stage
	# xfconf.mk Package Structure
	rm -rf $(BUILD_DIST)/xfconf

	# xfconf.mk Prep xfconf
	cp -a $(BUILD_STAGE)/xfconf $(BUILD_DIST)

	# xfconf.mk Sign
	$(call SIGN,xfconf,general.xml)

	# xfconf.mk Make .debs
	$(call PACK,xfconf,DEB_XFCONF_V)

	# xfconf.mk Build cleanup
	rm -rf $(BUILD_DIST)/xfconf

.PHONY: xfconf xfconf-package
