ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += bxfm
BXFM_VERSION := 0.90
DEB_BXFM_V   ?= $(BXFM_VERSION)

bxfm-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://master.dl.sourceforge.net/project/bxfm/bxfm-xmnl-0.90.tar.gz
	$(call EXTRACT_TAR,bxfm-xmnl-$(BXFM_VERSION).tar.gz,bxfm-xmnl-$(BXFM_VERSION),bxfm)

ifneq ($(wildcard $(BUILD_WORK)/bxfm/.build_complete),)
bxfm:
	@echo "Using previously built bxfm."
else
bxfm: bxfm-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/bxfm && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		 --enable-dependency-tracking \
		 --disable-inotify
	+$(MAKE) -i -C $(BUILD_WORK)/bxfm
	+$(MAKE) -C $(BUILD_WORK)/bxfm install \
		DESTDIR=$(BUILD_STAGE)/bxfm
	+$(MAKE) -C $(BUILD_WORK)/bxfm install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/bxfm/.build_complete
endif

bxfm-package: bxfm-stage
	# bxfm.mk Package Structure
	rm -rf $(BUILD_DIST)/bxfm

	# bxfm.mk Prep bxfm
	cp -a $(BUILD_STAGE)/bxfm $(BUILD_DIST)

	# bxfm.mk Sign
	$(call SIGN,bxfm,general.xml)

	# bxfm.mk Make .debs
	$(call PACK,bxfm,DEB_BXFM_V)

	# bxfm.mk Build cleanup
	rm -rf $(BUILD_DIST)/bxfm

.PHONY: bxfm bxfm-package
