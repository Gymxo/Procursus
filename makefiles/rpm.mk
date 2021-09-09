ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += rpm
RPM_VERSION := 4.16.1
DEB_RPM_V   ?= $(RPM_VERSION)

rpm-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) http://ftp.rpm.org/releases/rpm-4.16.x/rpm-4.16.1.tar.bz2
	$(call EXTRACT_TAR,rpm-$(RPM_VERSION).tar.bz2,rpm-$(RPM_VERSION),rpm)

ifneq ($(wildcard $(BUILD_WORK)/rpm/.build_complete),)
rpm:
	@echo "Using previously built rpm."
else
rpm: rpm-setup libx11 libxau libxext libxmu xorgproto
	cd $(BUILD_WORK)/rpm && PKG_CONFIG_PATH="$(BUILD_BASE)/usr/lib/pkgconfig/" ./configure -h \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--without-lua \
		--disable-bdb
	+$(MAKE) LDFLAGS='$(LDFLAGS) -lintl' -C $(BUILD_WORK)/rpm
	+$(MAKE) -C $(BUILD_WORK)/rpm install \
		DESTDIR=$(BUILD_STAGE)/rpm
	+$(MAKE) -C $(BUILD_WORK)/rpm install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/rpm/.build_complete
endif

rpm-package: rpm-stage
	# rpm.mk Package Structure
	rm -rf $(BUILD_DIST)/rpm

	# rpm.mk Prep rpm
	cp -a $(BUILD_STAGE)/rpm $(BUILD_DIST)

	# rpm.mk Sign
	$(call SIGN,rpm,general.xml)

	# rpm.mk Make .debs
	$(call PACK,rpm,DEB_RPM_V)

	# rpm.mk Build cleanup
	rm -rf $(BUILD_DIST)/rpm

.PHONY: rpm rpm-package
