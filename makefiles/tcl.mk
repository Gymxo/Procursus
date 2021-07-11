ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += tcl
TCL_VERSION := 8.6.11
DEB_TCL_V   ?= $(TCL_VERSION)

tcl-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://netactuate.dl.sourceforge.net/project/tcl/Tcl/8.6.11/tcl8.6.11-src.tar.gz
	$(call EXTRACT_TAR,tcl$(TCL_VERSION)-src.tar.gz,tcl$(TCL_VERSION),tcl)

ifneq ($(wildcard $(BUILD_WORK)/tcl/.build_complete),)
tcl:
	@echo "Using previously built tcl."
else
tcl: tcl-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/tcl/unix && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--disable-framework
	+$(MAKE) -i -C $(BUILD_WORK)/tcl/unix
	+$(MAKE) -i -C $(BUILD_WORK)/tcl/unix install \
		DESTDIR=$(BUILD_STAGE)/tcl/
	+$(MAKE) -i -C $(BUILD_WORK)/tcl/unix install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/tcl/.build_complete
endif

tcl-package: tcl-stage
	# tcl.mk Package Structure
	rm -rf $(BUILD_DIST)/tcl

	# tcl.mk Prep tcl
	cp -a $(BUILD_STAGE)/tcl $(BUILD_DIST)

	# tcl.mk Sign
	$(call SIGN,tcl,general.xml)

	# tcl.mk Make .debs
	$(call PACK,tcl,DEB_TCL_V)

	# tcl.mk Build cleanup
	rm -rf $(BUILD_DIST)/tcl

.PHONY: tcl tcl-package
