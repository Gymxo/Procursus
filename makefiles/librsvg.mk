ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += librsvg
LIBRSVG_VERSION := 2.47.0
DEB_LIBRSVG_V   ?= $(LIBRSVG_VERSION)

librsvg-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://download.gnome.org/sources/librsvg/2.47/librsvg-$(LIBRSVG_VERSION).tar.xz
	$(call EXTRACT_TAR,librsvg-$(LIBRSVG_VERSION).tar.xz,librsvg-$(LIBRSVG_VERSION),librsvg)

ifneq ($(wildcard $(BUILD_WORK)/librsvg/.build_complete),)
librsvg:
	@echo "Using previously built librsvg."
else
librsvg: librsvg-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/librsvg && RUST_TARGET=$(RUST_TARGET) ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--disable-Bsymbolic \
		--enable-introspection=no \
		--enable-vala=no \
		--disable-tools \
		--enable-pixbuf-loader \
		PROFILE=release \
		LIBS="-framework Security -framework Foundation"
	+$(MAKE) -i -C $(BUILD_WORK)/librsvg
	+$(MAKE) -i -C $(BUILD_WORK)/librsvg install \
		DESTDIR=$(BUILD_STAGE)/librsvg
	+$(MAKE) -i -C $(BUILD_WORK)/librsvg install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/librsvg/.build_complete
endif

librsvg-package: librsvg-stage
# librsvg.mk Package Structure
	rm -rf $(BUILD_DIST)/librsvg
	
# librsvg.mk Prep librsvg
	cp -a $(BUILD_STAGE)/librsvg $(BUILD_DIST)
	
# librsvg.mk Sign
	$(call SIGN,librsvg,general.xml)
	
# librsvg.mk Make .debs
	$(call PACK,librsvg,DEB_LIBRSVG_V)
	
# librsvg.mk Build cleanup
	rm -rf $(BUILD_DIST)/librsvg

.PHONY: librsvg librsvg-package