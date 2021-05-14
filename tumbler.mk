ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += tumbler
TUMBLER_VERSION := 4.16.0
DEB_TUMBLER_V   ?= $(TUMBLER_VERSION)

tumbler-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://archive.xfce.org/src/xfce/tumbler/4.16/tumbler-4.16.0.tar.bz2
	$(call EXTRACT_TAR,tumbler-$(TUMBLER_VERSION).tar.bz2,tumbler-$(TUMBLER_VERSION),tumbler)

ifneq ($(wildcard $(BUILD_WORK)/tumbler/.build_complete),)
tumbler:
	find $(BUILD_STAGE)/tumbler -type f -exec codesign --remove {} \; &> /dev/null; \
	find $(BUILD_STAGE)/tumbler -type f -exec codesign --sign $(CODESIGN_IDENTITY) --force --preserve-metadata=entitlements,requirements,flags,runtime {} \; &> /dev/null
	@echo "Using previously built tumbler."
else
tumbler: tumbler-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/tumbler && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-x \
		--x-libraries=$(BUILD_BASE)/usr/lib \
		--x-includes=$(BUILD_BASE)/usr/include
	+$(MAKE) -C $(BUILD_WORK)/tumbler
	+$(MAKE) -C $(BUILD_WORK)/tumbler install \
		DESTDIR=$(BUILD_STAGE)/tumbler
	+$(MAKE) -C $(BUILD_WORK)/tumbler install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/tumbler/.build_complete
endif

tumbler-package: tumbler-stage
	# tumbler.mk Package Structure
	rm -rf $(BUILD_DIST)/tumbler

	# tumbler.mk Prep tumbler
	cp -a $(BUILD_STAGE)/tumbler $(BUILD_DIST)

	# tumbler.mk Sign
	$(call SIGN,tumbler,general.xml)

	# tumbler.mk Make .debs
	$(call PACK,tumbler,DEB_TUMBLER_V)

	# tumbler.mk Build cleanup
	rm -rf $(BUILD_DIST)/tumbler

.PHONY: tumbler tumbler-package
