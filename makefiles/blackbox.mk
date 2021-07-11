ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += blackbox
BLACKBOX_VERSION := 0.76
DEB_BLACKBOX_V   ?= $(BLACKBOX_VERSION)

blackbox-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://github.com/bbidulock/blackboxwm/archive/refs/tags/0.76.tar.gz
	$(call EXTRACT_TAR,$(BLACKBOX_VERSION).tar.gz,blackboxwm-$(BLACKBOX_VERSION),blackbox)

ifneq ($(wildcard $(BUILD_WORK)/blackbox/.build_complete),)
blackbox:
	@echo "Using previously built blackbox."
else
blackbox: blackbox-setup libx11 libxau libxmu xorgproto libfribidi
	cd $(BUILD_WORK)/blackbox && ./autogen.sh && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=/etc \
		--localstatedir=/var
	+$(MAKE) -C $(BUILD_WORK)/blackbox
	+$(MAKE) -C $(BUILD_WORK)/blackbox DESTDIR="$pkgdir" install \
		DESTDIR=$(BUILD_STAGE)/blackbox
	+$(MAKE) -C $(BUILD_WORK)/blackbox DESTDIR="$pkgdir" install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/blackbox/.build_complete
endif

blackbox-package: blackbox-stage
# blackbox.mk Package Structure
	rm -rf $(BUILD_DIST)/blackbox
	
# blackbox.mk Prep blackbox
	cp -a $(BUILD_STAGE)/blackbox $(BUILD_DIST)
	
# blackbox.mk Sign
	$(call SIGN,blackbox,general.xml)
	
# blackbox.mk Make .debs
	$(call PACK,blackbox,DEB_BLACKBOX_V)
	
# blackbox.mk Build cleanup
	rm -rf $(BUILD_DIST)/blackbox

.PHONY: blackbox blackbox-package