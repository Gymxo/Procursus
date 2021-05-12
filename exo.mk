ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += exo
EXO_VERSION := 4.16.0
DEB_EXO_V   ?= $(EXO_VERSION)

exo-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://archive.al-us.xfce.org/src/xfce/exo/4.16/exo-4.16.0.tar.bz2
	$(call EXTRACT_TAR,exo-$(EXO_VERSION).tar.bz2,exo-$(EXO_VERSION),exo)

ifneq ($(wildcard $(BUILD_WORK)/exo/.build_complete),)
exo:
	@echo "Using previously built exo."
else
exo: exo-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/exo && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-x \
		--x-libraries=$(BUILD_BASE)/usr/lib \
		--x-includes=$(BUILD_BASE)/usr/include
	+$(MAKE) -C $(BUILD_WORK)/exo
	+$(MAKE) -C $(BUILD_WORK)/exo install \
		DESTDIR=$(BUILD_STAGE)/exo
	+$(MAKE) -C $(BUILD_WORK)/exo install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/exo/.build_complete
endif

exo-package: exo-stage
	# exo.mk Package Structure
	rm -rf $(BUILD_DIST)/exo

	# exo.mk Prep exo
	cp -a $(BUILD_STAGE)/exo $(BUILD_DIST)

	# exo.mk Sign
	$(call SIGN,exo,general.xml)

	# exo.mk Make .debs
	$(call PACK,exo,DEB_EXO_V)

	# exo.mk Build cleanup
	rm -rf $(BUILD_DIST)/exo

.PHONY: exo exo-package
