ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS      += zlib
ZLIB_VERSION  := 1.2.11
DEB_ZLIB_V    ?= $(ZLIB_VERSION)

zlib-setup: setup
	-wget -q -nc -P $(BUILD_SOURCE)  https://github.com/madler/zlib/archive/refs/tags/v1.2.11.tar.gz
	$(call EXTRACT_TAR,v$(ZLIB_VERSION).tar.gz,zlib-$(ZLIB_VERSION),zlib)
ifneq ($(wildcard $(BUILD_WORK)/zlib/.build_complete),)
zlib:
	@echo "Using previously built zlib."
else
zlib: zlib-setup
	cd $(BUILD_WORK)/zlib && cmake . \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_SYSTEM_NAME=Darwin \
		-DCMAKE_CROSSCOMPILING=true \
		-DCMAKE_INSTALL_NAME_TOOL=$(I_N_T) \
		-DCMAKE_INSTALL_PREFIX=/usr \
		-DCMAKE_INSTALL_NAME_DIR=/usr \
		-DCMAKE_INSTALL_RPATH=/usr \
		-DCMAKE_OSX_SYSROOT="$(TARGET_SYSROOT)" \
		-DCMAKE_C_FLAGS="$(CFLAGS)" \
		-DCMAKE_FIND_ROOT_PATH=$(BUILD_BASE) \
		-DCMAKE_OSX_ARCHITECTURES="$(MEMO_ARCH)" \
		.
	+$(MAKE) -C $(BUILD_WORK)/zlib
	+$(MAKE) -C $(BUILD_WORK)/zlib install \
		DESTDIR=$(BUILD_STAGE)/zlib
	+$(MAKE) -C $(BUILD_WORK)/zlib install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/zlib/.build_complete
endif
zlib-package: zlib-stage
	# zlib.mk Package Structure
	rm -rf $(BUILD_DIST)/zlib
		
	# zlib.mk Prep 
	cp -a $(BUILD_STAGE)/zlib $(BUILD_DIST)

	# zlib.mk Sign
	$(call SIGN,zlib,general.xml)
	
	# zlib.mk Make .debs
	$(call PACK,zlib,DEB_ZLIB_V)
	
	# zlib.mk Build cleanup
	rm -rf $(BUILD_DIST)/zlib

.PHONY: zlib zlib-package