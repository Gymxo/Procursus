ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += xfm
XFM_VERSION := 1.3.2
DEB_XFM_V   ?= $(XFM_VERSION)

xfm-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.ibiblio.org/pub/linux/X11/desktop/xfm-1.3.2.tar.gz
	$(call EXTRACT_TAR,xfm-$(XFM_VERSION).tar.gz,xfm-$(XFM_VERSION),xfm)

ifneq ($(wildcard $(BUILD_WORK)/xfm/.build_complete),)
xfm:
	@echo "Using previously built xfm."
else
xfm: xfm-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xfm && imake
	+$(MAKE) -C $(BUILD_WORK)/xfm install \
		DESTDIR=$(BUILD_STAGE)/xfm
	+$(MAKE) -C $(BUILD_WORK)/xfm install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xfm/.build_complete
endif

xfm-package: xfm-stage
	# xfm.mk Package Structure
	rm -rf $(BUILD_DIST)/xfm

	# xfm.mk Prep xfm
	cp -a $(BUILD_STAGE)/xfm $(BUILD_DIST)

	# xfm.mk Sign
	$(call SIGN,xfm,general.xml)

	# xfm.mk Make .debs
	$(call PACK,xfm,DEB_XFM_V)

	# xfm.mk Build cleanup
	rm -rf $(BUILD_DIST)/xfm

.PHONY: xfm xfm-package
