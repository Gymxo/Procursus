ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

ifneq ($(wildcard $(BUILD_WORK)/xkeyboard-config/.build_complete),)
xkeyboard-config:
	@echo "Using previously built xkeyboard-config."
else
xkeyboard-config: xkeyboard-config-setup xorgproto
	cd $(BUILD_WORK)/xkeyboard-config && ./configure \
		$(DEFAULT_CONFIGURE_FLAGS)
	+$(MAKE) -C $(BUILD_WORK)/xkeyboard-config
	+$(MAKE) -C $(BUILD_WORK)/xkeyboard-config install \
		DESTDIR=$(BUILD_STAGE)/xkeyboard-config
	+$(MAKE) -C $(BUILD_WORK)/xkeyboard-config install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xkeyboard-config/.build_complete
endif

xkeyboard-config-package: xkeyboard-config-stage
	# xkeyboard-config.mk Package Structure
	rm -rf $(BUILD_DIST)/xkeyboard-config

	# xkeyboard-config.mk Prep xkeyboard-config
	cp -a $(BUILD_STAGE)/xkeyboard-config $(BUILD_DIST)

	# xkeyboard-config.mk Sign
	$(call SIGN,xkeyboard-config,general.xml)

	# xkeyboard-config.mk Make .debs
	$(call PACK,xkeyboard-config,DEB_XKEYBOARD-CONFIG_V)

	# xkeyboard-config.mk Build cleanup
	rm -rf $(BUILD_DIST)/xkeyboard-config

.PHONY: xkeyboard-config xkeyboard-config-package
