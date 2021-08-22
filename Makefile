# THEOS_DEVICE_IP = 192.168.2.116
# temporary while working remotely
THEOS_DEVICE_IP = 192.168.1.173
TARGET := iphone:clang:14.4
INSTALL_TARGET_PROCESSES = Mu

include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = Mu

Mu_FILES = $(wildcard *.swift)
Mu_FRAMEWORKS = UIKit CoreGraphics

include $(THEOS_MAKE_PATH)/application.mk
