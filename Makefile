THEOS_DEVICE_IP = 192.168.2.133
TARGET := iphone:clang:13.0
INSTALL_TARGET_PROCESSES = Mu

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = Mu

Mu_FILES = $(wildcard *.swift)
Mu_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/application.mk
