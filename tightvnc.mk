ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += tightvnc
TIGHTVNC_VERSION := 1.3.10
DEB_TIGHTVNC_V   ?= $(TIGHTVNC_VERSION)

tightvnc-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.tightvnc.com/download/1.3.10/tightvnc-1.3.10_unixsrc.tar.gz
	$(call EXTRACT_TAR,tightvnc-$(TIGHTVNC_VERSION)_unixsrc.tar.gz,vnc_unixsrc,tightvnc)

ifneq ($(wildcard $(BUILD_WORK)/tightvnc/.build_complete),)
tightvnc:
	@echo "Using previously built tightvnc."
else
tightvnc: tightvnc-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/tightvnc/Xvnc && ./configure
	+$(MAKE) -C $(BUILD_WORK)/tightvnc
	+$(MAKE) -C $(BUILD_WORK)/tightvnc install \
		DESTDIR=$(BUILD_STAGE)/tightvnc
	+$(MAKE) -C $(BUILD_WORK)/tightvnc install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/tightvnc/.build_complete
endif

tightvnc-package: tightvnc-stage
	# tightvnc.mk Package Structure
	rm -rf $(BUILD_DIST)/tightvnc

	# tightvnc.mk Prep tightvnc
	cp -a $(BUILD_STAGE)/tightvnc $(BUILD_DIST)

	# tightvnc.mk Sign
	$(call SIGN,tightvnc,general.xml)

	# tightvnc.mk Make .debs
	$(call PACK,tightvnc,DEB_TIGHTVNC_V)

	# tightvnc.mk Build cleanup
	rm -rf $(BUILD_DIST)/tightvnc

.PHONY: tightvnc tightvnc-package
