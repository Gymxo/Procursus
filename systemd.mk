ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += systemd
SYSTEMD_VERSION := 248
DEB_SYSTEMD_V   ?= $(SYSTEMD_VERSION)

systemd-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://codeload.github.com/systemd/systemd/tar.gz/refs/tags/v248
	cp $(BUILD_SOURCE)/v$(SYSTEMD_VERSION) $(BUILD_SOURCE)/v$(SYSTEMD_VERSION).tar.gz
	rm -rf $(BUILD_SOURCE)/v$(SYSTEMD_VERSION)
	$(call EXTRACT_TAR,v$(SYSTEMD_VERSION).tar.gz,systemd-$(SYSTEMD_VERSION),systemd)

ifneq ($(wildcard $(BUILD_WORK)/systemd/.build_complete),)
systemd:
	@echo "Using previously built systemd."
else
systemd: systemd-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/systemd && ./configure
	+$(MAKE) -C $(BUILD_WORK)/systemd
	+$(MAKE) -C $(BUILD_WORK)/systemd install \
		DESTDIR=$(BUILD_STAGE)/systemd
	+$(MAKE) -C $(BUILD_WORK)/systemd install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/systemd/.build_complete
endif

systemd-package: systemd-stage
	# systemd.mk Package Structure
	rm -rf $(BUILD_DIST)/systemd

	# systemd.mk Prep systemd
	cp -a $(BUILD_STAGE)/systemd $(BUILD_DIST)

	# systemd.mk Sign
	$(call SIGN,systemd,general.xml)

	# systemd.mk Make .debs
	$(call PACK,systemd,DEB_SYSTEMD_V)

	# systemd.mk Build cleanup
	rm -rf $(BUILD_DIST)/systemd

.PHONY: systemd systemd-package
