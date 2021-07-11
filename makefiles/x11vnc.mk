ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += x11vnc
X11VNC_VERSION := 0.9.16
DEB_X11VNC_V   ?= $(X11VNC_VERSION)

x11vnc-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://github.com/LibVNC/x11vnc/archive/refs/tags/$(X11VNC_VERSION).tar.gz
	$(call EXTRACT_TAR,0.9.16.tar.gz,x11vnc-$(X11VNC_VERSION),x11vnc)
	$(call DO_PATCH,x11vnc,x11vnc,-p1)

ifneq ($(wildcard $(BUILD_WORK)/x11vnc/.build_complete),)
x11vnc:
	@echo "Using previously built x11vnc."
else
x11vnc: x11vnc-setup libx11 libxau libxmu xorgproto openssl libvncserver
	cd $(BUILD_WORK)/x11vnc && ./autogen.sh -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var \
		--with-x
	+$(MAKE) -C $(BUILD_WORK)/x11vnc
	+$(MAKE) -C $(BUILD_WORK)/x11vnc install \
		DESTDIR=$(BUILD_STAGE)/x11vnc
	+$(MAKE) -C $(BUILD_WORK)/x11vnc install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/x11vnc/.build_complete
endif

x11vnc-package: x11vnc-stage
# x11vnc.mk Package Structure
	rm -rf $(BUILD_DIST)/x11vnc
	
# x11vnc.mk Prep x11vnc
	cp -a $(BUILD_STAGE)/x11vnc $(BUILD_DIST)
	
# x11vnc.mk Sign
	$(call SIGN,x11vnc,general.xml)
	
# x11vnc.mk Make .debs
	$(call PACK,x11vnc,DEB_X11VNC_V)
	
# x11vnc.mk Build cleanup
	rm -rf $(BUILD_DIST)/x11vnc

.PHONY: x11vnc x11vnc-package