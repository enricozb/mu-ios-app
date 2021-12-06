THEOS_DEVICE_IP = 192.168.1.113
TARGET := iphone:clang:14.4
INSTALL_TARGET_PROCESSES = Mu

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = Mu

Mu_FILES = $(shell find lib -type f -name '*.swift') $(shell find src -type f -name '*.swift')
Mu_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/application.mk
