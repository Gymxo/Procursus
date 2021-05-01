ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += iso-codes
ISO_CODES_VERSION := 4.6.0
DEB_ISO_CODES_V   ?= $(ISO_CODES_VERSION)

iso-codes-setup: setup bison glib2.0
	wget -q -nc -P$(BUILD_SOURCE) https://deb.debian.org/debian/pool/main/i/iso-codes/iso-codes_4.6.0.orig.tar.xz
	$(call EXTRACT_TAR,iso-codes_$(ISO_CODES_VERSION).orig.tar.xz,iso-codes-$(ISO_CODES_VERSION),iso-codes)

ifneq ($(wildcard $(BUILD_WORK)/iso-codes/.build_complete),)
iso-codes:
	@echo "Using previously built iso-codes."
else
iso-codes: iso-codes-setup libx11 mesa
	cd $(BUILD_WORK)/iso-codes && autoreconf -fiv && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--disable-dependency-tracking
	+$(MAKE) -C $(BUILD_WORK)/iso-codes
	+$(MAKE) -C $(BUILD_WORK)/iso-codes install \
		DESTDIR=$(BUILD_STAGE)/iso-codes
	+$(MAKE) -C $(BUILD_WORK)/iso-codes install \
		DESTDIR="$(BUILD_BASE)"
	touch $(BUILD_WORK)/iso-codes/.build_complete
endif

iso-codes-package: iso-codes-stage
	# iso-codes.mk Package Structure
	rm -rf $(BUILD_DIST)/iso-codes
	mkdir -p $(BUILD_DIST)/iso-codes
	
	# iso-codes.mk Prep iso-codes
	cp -a $(BUILD_STAGE)/iso-codes $(BUILD_DIST)
	
	# iso-codes.mk Sign
	$(call SIGN,iso-codes,general.xml)
	
	# iso-codes.mk Make .debs
	$(call PACK,iso-codes,DEB_ISO_CODES_V)
	
	# iso-codes.mk Build cleanup
	rm -rf $(BUILD_DIST)/iso-codes

.PHONY: iso-codes iso-codes-package