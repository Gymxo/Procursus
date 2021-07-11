ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += tk
TK_VERSION := 8.6.11.1
DEB_TK_V   ?= $(TK_VERSION)

tk-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://phoenixnap.dl.sourceforge.net/project/tcl/Tcl/8.6.11/tk8.6.11.1-src.tar.gz
	$(call EXTRACT_TAR,tk$(TK_VERSION)-src.tar.gz,tk8.6.11,tk)

ifneq ($(wildcard $(BUILD_WORK)/tk/.build_complete),)
tk:
	@echo "Using previously built tk."
else
tk: tk-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/tk/unix && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-x
	+$(MAKE) -i -C $(BUILD_WORK)/tk/unix
	+$(MAKE) -i -C $(BUILD_WORK)/tk/unix install \
		DESTDIR=$(BUILD_STAGE)/tk/
	+$(MAKE) -i -C $(BUILD_WORK)/tk/unix install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/tk/.build_complete
endif

tk-package: tk-stage
	# tk.mk Package Structure
	rm -rf $(BUILD_DIST)/tk

	# tk.mk Prep tk
	cp -a $(BUILD_STAGE)/tk $(BUILD_DIST)

	# tk.mk Sign
	$(call SIGN,tk,general.xml)

	# tk.mk Make .debs
	$(call PACK,tk,DEB_TK_V)

	# tk.mk Build cleanup
	rm -rf $(BUILD_DIST)/tk

.PHONY: tk tk-package
