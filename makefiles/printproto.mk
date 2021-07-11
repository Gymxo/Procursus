ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += printproto
PRINTPROTO_VERSION := 1.0.5
DEB_PRINTPROTO_V   ?= $(PRINTPROTO_VERSION)

printproto-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/proto/printproto-$(PRINTPROTO_VERSION).tar.gz
	$(call EXTRACT_TAR,printproto-$(PRINTPROTO_VERSION).tar.gz,printproto-$(PRINTPROTO_VERSION),printproto)

ifneq ($(wildcard $(BUILD_WORK)/printproto/.build_complete),)
printproto:
	@echo "Using previously built printproto."
else
printproto: printproto-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/printproto && autoreconf -fiv && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS)
	+$(MAKE) -C $(BUILD_WORK)/printproto
	+$(MAKE) -C $(BUILD_WORK)/printproto install \
		DESTDIR=$(BUILD_STAGE)/printproto
	+$(MAKE) -C $(BUILD_WORK)/printproto install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/printproto/.build_complete
endif

printproto-package: printproto-stage
	# printproto.mk Package Structure
	rm -rf $(BUILD_DIST)/printproto

	# printproto.mk Prep printproto
	cp -a $(BUILD_STAGE)/printproto $(BUILD_DIST)

	# printproto.mk Sign
	$(call SIGN,printproto,general.xml)

	# printproto.mk Make .debs
	$(call PACK,printproto,DEB_PRINTPROTO_V)

	# printproto.mk Build cleanup
	rm -rf $(BUILD_DIST)/printproto

.PHONY: printproto printproto-package
