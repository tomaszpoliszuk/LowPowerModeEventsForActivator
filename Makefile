FINALPACKAGE = 1
DEBUG = 0

INSTALL_TARGET_PROCESSES = SpringBoard

ARCHS = armv7 arm64 arm64e
TARGET = iphone:clang::9.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = LowPowerModeEventsForActivator

$(TWEAK_NAME)_FILES = $(TWEAK_NAME).xm
$(TWEAK_NAME)_LIBRARIES = activator
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = SpringBoardUIServices

include $(THEOS_MAKE_PATH)/tweak.mk
