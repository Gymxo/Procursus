ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += libAppleWM
LIBAPPLEWM_VERSION := 1.4.1
DEB_LIBAPPLEWM_V   ?= $(LIBAPPLEWM_VERSION)

libAppleWM-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/lib/libAppleWM-1.4.1.tar.gz
	$(call EXTRACT_TAR,libAppleWM-$(LIBAPPLEWM_VERSION).tar.gz,libAppleWM-$(LIBAPPLEWM_VERSION),libAppleWM)

ifneq ($(wildcard $(BUILD_WORK)/libAppleWM/.build_complete),)
libAppleWM:
	@echo "Using previously built libAppleWM."
else
libAppleWM: libAppleWM-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/libAppleWM && autoreconf -fiv && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--enable-malloc0returnsnull=no
	+$(MAKE) -C $(BUILD_WORK)/libAppleWM
	+$(MAKE) -C $(BUILD_WORK)/libAppleWM install \
		DESTDIR=$(BUILD_STAGE)/libAppleWM
	+$(MAKE) -C $(BUILD_WORK)/libAppleWM install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/libAppleWM/.build_complete
endif

libAppleWM-package: libAppleWM-stage
# libAppleWM.mk Package Structure
	rm -rf $(BUILD_DIST)/libAppleWM
	
# libAppleWM.mk Prep libAppleWM
	cp -a $(BUILD_STAGE)/libAppleWM $(BUILD_DIST)
	
# libAppleWM.mk Sign
	$(call SIGN,libAppleWM,general.xml)
	
# libAppleWM.mk Make .debs
	$(call PACK,libAppleWM,DEB_LIBAPPLEWM_V)
	
# libAppleWM.mk Build cleanup
	rm -rf $(BUILD_DIST)/libAppleWM

.PHONY: libAppleWM libAppleWM-package