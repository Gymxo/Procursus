ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += xinput
XINPUT_VERSION := 1.6.3
DEB_XINPUT_V   ?= $(XINPUT_VERSION)

xinput-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/app/xinput-$(XINPUT_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,xinput-$(XINPUT_VERSION).tar.gz)
	$(call EXTRACT_TAR,xinput-$(XINPUT_VERSION).tar.gz,xinput-$(XINPUT_VERSION),xinput)

ifneq ($(wildcard $(BUILD_WORK)/xinput/.build_complete),)
xinput:
	@echo "Using previously built xinput."
else
xinput: xinput-setup libx11 libxi libxrandr
	cd $(BUILD_WORK)/xinput && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS)
	+$(MAKE) -C $(BUILD_WORK)/xinput
	+$(MAKE) -C $(BUILD_WORK)/xinput install \
		DESTDIR=$(BUILD_STAGE)/xinput
	+$(MAKE) -C $(BUILD_WORK)/xinput install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xinput/.build_complete
endif

xinput-package: xinput-stage
	# xinput.mk Package Structure
	rm -rf $(BUILD_DIST)/xinput

	# xinput.mk Prep xinput
	cp -a $(BUILD_STAGE)/xinput $(BUILD_DIST)

	# xinput.mk Sign
	$(call SIGN,xinput,general.xml)

	# xinput.mk Make .debs
	$(call PACK,xinput,DEB_XINPUT_V)

	# xinput.mk Build cleanup
	rm -rf $(BUILD_DIST)/xinput

.PHONY: xinput xinput-package
