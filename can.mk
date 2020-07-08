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

# can setup interface script
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/can/setup-can.sh:/system/etc/setup-can.sh \
    $(LOCAL_PATH)/can/init.can.rc:root/init.can.rc

# Can-Utils: https://github.com/linux-can/can-utils/
PRODUCT_PACKAGES += \
    libcan \
    libj1939 \
    j1939acd \
    j1939cat \
    j1939spy \
    j1939sr \
    testj1939 \
    candump \
    cansend \
    bcmserver \
    can-calc-bit-timing \
    canbusload \
    canfdtest \
    cangen \
    cangw \
    canlogserver \
    canplayer \
    cansniffer \
    isotpdump \
    isotprecv \
    isotpsend \
    isotpserver \
    isotpsniffer \
    isotptun \
    isotpperf \
    log2asc \
    asc2log \
    log2long \
    slcan_attach \
    slcand \
    slcanpty
