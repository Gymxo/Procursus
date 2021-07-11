ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += garcon
GARCON_VERSION := 4.16.1
DEB_GARCON_V   ?= $(GARCON_VERSION)

garcon-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://archive.xfce.org/src/xfce/garcon/4.16/garcon-4.16.1.tar.bz2
	$(call EXTRACT_TAR,garcon-$(GARCON_VERSION).tar.bz2,garcon-$(GARCON_VERSION),garcon)

ifneq ($(wildcard $(BUILD_WORK)/garcon/.build_complete),)
garcon:
	find $(BUILD_STAGE)/garcon -type f -exec codesign --remove {} \; &> /dev/null; \
	find $(BUILD_STAGE)/garcon -type f -exec codesign --sign $(CODESIGN_IDENTITY) --force --preserve-metadata=entitlements,requirements,flags,runtime {} \; &> /dev/null
	@echo "Using previously built garcon."
else
garcon: garcon-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/garcon && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--enable-introspection=no
	+$(MAKE) -C $(BUILD_WORK)/garcon
	+$(MAKE) -C $(BUILD_WORK)/garcon install \
		DESTDIR=$(BUILD_STAGE)/garcon
	+$(MAKE) -C $(BUILD_WORK)/garcon install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/garcon/.build_complete
endif

garcon-package: garcon-stage
	# garcon.mk Package Structure
	rm -rf $(BUILD_DIST)/garcon

	# garcon.mk Prep garcon
	cp -a $(BUILD_STAGE)/garcon $(BUILD_DIST)

	# garcon.mk Sign
	$(call SIGN,garcon,general.xml)

	# garcon.mk Make .debs
	$(call PACK,garcon,DEB_GARCON_V)

	# garcon.mk Build cleanup
	rm -rf $(BUILD_DIST)/garcon

.PHONY: garcon garcon-package
