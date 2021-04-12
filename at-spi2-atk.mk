ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += at-spi2-atk
AT-SPI2-ATK_VERSION := 2.20.0
DEB_AT-SPI2-ATK_V   ?= $(AT-SPI2-ATK_VERSION)

at-spi2-atk-setup: setup
	wget -q -nc -P$(BUILD_SOURCE) https://download.gnome.org/sources/at-spi2-atk/2.20/at-spi2-atk-2.20.0.tar.xz
	$(call EXTRACT_TAR,at-spi2-atk-$(AT-SPI2-ATK_VERSION).tar.xz,at-spi2-atk-$(AT-SPI2-ATK_VERSION),at-spi2-atk)

ifneq ($(wildcard $(BUILD_WORK)/at-spi2-atk/.build_complete),)
at-spi2-atk:
	@echo "Using previously built at-spi2-atk."
else
at-spi2-atk: at-spi2-atk-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/at-spi2-atk && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--enable-introspection=no
	+$(MAKE) -C $(BUILD_WORK)/at-spi2-atk
	+$(MAKE) -C $(BUILD_WORK)/at-spi2-atk install \
		DESTDIR=$(BUILD_STAGE)/at-spi2-atk
	+$(MAKE) -C $(BUILD_WORK)/at-spi2-atk install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/at-spi2-atk/.build_complete
endif

at-spi2-atk-package: at-spi2-atk-stage
	# at-spi2-atk.mk Package Structure
	rm -rf $(BUILD_DIST)/at-spi2-atk

	# at-spi2-atk.mk Prep at-spi2-atk
	cp -a $(BUILD_STAGE)/at-spi2-atk $(BUILD_DIST)

	# at-spi2-atk.mk Sign
	$(call SIGN,at-spi2-atk,general.xml)

	# at-spi2-atk.mk Make .debs
	$(call PACK,at-spi2-atk,DEB_AT-SPI2-ATK_V)

	# at-spi2-atk.mk Build cleanup
	rm -rf $(BUILD_DIST)/at-spi2-atk

.PHONY: at-spi2-atk at-spi2-atk-package


