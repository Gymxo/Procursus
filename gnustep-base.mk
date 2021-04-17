ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += gnustep-base
GNUSTEP-BASE_VERSION := 1.26.0
DEB_GNUSTEP-BASE_V   ?= $(GNUSTEP-BASE_VERSION)

gnustep-base-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) http://ftpmain.gnustep.org/pub/gnustep/core/gnustep-base-1.26.0.tar.gz
	$(call EXTRACT_TAR,gnustep-base-$(GNUSTEP-BASE_VERSION).tar.gz,gnustep-base-$(GNUSTEP-BASE_VERSION),gnustep-base)

ifneq ($(wildcard $(BUILD_WORK)/gnustep-base/.build_complete),)
gnustep-base:
	@echo "Using previously built gnustep-base."
else
gnustep-base: gnustep-base-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/gnustep-base && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--disable-iconv \
		--with-default-config=/usr/GNUstep/Local/Configuration/GNUstep.conf \
		--enable-libffi
	+$(MAKE) -C $(BUILD_WORK)/gnustep-base
	+$(MAKE) -C $(BUILD_WORK)/gnustep-base install \
		DESTDIR=$(BUILD_STAGE)/gnustep-base
	+$(MAKE) -C $(BUILD_WORK)/gnustep-base install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/gnustep-base/.build_complete
endif

gnustep-base-package: gnustep-base-stage
	# gnustep-base.mk Package Structure
	rm -rf $(BUILD_DIST)/gnustep-base

	# gnustep-base.mk Prep gnustep-base
	cp -a $(BUILD_STAGE)/gnustep-base $(BUILD_DIST)

	# gnustep-base.mk Sign
	$(call SIGN,gnustep-base,general.xml)

	# gnustep-base.mk Make .debs
	$(call PACK,gnustep-base,DEB_GNUSTEP-BASE_V)

	# gnustep-base.mk Build cleanup
	rm -rf $(BUILD_DIST)/gnustep-base

.PHONY: gnustep-base gnustep-base-package
