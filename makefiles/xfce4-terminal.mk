ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += xfce4-terminal
XFCE4-TERMINAL_VERSION := 0.8.9.2
DEB_XFCE4-TERMINAL_V   ?= $(XFCE4-TERMINAL_VERSION)

xfce4-terminal-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://archive.xfce.org/src/apps/xfce4-terminal/0.8/xfce4-terminal-0.8.9.2.tar.bz2
	$(call EXTRACT_TAR,xfce4-terminal-$(XFCE4-TERMINAL_VERSION).tar.bz2,xfce4-terminal-$(XFCE4-TERMINAL_VERSION),xfce4-terminal)

ifneq ($(wildcard $(BUILD_WORK)/xfce4-terminal/.build_complete),)
xfce4-terminal:
	find $(BUILD_STAGE)/xfce4-terminal -type f -exec codesign --remove {} \; &> /dev/null; \
	find $(BUILD_STAGE)/xfce4-terminal -type f -exec codesign --sign $(CODESIGN_IDENTITY) --force --preserve-metadata=entitlements,requirements,flags,runtime {} \; &> /dev/null
	@echo "Using previously built xfce4-terminal."
else
xfce4-terminal: xfce4-terminal-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/xfce4-terminal && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-x \
		--x-libraries=$(BUILD_BASE)/usr/lib \
		--x-includes=$(BUILD_BASE)/usr/include
	+$(MAKE) -C $(BUILD_WORK)/xfce4-terminal
	+$(MAKE) -C $(BUILD_WORK)/xfce4-terminal install \
		DESTDIR=$(BUILD_STAGE)/xfce4-terminal
	+$(MAKE) -C $(BUILD_WORK)/xfce4-terminal install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/xfce4-terminal/.build_complete
endif

xfce4-terminal-package: xfce4-terminal-stage
	# xfce4-terminal.mk Package Structure
	rm -rf $(BUILD_DIST)/xfce4-terminal

	# xfce4-terminal.mk Prep xfce4-terminal
	cp -a $(BUILD_STAGE)/xfce4-terminal $(BUILD_DIST)

	# xfce4-terminal.mk Sign
	$(call SIGN,xfce4-terminal,general.xml)

	# xfce4-terminal.mk Make .debs
	$(call PACK,xfce4-terminal,DEB_XFCE4-TERMINAL_V)

	# xfce4-terminal.mk Build cleanup
	rm -rf $(BUILD_DIST)/xfce4-terminal

.PHONY: xfce4-terminal xfce4-terminal-package
