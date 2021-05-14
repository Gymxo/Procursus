ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   		+= xfce4-session
XFCE4-SESSION_VERSION := 4.16.0
DEB_XFCE4-SESSION_V   ?= $(XFCE4-SESSION_VERSION)

xfce4-session-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://archive.xfce.org/src/xfce/xfce4-session/4.16/xfce4-session-$(XFCE4-SESSION_VERSION).tar.bz2
	$(call EXTRACT_TAR,xfce4-session-$(XFCE4-SESSION_VERSION).tar.bz2,xfce4-session-$(XFCE4-SESSION_VERSION),xfce4-session)
	$(call DO_PATCH,xfce4-session,xfce4-session,-p1)

ifneq ($(wildcard $(BUILD_WORK)/xfce4-session/.build_complete),)
xfce4-session:
	find $(BUILD_STAGE)/xfce4-session -type f -exec codesign --remove {} \; &> /dev/null; \
	find $(BUILD_STAGE)/xfce4-session -type f -exec codesign --sign $(CODESIGN_IDENTITY) --force --preserve-metadata=entitlements,requirements,flags,runtime {} \; &> /dev/null
	@echo "Using previously built xfce4-session."
else
xfce4-session: xfce4-session-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xfce4-session && autoreconf -fiv && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-x \
		--x-libraries=$(BUILD_BASE)/usr/lib \
		--x-includes=$(BUILD_BASE)/usr/include \
		--disable-polkit \
		ac_cv_func_malloc_0_nonnull=yes \
		ac_cv_func_realloc_0_nonnull=yes
	+$(MAKE) -C $(BUILD_WORK)/xfce4-session
	+$(MAKE) -C $(BUILD_WORK)/xfce4-session install \
		DESTDIR=$(BUILD_STAGE)/xfce4-session
	+$(MAKE) -C $(BUILD_WORK)/xfce4-session install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xfce4-session/.build_complete
endif

xfce4-session-package: xfce4-session-stage
	# xfce4-session.mk Package Structure
	rm -rf $(BUILD_DIST)/xfce4-session

	# xfce4-session.mk Prep xfce4-session
	cp -a $(BUILD_STAGE)/xfce4-session $(BUILD_DIST)

	# xfce4-session.mk Sign
	$(call SIGN,xfce4-session,general.xml)

	# xfce4-session.mk Make .debs
	$(call PACK,xfce4-session,DEB_XFCE4-SESSION_V)

	# xfce4-session.mk Build cleanup
	rm -rf $(BUILD_DIST)/xfce4-session

.PHONY: xfce4-session xfce4-session-package
