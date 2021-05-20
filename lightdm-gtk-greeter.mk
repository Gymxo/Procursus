ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

SUBPROJECTS   += lightdm-gtk-greeter
LIGHTDM-GTK-GREETER_VERSION := 2.0.8
DEB_LIGHTDM-GTK-GREETER_V   ?= $(LIGHTDM-GTK-GREETER_VERSION)

lightdm-gtk-greeter-setup: setup
	wget -q -nc -P $(BUILD_SOURCE) https://github.com/Xubuntu/lightdm-gtk-greeter/releases/download/lightdm-gtk-greeter-2.0.8/lightdm-gtk-greeter-2.0.8.tar.gz
	$(call EXTRACT_TAR,lightdm-gtk-greeter-$(LIGHTDM-GTK-GREETER_VERSION).tar.gz,lightdm-gtk-greeter-$(LIGHTDM-GTK-GREETER_VERSION),lightdm-gtk-greeter)

ifneq ($(wildcard $(BUILD_WORK)/lightdm-gtk-greeter/.build_complete),)
lightdm-gtk-greeter:
	@echo "Using previously built lightdm-gtk-greeter."
else
lightdm-gtk-greeter: lightdm-gtk-greeter-setup libx11 libxau libxmu xorgproto xxhash libgcrypt
	cd $(BUILD_WORK)/lightdm-gtk-greeter && ./configure -C \
		$(DEFAULT_CONFIGURE_FLAGS) \
		--with-libxklavier \
		--disable-rpath \
		--enable-introspection=no
	+$(MAKE) -C $(BUILD_WORK)/lightdm-gtk-greeter
	+$(MAKE) -C $(BUILD_WORK)/lightdm-gtk-greeter install \
		DESTDIR=$(BUILD_STAGE)/lightdm-gtk-greeter
	+$(MAKE) -C $(BUILD_WORK)/lightdm-gtk-greeter install \
		DESTDIR=$(BUILD_BASE)
	touch $(BUILD_WORK)/lightdm-gtk-greeter/.build_complete
endif

lightdm-gtk-greeter-package: lightdm-gtk-greeter-stage
	# lightdm-gtk-greeter.mk Package Structure
	rm -rf $(BUILD_DIST)/lightdm-gtk-greeter

	# lightdm-gtk-greeter.mk Prep lightdm-gtk-greeter
	cp -a $(BUILD_STAGE)/lightdm-gtk-greeter $(BUILD_DIST)

	# lightdm-gtk-greeter.mk Sign
	$(call SIGN,lightdm-gtk-greeter,general.xml)

	# lightdm-gtk-greeter.mk Make .debs
	$(call PACK,lightdm-gtk-greeter,DEB_LIGHTDM-GTK-GREETER_V)

	# lightdm-gtk-greeter.mk Build cleanup
	rm -rf $(BUILD_DIST)/lightdm-gtk-greeter

.PHONY: lightdm-gtk-greeter lightdm-gtk-greeter-package
