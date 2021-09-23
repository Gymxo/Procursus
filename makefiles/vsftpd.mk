ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += vsftpd
VSFTPD_VERSION := 3.0.5
DEB_VSFTPD_V   ?= $(VSFTPD_VERSION)

vsftpd-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://security.appspot.com/downloads/vsftpd-$(VSFTPD_VERSION).tar.gz
	$(call EXTRACT_TAR,vsftpd-$(VSFTPD_VERSION).tar.gz,vsftpd-$(VSFTPD_VERSION),vsftpd)
	sed -i 's/gcc/cc/g' $(BUILD_WORK)/vsftpd/Makefile
	sed -i 's|\$$(CFLAGS) \$$(IFLAGS)|\$$(CFLAGS) \$$(IFLAGS) $(CFLAGS)|g' $(BUILD_WORK)/vsftpd/Makefile
	sed -i 's|\$$(LDFLAGS) \$$(LIBS)|$(LDFLAGS) -lpam \$$(LIBS)|g' $(BUILD_WORK)/vsftpd/Makefile
	sed -i 's|/usr/local|$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)|g' $(BUILD_WORK)/vsftpd/Makefile
	sed -i '/#define VSF_SYSDEP_HAVE_PAM/d' $(BUILD_WORK)/vsftpd/sysdeputil.c
	sed -i '/#define VSF_SYSDEP_HAVE_UTMPX/d' $(BUILD_WORK)/vsftpd/sysdeputil.c
	mkdir -p $(BUILD_STAGE)/vsftpd/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/sbin

ifneq ($(wildcard $(BUILD_WORK)/vsftpd/.build_complete),)
vsftpd:
	find $(BUILD_STAGE)/vsftpd -type f -exec codesign --remove {} \; &> /dev/null; \
	find $(BUILD_STAGE)/vsftpd -type f -exec codesign --sign $(CODESIGN_IDENTITY) --force --preserve-metadata=entitlements,requirements,flags,runtime {} \; &> /dev/null
	@echo "Using previously built vsftpd."
else
vsftpd: vsftpd-setup
	+$(MAKE) -C $(BUILD_WORK)/vsftpd
	$(INSTALL) -Dm755 $(BUILD_WORK)/vsftpd/vsftpd $(BUILD_STAGE)/vsftpd/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/sbin/vsftpd
	$(INSTALL) -Dm644 $(BUILD_WORK)/vsftpd/vsftpd.8 $(BUILD_STAGE)/vsftpd/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/man/man8/vsftpd.8;
	$(INSTALL) -Dm644 $(BUILD_WORK)/vsftpd/vsftpd.conf.5 $(BUILD_STAGE)/vsftpd/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/man/man5/vsftpd.conf.5
	$(INSTALL) -Dm644 $(BUILD_WORK)/vsftpd/xinetd.d/vsftpd $(BUILD_STAGE)/vsftpd/$(MEMO_PREFIX)/etc/xinetd.d/vsftpd
	$(call AFTER_BUILD)
endif

vsftpd-package: vsftpd-stage
	# vsftpd.mk Package Structure
	rm -rf $(BUILD_DIST)/vsftpd

	# vsftpd.mk Prep vsftpd
	cp -a $(BUILD_STAGE)/vsftpd $(BUILD_DIST)

	# vsftpd.mk Sign
	$(call SIGN,vsftpd,general.xml)

	# vsftpd.mk Make .debs
	$(call PACK,vsftpd,DEB_VSFTPD_V)

	# vsftpd.mk Build cleanup
	rm -rf $(BUILD_DIST)/vsftpd

.PHONY: vsftpd vsftpd-package
