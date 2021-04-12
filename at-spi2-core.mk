ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += at-spi2-core
AT-SPI2-CORE_VERSION := 2.18.0
DEB_AT-SPI2-CORE_V   ?= $(AT-SPI2-CORE_VERSION)

at-spi2-core-setup: setup
	wget -q -nc -P$(BUILD_SOURCE) https://mirror.umd.edu/gnome/sources/at-spi2-core/2.18/at-spi2-core-2.18.0.tar.xz
	$(call EXTRACT_TAR,at-spi2-core-$(AT-SPI2-CORE_VERSION).tar.xz,at-spi2-core-$(AT-SPI2-CORE_VERSION),at-spi2-core)

ifneq ($(wildcard $(BUILD_WORK)/at-spi2-core/.build_complete),)
at-spi2-core:
	@echo "Using previously built at-spi2-core."
else
at-spi2-core: at-spi2-core-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/at-spi2-core && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--disable-dependency-tracking \
		--enable-gtk-doc-html \
		--with-x \
		--enable-introspection=no
	+$(MAKE) -C $(BUILD_WORK)/at-spi2-core
	+$(MAKE) -i -C $(BUILD_WORK)/at-spi2-core install \
		DESTDIR=$(BUILD_STAGE)/at-spi2-core
	+$(MAKE) -i -C $(BUILD_WORK)/at-spi2-core install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/at-spi2-core/.build_complete
endif

at-spi2-core-package: at-spi2-core-stage
	# at-spi2-core.mk Package Structure
	rm -rf $(BUILD_DIST)/at-spi2-core

	# at-spi2-core.mk Prep at-spi2-core
	cp -a $(BUILD_STAGE)/at-spi2-core $(BUILD_DIST)

	# at-spi2-core.mk Sign
	$(call SIGN,at-spi2-core,general.xml)

	# at-spi2-core.mk Make .debs
	$(call PACK,at-spi2-core,DEB_AT-SPI2-CORE_V)

	# at-spi2-core.mk Build cleanup
	rm -rf $(BUILD_DIST)/at-spi2-core

.PHONY: at-spi2-core at-spi2-core-package
