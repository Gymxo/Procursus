ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += emacs
EMACS_VERSION := 27.2
DEB_EMACS_V   ?= $(EMACS_VERSION)

emacs-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://ftp.gnu.org/gnu/emacs/emacs-27.2.tar.xz
	$(call EXTRACT_TAR,emacs-$(EMACS_VERSION).tar.xz,emacs-$(EMACS_VERSION),emacs)

ifneq ($(wildcard $(BUILD_WORK)/emacs/.build_complete),)
emacs:
	@echo "Using previously built emacs."
else
emacs: emacs-setup libx11 libxau libxmu xorgproto xxhash
	cd $(BUILD_WORK)/emacs && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-x \
		--with-x-toolkit=athena \
		--x-libraries=$(BUILD_BASE)/usr/lib \
		--x-includes=$(BUILD_BASE)/usr/include \
		--without-ns \
		--without-makeinfo
	+$(MAKE) -C $(BUILD_WORK)/emacs
	+$(MAKE) -C $(BUILD_WORK)/emacs install \
		DESTDIR=$(BUILD_STAGE)/emacs
	+$(MAKE) -C $(BUILD_WORK)/emacs install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/emacs/.build_complete
endif

emacs-package: emacs-stage
	# emacs.mk Package Structure
	rm -rf $(BUILD_DIST)/emacs

	# emacs.mk Prep emacs
	cp -a $(BUILD_STAGE)/emacs $(BUILD_DIST)

	# emacs.mk Sign
	$(call SIGN,emacs,general.xml)

	# emacs.mk Make .debs
	$(call PACK,emacs,DEB_EMACS_V)

	# emacs.mk Build cleanup
	rm -rf $(BUILD_DIST)/emacs

.PHONY: emacs emacs-package
