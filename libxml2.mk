ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += libxml2
LIBXML2_VERSION := 2.9.10
DEB_LIBXML2_V   ?= $(LIBXML2_VERSION)

libxml2-setup: setup bison glib2.0
	wget -q -nc -P$(BUILD_SOURCE) https://ftp.osuosl.org/pub/blfs/conglomeration/libxml2/libxml2-2.9.10.tar.gz
	$(call EXTRACT_TAR,libxml2-$(LIBXML2_VERSION).tar.gz,libxml2-$(LIBXML2_VERSION),libxml2)

ifneq ($(wildcard $(BUILD_WORK)/libxml2/.build_complete),)
libxml2:
	@echo "Using previously built libxml2."
else
libxml2: libxml2-setup libx11 mesa
	cd $(BUILD_WORK)/libxml2 && autoreconf -fiv && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--disable-dependency-tracking
	+$(MAKE) -C $(BUILD_WORK)/libxml2
	+$(MAKE) -C $(BUILD_WORK)/libxml2 install \
		DESTDIR=$(BUILD_STAGE)/libxml2
	+$(MAKE) -C $(BUILD_WORK)/libxml2 install \
		DESTDIR="$(BUILD_BASE)"
	touch $(BUILD_WORK)/libxml2/.build_complete
endif

libxml2-package: libxml2-stage
	# libxml2.mk Package Structure
	rm -rf $(BUILD_DIST)/libxml2
	mkdir -p $(BUILD_DIST)/libxml2
	
	# libxml2.mk Prep libxml2
	cp -a $(BUILD_STAGE)/libxml2 $(BUILD_DIST)
	
	# libxml2.mk Sign
	$(call SIGN,libxml2,general.xml)
	
	# libxml2.mk Make .debs
	$(call PACK,libxml2,DEB_LIBXML2_V)
	
	# libxml2.mk Build cleanup
	rm -rf $(BUILD_DIST)/libxml2

.PHONY: libxml2 libxml2-package