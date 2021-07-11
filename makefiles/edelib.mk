ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += edelib
EDELIB_VERSION := 2.1
DEB_EDELIB_V   ?= $(EDELIB_VERSION)

edelib-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://phoenixnap.dl.sourceforge.net/project/ede/edelib/2.1/edelib-2.1.tar.gz
	$(call EXTRACT_TAR,edelib-$(EDELIB_VERSION).tar.gz,edelib-$(EDELIB_VERSION),edelib)

ifneq ($(wildcard $(BUILD_WORK)/edelib/.build_complete),)
edelib:
	@echo "Using previously built edelib."
else
edelib: edelib-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/edelib && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-x \
		--x-libraries=$(BUILD_BASE)/usr/lib \
		--x-includes=$(BUILD_BASE)/usr/include
	cd $(BUILD_WORK)/edelib && jam $(BUILD_WORK)/edelib
	cd $(BUILD_WORK)/edelib && sudo jam $(BUILD_WORK)/edelib $(BUILD_WORK)/edelib install \
		DESTDIR=$(BUILD_STAGE)/edelib
	cd $(BUILD_WORK)/edelib && jam $(BUILD_WORK)/edelib $(BUILD_WORK)/edelib install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/edelib/.build_complete
endif

edelib-package: edelib-stage
	# edelib.mk Package Structure
	rm -rf $(BUILD_DIST)/edelib

	# edelib.mk Prep edelib
	cp -a $(BUILD_STAGE)/edelib $(BUILD_DIST)

	# edelib.mk Sign
	$(call SIGN,edelib,general.xml)

	# edelib.mk Make .debs
	$(call PACK,edelib,DEB_EDELIB_V)

	# edelib.mk Build cleanup
	rm -rf $(BUILD_DIST)/edelib

.PHONY: edelib edelib-package
