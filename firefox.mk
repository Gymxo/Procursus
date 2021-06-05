ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += firefox
FIREFOX_VERSION := 78.10.1
DEB_FIREFOX_V   ?= $(FIREFOX_VERSION)

firefox-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://archive.mozilla.org/pub/firefox/releases/78.10.1esr/source/firefox-78.10.1esr.source.tar.xz
	$(call EXTRACT_TAR,firefox-$(FIREFOX_VERSION)esr.source.tar.xz,firefox-$(FIREFOX_VERSION),firefox)

ifneq ($(wildcard $(BUILD_WORK)/firefox/.build_complete),)
firefox:
	@echo "Using previously built firefox."
else
firefox: firefox-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/firefox/js/src && mkdir -p obj && cd obj \
	&& unset MACOSX_DEPLOYMENT_TARGET && ../configure \
	--enable-dbus \
	--target=aarch64-apple-darwin \
	--disable-shared-memory \
	--disable-tests \
	--with-macos-sdk=$(TARGET_SYSROOT) \
	--enable-profile-use=cross \
	--disable-macos-target \
	--enable-application=js \
	--prefix=$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)
	+$(MAKE) -C $(BUILD_WORK)/firefox/js/src/obj
	+$(MAKE) -C $(BUILD_WORK)/firefox/js/src/obj install \
		DESTDIR=$(BUILD_STAGE)/firefox
	+$(MAKE) -C $(BUILD_WORK)/firefox/js/src/obj install \
		DESTDIR=$(BUILD_BASE)
endif

firefox-package: firefox-stage
	# firefox.mk Package Structure
	rm -rf $(BUILD_DIST)/firefox

	# firefox.mk Prep firefox
	cp -a $(BUILD_STAGE)/firefox $(BUILD_DIST)

	# firefox.mk Sign
	$(call SIGN,firefox,general.xml)

	# firefox.mk Make .debs
	$(call PACK,firefox,DEB_FIREFOX_V)

	# firefox.mk Build cleanup
	rm -rf $(BUILD_DIST)/firefox

.PHONY: firefox firefox-package
