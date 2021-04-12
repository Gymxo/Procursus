ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += dos2unix
DOS2UNIX_VERSION := 7.4.2
DEB_DOS2UNIX_V   ?= $(DOS2UNIX_VERSION)

dos2unix-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://iweb.dl.sourceforge.net/project/dos2unix/dos2unix/7.4.2/dos2unix-7.4.2.tar.gz
	$(call EXTRACT_TAR,dos2unix-$(DOS2UNIX_VERSION).tar.gz,dos2unix-$(DOS2UNIX_VERSION),dos2unix)

ifneq ($(wildcard $(BUILD_WORK)/dos2unix/.build_complete),)
dos2unix:
	@echo "Using previously built dos2unix."
else
dos2unix: dos2unix-setup libx11 libxau libxmu xorgproto xxhash
	+$(MAKE) -C $(BUILD_WORK)/dos2unix
	+$(MAKE) -C $(BUILD_WORK)/dos2unix install \
		DESTDIR=$(BUILD_STAGE)/dos2unix
	+$(MAKE) -C $(BUILD_WORK)/dos2unix install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/dos2unix/.build_complete
endif

dos2unix-package: dos2unix-stage
# dos2unix.mk Package Structure
	rm -rf $(BUILD_DIST)/dos2unix
	
# dos2unix.mk Prep dos2unix
	cp -a $(BUILD_STAGE)/dos2unix $(BUILD_DIST)
	
# dos2unix.mk Sign
	$(call SIGN,dos2unix,general.xml)
	
# dos2unix.mk Make .debs
	$(call PACK,dos2unix,DEB_DOS2UNIX_V)
	
# dos2unix.mk Build cleanup
	rm -rf $(BUILD_DIST)/dos2unix

.PHONY: dos2unix dos2unix-package
