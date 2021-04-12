ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

<<<<<<< HEAD
SUBPROJECTS    += xkbcomp
=======
SUBPROJECTS     += xkbcomp
>>>>>>> b3101346967d65d30c8678c524e834b1862b3ab0
XKBCOMP_VERSION := 1.4.5
DEB_XKBCOMP_V   ?= $(XKBCOMP_VERSION)

xkbcomp-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://www.x.org/archive/individual/app/xkbcomp-$(XKBCOMP_VERSION).tar.gz{,.sig}
	$(call PGP_VERIFY,xkbcomp-$(XKBCOMP_VERSION).tar.gz)
	$(call EXTRACT_TAR,xkbcomp-$(XKBCOMP_VERSION).tar.gz,xkbcomp-$(XKBCOMP_VERSION),xkbcomp)

ifneq ($(wildcard $(BUILD_WORK)/xkbcomp/.build_complete),)
xkbcomp:
	@echo "Using previously built xkbcomp."
else
<<<<<<< HEAD
xkbcomp: xkbcomp-setup libx11 libxau libxmu xorgproto libxkbfile
	cd $(BUILD_WORK)/xkbcomp && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=$(MEMO_PREFIX)$(MEMO_SUB_PREFIX) \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var
=======
xkbcomp: xkbcomp-setup libx11 xorgproto libxkbfile
	cd $(BUILD_WORK)/xkbcomp && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS)
>>>>>>> b3101346967d65d30c8678c524e834b1862b3ab0
	+$(MAKE) -C $(BUILD_WORK)/xkbcomp
	+$(MAKE) -C $(BUILD_WORK)/xkbcomp install \
		DESTDIR=$(BUILD_STAGE)/xkbcomp
	+$(MAKE) -C $(BUILD_WORK)/xkbcomp install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xkbcomp/.build_complete
endif

xkbcomp-package: xkbcomp-stage
<<<<<<< HEAD
# xkbcomp.mk Package Structure
	rm -rf $(BUILD_DIST)/xkbcomp
	
# xkbcomp.mk Prep xkbcomp
	cp -a $(BUILD_STAGE)/xkbcomp $(BUILD_DIST)
	
# xkbcomp.mk Sign
	$(call SIGN,xkbcomp,general.xml)
	
# xkbcomp.mk Make .debs
	$(call PACK,xkbcomp,DEB_XKBCOMP_V)
	
# xkbcomp.mk Build cleanup
	rm -rf $(BUILD_DIST)/xkbcomp

.PHONY: xkbcomp xkbcomp-package
=======
	# xkbcomp.mk Package Structure
	rm -rf $(BUILD_DIST)/xkbcomp

	# xkbcomp.mk Prep xkbcomp
	cp -a $(BUILD_STAGE)/xkbcomp $(BUILD_DIST)

	# xkbcomp.mk Sign
	$(call SIGN,xkbcomp,general.xml)

	# xkbcomp.mk Make .debs
	$(call PACK,xkbcomp,DEB_XKBCOMP_V)

	# xkbcomp.mk Build cleanup
	rm -rf $(BUILD_DIST)/xkbcomp

.PHONY: xkbcomp xkbcomp-package
>>>>>>> b3101346967d65d30c8678c524e834b1862b3ab0
