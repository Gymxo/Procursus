ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += tkdesk
TKDESK_VERSION := 2.0
DEB_TKDESK_V   ?= $(TKDESK_VERSION)

tkdesk-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://phoenixnap.dl.sourceforge.net/project/tkdesk/TkDesk/2.0/tkdesk-2.0.tar.gz
	$(call EXTRACT_TAR,tkdesk-$(TKDESK_VERSION).tar.gz,tkdesk-$(TKDESK_VERSION),tkdesk)

ifneq ($(wildcard $(BUILD_WORK)/tkdesk/.build_complete),)
tkdesk:
	@echo "Using previously built tkdesk."
else
tkdesk: tkdesk-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/tkdesk && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS)
	+$(MAKE) -i -C $(BUILD_WORK)/tkdesk
	+$(MAKE) -i -C $(BUILD_WORK)/tkdesk install \
		DESTDIR=$(BUILD_STAGE)/tkdesk
	+$(MAKE) -i -C $(BUILD_WORK)/tkdesk install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/tkdesk/.build_complete
endif

tkdesk-package: tkdesk-stage
	# tkdesk.mk Package Structure
	rm -rf $(BUILD_DIST)/tkdesk

	# tkdesk.mk Prep tkdesk
	cp -a $(BUILD_STAGE)/tkdesk $(BUILD_DIST)

	# tkdesk.mk Sign
	$(call SIGN,tkdesk,general.xml)

	# tkdesk.mk Make .debs
	$(call PACK,tkdesk,DEB_TKDESK_V)

	# tkdesk.mk Build cleanup
	rm -rf $(BUILD_DIST)/tkdesk

.PHONY: tkdesk tkdesk-package
