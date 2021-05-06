ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += xinit
XINIT_VERSION := 1.4.1
DEB_XINIT_V   ?= $(XINIT_VERSION)

xinit-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive//individual/app/xinit-$(XINIT_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,xinit-$(XINIT_VERSION).tar.gz)
	$(call EXTRACT_TAR,xinit-$(XINIT_VERSION).tar.gz,xinit-$(XINIT_VERSION),xinit)

ifneq ($(wildcard $(BUILD_WORK)/xinit/.build_complete),)
xinit:
	@echo "Using previously built xinit."
else
xinit: xinit-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xinit && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-launchd \
		--with-xinitdir=/usr/lib/X11 \
		--with-xserver=/usr/bin/Xvnc
	+$(MAKE) -C $(BUILD_WORK)/xinit
	+$(MAKE) -C $(BUILD_WORK)/xinit install \
		DESTDIR=$(BUILD_STAGE)/xinit
	+$(MAKE) -C $(BUILD_WORK)/xinit install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xinit/.build_complete
endif

xinit-package: xinit-stage
# xinit.mk Package Structure
	rm -rf $(BUILD_DIST)/xinit
	
# xinit.mk Prep xinit
	cp -a $(BUILD_STAGE)/xinit $(BUILD_DIST)
	
# xinit.mk Sign
	$(call SIGN,xinit,general.xml)
	
# xinit.mk Make .debs
	$(call PACK,xinit,DEB_XINIT_V)
	
# xinit.mk Build cleanup
	rm -rf $(BUILD_DIST)/xinit

.PHONY: xinit xinit-package