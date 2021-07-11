ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += lxsession
LXSESSION_VERSION := 0.5.5
DEB_LXSESSION_V   ?= $(LXSESSION_VERSION)

lxsession-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://github.com/lxde/lxsession/archive/refs/tags/$(LXSESSION_VERSION).tar.gz
	$(call EXTRACT_TAR,$(LXSESSION_VERSION).tar.gz,lxsession-$(LXSESSION_VERSION),lxsession)

ifneq ($(wildcard $(BUILD_WORK)/lxsession/.build_complete),)
lxsession:
	find $(BUILD_STAGE)/lxsession -type f -exec codesign --remove {} \; &> /dev/null; \
	find $(BUILD_STAGE)/lxsession -type f -exec codesign --sign $(CODESIGN_IDENTITY) --force --preserve-metadata=entitlements,requirements,flags,runtime {} \; &> /dev/null
	@echo "Using previously built lxsession."
else
lxsession: lxsession-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/lxsession && autoreconf -fiv && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--enable-buildin-polkit \
		--enable-gtk3 \
		--enable-gtk \
		--disable-man
	+$(MAKE) -C $(BUILD_WORK)/lxsession
	+$(MAKE) -C $(BUILD_WORK)/lxsession install \
		DESTDIR=$(BUILD_STAGE)/lxsession
	+$(MAKE) -C $(BUILD_WORK)/lxsession install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/lxsession/.build_complete
endif

lxsession-package: lxsession-stage
	# lxsession.mk Package Structure
	rm -rf $(BUILD_DIST)/lxsession

	# lxsession.mk Prep lxsession
	cp -a $(BUILD_STAGE)/lxsession $(BUILD_DIST)

	# lxsession.mk Sign
	$(call SIGN,lxsession,general.xml)

	# lxsession.mk Make .debs
	$(call PACK,lxsession,DEB_LXSESSION_V)

	# lxsession.mk Build cleanup
	rm -rf $(BUILD_DIST)/lxsession

.PHONY: lxsession lxsession-package
