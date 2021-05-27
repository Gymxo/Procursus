ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += lxdm
LXDM_VERSION := 0.5.3
DEB_LXDM_V   ?= $(LXDM_VERSION)

lxdm-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://cfhcable.dl.sourceforge.net/project/lxdm/lxdm%20$(LXDM_VERSION)/lxdm-$(LXDM_VERSION).tar.xz
	$(call EXTRACT_TAR,lxdm-$(LXDM_VERSION).tar.xz,lxdm-$(LXDM_VERSION),lxdm)

ifneq ($(wildcard $(BUILD_WORK)/lxdm/.build_complete),)
lxdm:
	@echo "Using previously built lxdm."
else
lxdm: lxdm-setup libx11 gtk+3 libxcb
	cd $(BUILD_WORK)/lxdm && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--x-libraries=$(BUILD_BASE)/usr/lib \
		--x-includes=$(BUILD_BASE)/usr/include \
		--enable-gtk3 \
		--with-x \
		--without-pam \
		--enable-password \
		--disable-consolekit \
		--with-xconn=xlib
	+$(MAKE) -i -C $(BUILD_WORK)/lxdm
	+$(MAKE) -i -C $(BUILD_WORK)/lxdm install \
		DESTDIR=$(BUILD_STAGE)/lxdm
	+$(MAKE) -i -C $(BUILD_WORK)/lxdm install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/lxdm/.build_complete
endif

lxdm-package: lxdm-stage
	# lxdm.mk Package Structure
	rm -rf $(BUILD_DIST)/lxdm

	# lxdm.mk Prep lxdm
	cp -a $(BUILD_STAGE)/lxdm $(BUILD_DIST)

	# lxdm.mk Sign
	$(call SIGN,lxdm,general.xml)

	# lxdm.mk Make .debs
	$(call PACK,lxdm,DEB_LXDM_V)

	# lxdm.mk Build cleanup
	rm -rf $(BUILD_DIST)/lxdm

.PHONY: lxdm lxdm-package
