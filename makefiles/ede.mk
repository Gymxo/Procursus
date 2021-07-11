ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += ede
EDE_VERSION := 2.1
DEB_EDE_V   ?= $(EDE_VERSION)

ede-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://versaweb.dl.sourceforge.net/project/ede/ede/2.1/ede-2.1.tar.gz
	$(call EXTRACT_TAR,ede-$(EDE_VERSION).tar.gz,ede-$(EDE_VERSION),ede)

ifneq ($(wildcard $(BUILD_WORK)/ede/.build_complete),)
ede:
	@echo "Using previously built ede."
else
ede: ede-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/ede && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-x \
		--x-libraries=$(BUILD_BASE)/usr/lib \
		--x-includes=$(BUILD_BASE)/usr/include \
		--with-fltk-path=$(BUILD_BASE)
	+$(MAKE) -C $(BUILD_WORK)/ede
	+$(MAKE) -C $(BUILD_WORK)/ede install \
		DESTDIR=$(BUILD_STAGE)/ede
	+$(MAKE) -C $(BUILD_WORK)/ede install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/ede/.build_complete
endif

ede-package: ede-stage
	# ede.mk Package Structure
	rm -rf $(BUILD_DIST)/ede

	# ede.mk Prep ede
	cp -a $(BUILD_STAGE)/ede $(BUILD_DIST)

	# ede.mk Sign
	$(call SIGN,ede,general.xml)

	# ede.mk Make .debs
	$(call PACK,ede,DEB_EDE_V)

	# ede.mk Build cleanup
	rm -rf $(BUILD_DIST)/ede

.PHONY: ede ede-package
