ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += libvncserver
LIBVNCSERVER_VERSION := 0.9.13
DEB_LIBVNCSERVER_V   ?= $(LIBVNCSERVER_VERSION)

libvncserver-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://github.com/LibVNC/libvncserver/archive/refs/tags/LibVNCServer-0.9.13.tar.gz
	$(call EXTRACT_TAR,LibVNCServer-$(LIBVNCSERVER_VERSION).tar.gz,libvncserver-LibVNCServer-$(LIBVNCSERVER_VERSION),libvncserver)

ifneq ($(wildcard $(BUILD_WORK)/libvncserver/.build_complete),)
libvncserver:
	@echo "Using previously built libvncserver."
else
libvncserver: libvncserver-setup libx11 libxau libxmu xorgproto openssl libjpeg-turbo gnutls
	cd $(BUILD_WORK)/libvncserver && cmake . \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_SYSTEM_NAME=Darwin \
		-DCMAKE_CROSSCOMPILING=true \
		-DCMAKE_INSTALL_PREFIX=/ \
		-DCMAKE_INSTALL_NAME_DIR=/usr/lib \
		-DCMAKE_OSX_SYSROOT="$(TARGET_SYSROOT)" \
		-DCMAKE_FIND_ROOT_PATH=$(BUILD_BASE) \
		-DCMAKE_INSTALL_RPATH=/usr 
	+$(MAKE) -C $(BUILD_WORK)/libvncserver
	+$(MAKE) -C $(BUILD_WORK)/libvncserver install \
		DESTDIR=$(BUILD_STAGE)/libvncserver
	+$(MAKE) -C $(BUILD_WORK)/libvncserver install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/libvncserver/.build_complete
endif

libvncserver-package: libvncserver-stage
# libvncserver.mk Package Structure
	rm -rf $(BUILD_DIST)/libvncserver
	
# libvncserver.mk Prep libvncserver
	cp -a $(BUILD_STAGE)/libvncserver $(BUILD_DIST)
	
# libvncserver.mk Sign
	$(call SIGN,libvncserver,general.xml)
	
# libvncserver.mk Make .debs
	$(call PACK,libvncserver,DEB_LIBVNCSERVER_V)
	
# libvncserver.mk Build cleanup
	rm -rf $(BUILD_DIST)/libvncserver

.PHONY: libvncserver libvncserver-package