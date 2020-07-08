#
# Copyright 2020 Android-RPi Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

TARGET_USES_CAR_FUTURE_FEATURES := true

#BOARD_PLAT_PUBLIC_SEPOLICY_DIR += packages/services/Car/car_product/sepolicy/public
#BOARD_PLAT_PRIVATE_SEPOLICY_DIR += packages/services/Car/car_product/sepolicy/private

$(call inherit-product, device/generic/car/common/car.mk)

PRODUCT_NAME := rpi4car
PRODUCT_DEVICE := rpi4car
PRODUCT_BRAND := rpi
PRODUCT_MANUFACTURER := RPi
PRODUCT_MODEL := Raspberry Pi 4

include frameworks/native/build/tablet-7in-hdpi-1024-dalvik-heap.mk

PRODUCT_PROPERTY_OVERRIDES += \
    debug.drm.mode.force=1280x720 \
    gralloc.drm.device=/dev/dri/card0 \
    gralloc.drm.kms=/dev/dri/card1 \
    ro.opengles.version=196609 \
    wifi.interface=wlan0 \
    qemu.hw.mainkeys=0 \
    ro.config.ringtone=Girtab.ogg \
    ro.config.notification_sound=Tethys.ogg \
    ro.config.alarm_alert=Oxygen.ogg

# Automotive specific packages
PRODUCT_PACKAGES += \
    vehicle.default \
    CarSettings \
    CarLauncher \
    android.hardware.automotive.vehicle@2.0 \
    android.hardware.automotive.vehicle@2.0-service  \
    CarService \
    CarTrustAgentService \
    CarDialerApp \
    CarRadioApp \
    OverviewApp \
    CarLensPickerApp \
    LocalMediaPlayer \
    CarMediaApp \
    CarMessengerApp \
    CarHvacApp \
    CarMapsPlaceholder \
    CarLatinIME \
    CarUsbHandler \
    DirectRenderingCluster \
    android.car \
    car-frameworks-service \
    com.android.car.procfsinspector \
    libcar-framework-service-jni \
    NoCutoutOverlay

# Remove the default launchers
#LOCAL_OVERRIDES_PACKAGES := Home Launcher2 Launcher3 Launcher3QuickStep
LOCAL_OVERRIDES_PACKAGES += Home

# System Server components
PRODUCT_SYSTEM_SERVER_JARS += car-frameworks-service

# Boot animation
PRODUCT_COPY_FILES += \
    packages/services/Car/car_product/bootanimations/bootanimation-832.zip:system/media/bootanimation.zip

# Add car related sepolicy.
BOARD_SEPOLICY_DIRS += \
    device/generic/car/common/sepolicy \
    packages/services/Car/car_product/sepolicy

# system packages
PRODUCT_PACKAGES += \
    libGLES_mesa \
    gralloc.rpi4 \
    memtrack.rpi4 \
    gatekeeper.rpi4 \
    audio.primary.rpi4 \
    audio.usb.default \
    wificond \
    wifilogd \
    wpa_supplicant \
    wpa_supplicant.conf

# hardware/interfaces
PRODUCT_PACKAGES += \
    android.hardware.graphics.allocator@2.0-service.rpi4 \
    android.hardware.graphics.mapper@2.0-impl.rpi4 \
    android.hardware.graphics.composer@2.1-service.rpi4 \
    android.hardware.audio@2.0-impl \
    android.hardware.audio.effect@2.0-impl \
    android.hardware.audio@2.0-service \
    android.hardware.keymaster@3.0-impl \
    android.hardware.keymaster@3.0-service \
    android.hardware.gatekeeper@1.0-impl \
    android.hardware.gatekeeper@1.0-service \
    android.hardware.memtrack@1.0-impl \
    android.hardware.memtrack@1.0-service \
    android.hardware.health@2.0-service \
    android.hardware.health@2.0-impl \
    android.hardware.wifi@1.0-service \
    android.hardware.configstore@1.1-service \
    vndservicemanager

