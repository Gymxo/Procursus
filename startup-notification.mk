ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += startup-notification
STARTUP-NOTIFICATION_VERSION := 0.12
DEB_STARTUP-NOTIFICATION_V   ?= $(STARTUP-NOTIFICATION_VERSION)

startup-notification-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) http://www.freedesktop.org/software/startup-notification/releases/startup-notification-$(STARTUP-NOTIFICATION_VERSION).tar.gz
	$(call EXTRACT_TAR,startup-notification-$(STARTUP-NOTIFICATION_VERSION).tar.gz,startup-notification-$(STARTUP-NOTIFICATION_VERSION),startup-notification)

ifneq ($(wildcard $(BUILD_WORK)/startup-notification/.build_complete),)
startup-notification:
	@echo "Using previously built startup-notification."
else
startup-notification: startup-notification-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/startup-notification && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--sysconfdir=$(MEMO_PREFIX)/etc \
		--localstatedir=$(MEMO_PREFIX)/var
	+$(MAKE) -C $(BUILD_WORK)/startup-notification
	+$(MAKE) -C $(BUILD_WORK)/startup-notification install \
		DESTDIR=$(BUILD_STAGE)/startup-notification
	+$(MAKE) -C $(BUILD_WORK)/startup-notification install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/startup-notification/.build_complete
endif

startup-notification-package: startup-notification-stage
# startup-notification.mk Package Structure
	rm -rf $(BUILD_DIST)/startup-notification
	
# startup-notification.mk Prep startup-notification
	cp -a $(BUILD_STAGE)/startup-notification $(BUILD_DIST)
	
# startup-notification.mk Sign
	$(call SIGN,startup-notification,general.xml)
	
# startup-notification.mk Make .debs
	$(call PACK,startup-notification,DEB_STARTUP-NOTIFICATION_V)
	
# startup-notification.mk Build cleanup
	rm -rf $(BUILD_DIST)/startup-notification

.PHONY: startup-notification startup-notification-package