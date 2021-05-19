ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += openbox
OPENBOX_VERSION := 3.6.1
DEB_OPENBOX_V   ?= $(OPENBOX_VERSION)

openbox-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) http://openbox.org/dist/openbox/openbox-3.6.1.tar.gz
	$(call EXTRACT_TAR,openbox-$(OPENBOX_VERSION).tar.gz,openbox-$(OPENBOX_VERSION),openbox)

ifneq ($(wildcard $(BUILD_WORK)/openbox/.build_complete),)
openbox:
	@echo "Using previously built openbox."
else
openbox: openbox-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/openbox && autoreconf -fi && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--x-libraries=$(BUILD_BASE)/usr/lib \
		--x-includes=$(BUILD_BASE)/usr/include \
		--with-x \
		--disable-startup-notification \
		--disable-rpath
	+$(MAKE) -C $(BUILD_WORK)/openbox
	+$(MAKE) -C $(BUILD_WORK)/openbox install \
		DESTDIR=$(BUILD_STAGE)/openbox
	+$(MAKE) -C $(BUILD_WORK)/openbox install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/openbox/.build_complete
endif

openbox-package: openbox-stage
# openbox.mk Package Structure
	rm -rf $(BUILD_DIST)/openbox
	
# openbox.mk Prep openbox
	cp -a $(BUILD_STAGE)/openbox $(BUILD_DIST)
	
# openbox.mk Sign
	$(call SIGN,openbox,general.xml)
	
# openbox.mk Make .debs
	$(call PACK,openbox,DEB_OPENBOX_V)
	
# openbox.mk Build cleanup
	rm -rf $(BUILD_DIST)/openbox

.PHONY: openbox openbox-package