# system configurations
PRODUCT_COPY_FILES := \
    hardware/broadcom/wlan/bcmdhd/config/wpa_supplicant_overlay.conf:$(TARGET_COPY_OUT_VENDOR)/etc/wifi/wpa_supplicant_overlay.conf \
    frameworks/native/data/etc/android.hardware.ethernet.xml:system/etc/permissions/android.hardware.ethernet.xml \
    frameworks/native/data/etc/android.hardware.usb.host.xml:system/etc/permissions/android.hardware.usb.host.xml \
    frameworks/native/data/etc/android.hardware.wifi.xml:system/etc/permissions/android.hardware.wifi.xml \
    $(LOCAL_PATH)/rpi4_core_hardware.xml:system/etc/permissions/rpi4_core_hardware.xml \
    $(LOCAL_PATH)/init.usb.rc:root/init.usb.rc \
    $(LOCAL_PATH)/init.rpi4.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.rpi4.rc \
    $(LOCAL_PATH)/init.rpi4.usb.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/hw/init.rpi4.usb.rc \
    $(LOCAL_PATH)/ueventd.rpi4.rc:$(TARGET_COPY_OUT_VENDOR)/ueventd.rc \
    $(LOCAL_PATH)/fstab.rpi4:$(TARGET_COPY_OUT_VENDOR)/etc/fstab.rpi4 \
    $(LOCAL_PATH)/fstab.rpi4:$(TARGET_COPY_OUT_RAMDISK)/fstab.rpi4 \
    $(LOCAL_PATH)/Generic.kl:$(TARGET_COPY_OUT_VENDOR)/usr/keylayout/Generic.kl \
    $(LOCAL_PATH)/firmware/brcm/brcmfmac43455-sdio.bin:root/lib/firmware/brcm/brcmfmac43455-sdio.bin \
    $(LOCAL_PATH)/firmware/brcm/brcmfmac43455-sdio.bin:$(TARGET_COPY_OUT_RAMDISK)/lib/firmware/brcm/brcmfmac43455-sdio.bin \
    $(LOCAL_PATH)/firmware/brcm/brcmfmac43455-sdio.clm_blob:root/lib/firmware/brcm/brcmfmac43455-sdio.clm_blob \
    $(LOCAL_PATH)/firmware/brcm/brcmfmac43455-sdio.clm_blob:$(TARGET_COPY_OUT_RAMDISK)/lib/firmware/brcm/brcmfmac43455-sdio.clm_blob \
    $(LOCAL_PATH)/firmware/brcm/brcmfmac43455-sdio.txt:root/lib/firmware/brcm/brcmfmac43455-sdio.raspberrypi,4-model-b.txt \
    $(LOCAL_PATH)/firmware/brcm/brcmfmac43455-sdio.txt:$(TARGET_COPY_OUT_RAMDISK)/lib/firmware/brcm/brcmfmac43455-sdio.raspberrypi,4-model-b.txt \
    $(PRODUCT_COPY_FILES)

# media configurations
PRODUCT_COPY_FILES := \
    device/generic/goldfish/camera/media_profiles.xml:system/etc/media_profiles.xml \
    device/generic/goldfish/camera/media_codecs.xml:system/etc/media_codecs.xml \
    frameworks/av/media/libeffects/data/audio_effects.conf:system/etc/audio_effects.conf \
    frameworks/av/media/libstagefright/data/media_codecs_google_audio.xml:system/etc/media_codecs_google_audio.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_telephony.xml:system/etc/media_codecs_google_telephony.xml \
    frameworks/av/media/libstagefright/data/media_codecs_google_video.xml:system/etc/media_codecs_google_video.xml \
    frameworks/av/services/audiopolicy/config/usb_audio_policy_configuration.xml:system/etc/usb_audio_policy_configuration.xml \
    frameworks/av/services/audiopolicy/config/default_volume_tables.xml:system/etc/default_volume_tables.xml \
    frameworks/av/services/audiopolicy/config/audio_policy_volumes.xml:system/etc/audio_policy_volumes.xml \
    $(LOCAL_PATH)/audio_policy_configuration.xml:system/etc/audio_policy_configuration.xml \
    frameworks/base/data/sounds/effects/ogg/Effect_Tick_48k.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ui/Effect_Tick.ogg \
    frameworks/base/data/sounds/alarms/ogg/Oxygen.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/alarms/Oxygen.ogg \
    frameworks/base/data/sounds/ringtones/ogg/Girtab.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/ringtones/Girtab.ogg \
    frameworks/base/data/sounds/notifications/ogg/Tethys_48k.ogg:$(TARGET_COPY_OUT_PRODUCT)/media/audio/notifications/Tethys.ogg \
    $(PRODUCT_COPY_FILES)

DEVICE_PACKAGE_OVERLAYS := device/arpi/rpi4car/overlay
PRODUCT_AAPT_PREF_CONFIG := xxhdpi
PRODUCT_CHARACTERISTICS := tablet

# should add to BOOT_JARS only once
ifeq (,$(INCLUDED_ANDROID_CAR_TO_PRODUCT_BOOT_JARS))
   PRODUCT_BOOT_JARS += \
   android.car

   INCLUDED_ANDROID_CAR_TO_PRODUCT_BOOT_JARS := yes
endif

$(call inherit-product, $(LOCAL_PATH)/can.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/languages_full.mk)
