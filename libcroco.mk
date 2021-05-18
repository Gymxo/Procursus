ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += libcroco
LIBCROCO_VERSION := 0.6.9
DEB_LIBCROCO_V   ?= $(LIBCROCO_VERSION)

libcroco-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://download.gnome.org/sources/libcroco/0.6/libcroco-0.6.9.tar.xz
	$(call EXTRACT_TAR,libcroco-$(LIBCROCO_VERSION).tar.xz,libcroco-$(LIBCROCO_VERSION),libcroco)

ifneq ($(wildcard $(BUILD_WORK)/libcroco/.build_complete),)
libcroco:
	@echo "Using previously built libcroco."
else
libcroco: libcroco-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/libcroco && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--disable-Bsymbolic
	+$(MAKE) -C $(BUILD_WORK)/libcroco
	+$(MAKE) -C $(BUILD_WORK)/libcroco install \
		DESTDIR=$(BUILD_STAGE)/libcroco
	+$(MAKE) -C $(BUILD_WORK)/libcroco install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/libcroco/.build_complete
endif

libcroco-package: libcroco-stage
# libcroco.mk Package Structure
	rm -rf $(BUILD_DIST)/libcroco
	
# libcroco.mk Prep libcroco
	cp -a $(BUILD_STAGE)/libcroco $(BUILD_DIST)
	
# libcroco.mk Sign
	$(call SIGN,libcroco,general.xml)
	
# libcroco.mk Make .debs
	$(call PACK,libcroco,DEB_LIBCROCO_V)
	
# libcroco.mk Build cleanup
	rm -rf $(BUILD_DIST)/libcroco

.PHONY: libcroco libcroco-package