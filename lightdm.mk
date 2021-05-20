ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += lightdm
LIGHTDM_VERSION := 1.30.0
DEB_LIGHTDM_V   ?= $(LIGHTDM_VERSION)

lightdm-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://github.com/canonical/lightdm/releases/download/1.30.0/lightdm-1.30.0.tar.xz
	$(call EXTRACT_TAR,lightdm-$(LIGHTDM_VERSION).tar.xz,lightdm-$(LIGHTDM_VERSION),lightdm)

ifneq ($(wildcard $(BUILD_WORK)/lightdm/.build_complete),)
lightdm:
	@echo "Using previously built lightdm."
else
lightdm: lightdm-setup libx11 libxau libxmu xorgproto xxhash libgcrypt
	cd $(BUILD_WORK)/lightdm && ./autogen.sh -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-user-session=Procursus \
		--with-greeter-user=mobile \
		--disable-tests \
		--enable-introspection=no
	+$(MAKE) -C $(BUILD_WORK)/lightdm
	+$(MAKE) -C $(BUILD_WORK)/lightdm install \
		DESTDIR=$(BUILD_STAGE)/lightdm
	+$(MAKE) -C $(BUILD_WORK)/lightdm install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/lightdm/.build_complete
endif

lightdm-package: lightdm-stage
	# lightdm.mk Package Structure
	rm -rf $(BUILD_DIST)/lightdm

	# lightdm.mk Prep lightdm
	cp -a $(BUILD_STAGE)/lightdm $(BUILD_DIST)

	# lightdm.mk Sign
	$(call SIGN,lightdm,general.xml)

	# lightdm.mk Make .debs
	$(call PACK,lightdm,DEB_LIGHTDM_V)

	# lightdm.mk Build cleanup
	rm -rf $(BUILD_DIST)/lightdm

.PHONY: lightdm lightdm-package
