ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += xmnllib
XMNLLIB_VERSION := 0.94
DEB_XMNLLIB_V   ?= $(XMNLLIB_VERSION)

xmnllib-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://master.dl.sourceforge.net/project/xmnllib/XmNllib-0.94.tar.gz
	$(call EXTRACT_TAR,XmNllib-$(XMNLLIB_VERSION).tar.gz,XmNllib-$(XMNLLIB_VERSION),xmnllib)

ifneq ($(wildcard $(BUILD_WORK)/xmnllib/.build_complete),)
xmnllib:
	@echo "Using previously built xmnllib."
else
xmnllib: xmnllib-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xmnllib && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--disable-dependency-tracking
	+$(MAKE) -C $(BUILD_WORK)/xmnllib
	+$(MAKE) -C $(BUILD_WORK)/xmnllib install \
		DESTDIR=$(BUILD_STAGE)/xmnllib
	+$(MAKE) -C $(BUILD_WORK)/xmnllib install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xmnllib/.build_complete
endif

xmnllib-package: xmnllib-stage
	# xmnllib.mk Package Structure
	rm -rf $(BUILD_DIST)/xmnllib

	# xmnllib.mk Prep xmnllib
	cp -a $(BUILD_STAGE)/xmnllib $(BUILD_DIST)

	# xmnllib.mk Sign
	$(call SIGN,xmnllib,general.xml)

	# xmnllib.mk Make .debs
	$(call PACK,xmnllib,DEB_XMNLLIB_V)

	# xmnllib.mk Build cleanup
	rm -rf $(BUILD_DIST)/xmnllib

.PHONY: xmnllib xmnllib-package
