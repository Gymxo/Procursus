ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += atk
ATK_VERSION := 2.18.0
DEB_ATK_V   ?= $(ATK_VERSION)

atk-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://download.gnome.org/sources/atk/2.18/atk-2.18.0.tar.xz
	$(call EXTRACT_TAR,atk-$(ATK_VERSION).tar.xz,atk-$(ATK_VERSION),atk)

ifneq ($(wildcard $(BUILD_WORK)/atk/.build_complete),)
atk:
	@echo "Using previously built atk."
else
atk: atk-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/atk && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--enable-introspection=no
	+$(MAKE) -C $(BUILD_WORK)/atk
	+$(MAKE) -C $(BUILD_WORK)/atk install \
		DESTDIR=$(BUILD_STAGE)/atk
	+$(MAKE) -C $(BUILD_WORK)/atk install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/atk/.build_complete
endif

atk-package: atk-stage
	# atk.mk Package Structure
	rm -rf $(BUILD_DIST)/atk

	# atk.mk Prep atk
	cp -a $(BUILD_STAGE)/atk $(BUILD_DIST)

	# atk.mk Sign
	$(call SIGN,atk,general.xml)

	# atk.mk Make .debs
	$(call PACK,atk,DEB_ATK_V)

	# atk.mk Build cleanup
	rm -rf $(BUILD_DIST)/atk

.PHONY: atk atk-package
