ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS    += popt
POPT_VERSION := 1.18
DEB_POPT_V   ?= $(POPT_VERSION)

popt-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) http://ftp.rpm.org/popt/releases/popt-1.x/popt-1.18.tar.gz
	$(call EXTRACT_TAR,popt-$(POPT_VERSION).tar.gz,popt-$(POPT_VERSION),popt)

ifneq ($(wildcard $(BUILD_WORK)/popt/.build_complete),)
popt:
	@echo "Using previously built popt."
else
popt: popt-setup libx11 libxau libxext libxmu xorgproto
	cd $(BUILD_WORK)/popt && ./autogen.sh \
	cd $(BUILD_WORK)/popt && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS)
	+$(MAKE) -C $(BUILD_WORK)/popt
	+$(MAKE) -C $(BUILD_WORK)/popt install \
		DESTDIR=$(BUILD_STAGE)/popt
	+$(MAKE) -C $(BUILD_WORK)/popt install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/popt/.build_complete
endif

popt-package: popt-stage
	# popt.mk Package Structure
	rm -rf $(BUILD_DIST)/popt

	# popt.mk Prep popt
	cp -a $(BUILD_STAGE)/popt $(BUILD_DIST)

	# popt.mk Sign
	$(call SIGN,popt,general.xml)

	# popt.mk Make .debs
	$(call PACK,popt,DEB_POPT_V)

	# popt.mk Build cleanup
	rm -rf $(BUILD_DIST)/popt

.PHONY: popt popt-package
