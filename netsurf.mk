ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += netsurf
NETSURF_VERSION := 3.10
DEB_NETSURF_V   ?= $(NETSURF_VERSION)

netsurf-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) http://download.netsurf-browser.org/netsurf/releases/source-full/netsurf-all-3.10.tar.gz
	$(call EXTRACT_TAR,netsurf-all-$(NETSURF_VERSION).tar.gz,netsurf-all-$(NETSURF_VERSION),netsurf)

ifneq ($(wildcard $(BUILD_WORK)/netsurf/.build_complete),)
netsurf:
	@echo "Using previously built netsurf."
else
netsurf: netsurf-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/netsurf && $(MAKE) CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)"
	+$(MAKE) CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)" -C $(BUILD_WORK)/netsurf install \
		DESTDIR=$(BUILD_STAGE)/netsurf
	+$(MAKE) CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)" -C $(BUILD_WORK)/netsurf install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/netsurf/.build_complete
endif

netsurf-package: netsurf-stage
	# netsurf.mk Package Structure
	rm -rf $(BUILD_DIST)/netsurf

	# netsurf.mk Prep netsurf
	cp -a $(BUILD_STAGE)/netsurf $(BUILD_DIST)

	# netsurf.mk Sign
	$(call SIGN,netsurf,general.xml)

	# netsurf.mk Make .debs
	$(call PACK,netsurf,DEB_NETSURF_V)

	# netsurf.mk Build cleanup
	rm -rf $(BUILD_DIST)/netsurf

.PHONY: netsurf netsurf-package
