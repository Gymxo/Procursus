ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += accountsservice
ACCOUNTSSERVICE_VERSION := 0.6.42
DEB_ACCOUNTSSERVICE_V   ?= $(ACCOUNTSSERVICE_VERSION)

accountsservice-setup: setup
	wget -q -nc -P$(BUILD_SOURCE) https://www.freedesktop.org/software/accountsservice/accountsservice-0.6.42.tar.xz
	$(call EXTRACT_TAR,accountsservice-$(ACCOUNTSSERVICE_VERSION).tar.xz,accountsservice-$(ACCOUNTSSERVICE_VERSION),accountsservice)

ifneq ($(wildcard $(BUILD_WORK)/accountsservice/.build_complete),)
accountsservice:
	@echo "Using previously built accountsservice."
else
accountsservice: accountsservice-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/accountsservice && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--enable-introspection=no \
		--disable-systemd \
        --disable-silent-rule
	+$(MAKE) -C $(BUILD_WORK)/accountsservice
	+$(MAKE) -C $(BUILD_WORK)/accountsservice install \
		DESTDIR=$(BUILD_STAGE)/accountsservice
	+$(MAKE) -C $(BUILD_WORK)/accountsservice install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/accountsservice/.build_complete
endif

accountsservice-package: accountsservice-stage
	# accountsservice.mk Package Structure
	rm -rf $(BUILD_DIST)/accountsservice

	# accountsservice.mk Prep accountsservice
	cp -a $(BUILD_STAGE)/accountsservice $(BUILD_DIST)

	# accountsservice.mk Sign
	$(call SIGN,accountsservice,general.xml)

	# accountsservice.mk Make .debs
	$(call PACK,accountsservice,DEB_ACCOUNTSSERVICE_V)

	# accountsservice.mk Build cleanup
	rm -rf $(BUILD_DIST)/accountsservice

.PHONY: accountsservice accountsservice-package
