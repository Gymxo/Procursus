ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += libXinerama
LIBXINERAMA_VERSION := 1.1.4
DEB_LIBXINERAMA_V   ?= $(LIBXINERAMA_VERSION)

libXinerama-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/lib/libXinerama-$(LIBXINERAMA_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,libXinerama-$(LIBXINERAMA_VERSION).tar.gz)
	$(call EXTRACT_TAR,libXinerama-$(LIBXINERAMA_VERSION).tar.gz,libXinerama-$(LIBXINERAMA_VERSION),libXinerama)

ifneq ($(wildcard $(BUILD_WORK)/libXinerama/.build_complete),)
libXinerama:
	@echo "Using previously built libXinerama."
else
libXinerama: libXinerama-setup libx11 libxau libxmu xorgproto 
	cd $(BUILD_WORK)/libXinerama && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var \
		--enable-malloc0returnsnull=no
	+$(MAKE) -C $(BUILD_WORK)/libXinerama
	+$(MAKE) -C $(BUILD_WORK)/libXinerama install \
		DESTDIR=$(BUILD_STAGE)/libXinerama
	+$(MAKE) -C $(BUILD_WORK)/libXinerama install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/libXinerama/.build_complete
endif

libXinerama-package: libXinerama-stage
# libXinerama.mk Package Structure
	rm -rf $(BUILD_DIST)/libXinerama
	
# libXinerama.mk Prep libXinerama
	cp -a $(BUILD_STAGE)/libXinerama $(BUILD_DIST)
	
# libXinerama.mk Sign
	$(call SIGN,libXinerama,general.xml)
	
# libXinerama.mk Make .debs
	$(call PACK,libXinerama,DEB_LIBXINERAMA_V)
	
# libXinerama.mk Build cleanup
	rm -rf $(BUILD_DIST)/libXinerama

.PHONY: libXinerama libXinerama-package