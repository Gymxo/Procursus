ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += uwm
UWM_VERSION := 0.2.11a
DEB_UWM_V   ?= $(UWM_VERSION)

uwm-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://cfhcable.dl.sourceforge.net/project/udeproject/UWM/uwm-0.2.11a%20stable/uwm-0.2.11a.tar.gz
	$(call EXTRACT_TAR,uwm-$(UWM_VERSION).tar.gz,uwm-$(UWM_VERSION),uwm)

ifneq ($(wildcard $(BUILD_WORK)/uwm/.build_complete),)
uwm:
	@echo "Using previously built uwm."
else
uwm: uwm-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/uwm && export ac_cv_func_malloc_0_nonnull=yes && export ac_cv_func_realloc_0_nonnull=yes && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-x \
		--x-libraries=$(BUILD_BASE)/usr/lib \
		--x-includes=$(BUILD_BASE)/usr/include
	+$(MAKE) -C $(BUILD_WORK)/uwm
	+$(MAKE) -C $(BUILD_WORK)/uwm install \
		DESTDIR=$(BUILD_STAGE)/uwm
	+$(MAKE) -C $(BUILD_WORK)/uwm install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/uwm/.build_complete
endif

uwm-package: uwm-stage
	# uwm.mk Package Structure
	rm -rf $(BUILD_DIST)/uwm

	# uwm.mk Prep uwm
	cp -a $(BUILD_STAGE)/uwm $(BUILD_DIST)

	# uwm.mk Sign
	$(call SIGN,uwm,general.xml)

	# uwm.mk Make .debs
	$(call PACK,uwm,DEB_UWM_V)

	# uwm.mk Build cleanup
	rm -rf $(BUILD_DIST)/uwm

.PHONY: uwm uwm-package
