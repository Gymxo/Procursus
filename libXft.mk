ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

<<<<<<< HEAD
SUBPROJECTS    += libXft
LIBXFT_VERSION := 2.3.3
DEB_LIBXFT_V   ?= $(LIBXFT_VERSION)

libXft-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/lib/libXft-$(LIBXFT_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,libXft-$(LIBXFT_VERSION).tar.gz)
	$(call EXTRACT_TAR,libXft-$(LIBXFT_VERSION).tar.gz,libXft-$(LIBXFT_VERSION),libXft)

ifneq ($(wildcard $(BUILD_WORK)/libXft/.build_complete),)
libXft:
	@echo "Using previously built libXft."
else
libXft: libXft-setup libx11 libxau libxmu xorgproto fontconfig freetype
	cd $(BUILD_WORK)/libXft && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var
	+$(MAKE) -C $(BUILD_WORK)/libXft
	+$(MAKE) -C $(BUILD_WORK)/libXft install \
		DESTDIR=$(BUILD_STAGE)/libXft
	+$(MAKE) -C $(BUILD_WORK)/libXft install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/libXft/.build_complete
endif

libXft-package: libXft-stage
# libXft.mk Package Structure
	rm -rf $(BUILD_DIST)/libXft
	
# libXft.mk Prep libXft
	cp -a $(BUILD_STAGE)/libXft $(BUILD_DIST)
	
# libXft.mk Sign
	$(call SIGN,libXft,general.xml)
	
# libXft.mk Make .debs
	$(call PACK,libXft,DEB_LIBXFT_V)
	
# libXft.mk Build cleanup
	rm -rf $(BUILD_DIST)/libXft

.PHONY: libXft libXft-package
=======
SUBPROJECTS    += libxft
LIBXFT_VERSION := 2.3.3
DEB_LIBXFT_V   ?= $(LIBXFT_VERSION)

libxft-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/lib/libXft-$(LIBXFT_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,libXft-$(LIBXFT_VERSION).tar.gz)
	$(call EXTRACT_TAR,libXft-$(LIBXFT_VERSION).tar.gz,libXft-$(LIBXFT_VERSION),libxft)

ifneq ($(wildcard $(BUILD_WORK)/libxft/.build_complete),)
libxft:
	@echo "Using previously built libxft."
else
libxft: libxft-setup libx11 libxau libxmu xorgproto fontconfig freetype
	cd $(BUILD_WORK)/libxft && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS)
	+$(MAKE) -C $(BUILD_WORK)/libxft
	+$(MAKE) -C $(BUILD_WORK)/libxft install \
		DESTDIR=$(BUILD_STAGE)/libxft
	+$(MAKE) -C $(BUILD_WORK)/libxft install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/libxft/.build_complete
endif

libxft-package: libxft-stage
# libxft.mk Package Structure
	rm -rf $(BUILD_DIST)/libxft
	
# libxft.mk Prep libxft
	cp -a $(BUILD_STAGE)/libxft $(BUILD_DIST)
	
# libxft.mk Sign
	$(call SIGN,libxft,general.xml)
	
# libxft.mk Make .debs
	$(call PACK,libxft,DEB_LIBXFT_V)
	
# libxft.mk Build cleanup
	rm -rf $(BUILD_DIST)/libxft

.PHONY: libxft libxft-package
>>>>>>> b3101346967d65d30c8678c524e834b1862b3ab0
