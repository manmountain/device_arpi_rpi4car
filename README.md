# Android Automotive Rapberry Pi 4 

# TODO
  * WiFi ✔️
  * Can-Bus ✅
  * Vehicle Hal ⚙️
  * Secondary screen ❌
  * GPS ➖
  * Bluetooth ❌
  * Camera Support ➖
  * Support more Can-Bus Hat's ⚙️

  * ✔️ working
  * ✅ working but need some love
  * ⚙️ ongoing development
  * ❌ not working
  * ➖ not tested / unknown status

# Initialize AOSP source
```
  $ repo init -u https://android.googlesource.com/platform/manifest -b android-10.0.0_r39 --current-branch --no-tags --no-clone-bundle --depth 1
```
# Set local repos
```
  $ git clone https://github.com/android-rpi/local_manifests .repo/local_manifests -b arpi-10
```

# Make changes to local manifest
  * edit `.repo/local_manifests/defualt.xml`
  * add remote `<remote name="arpicar" fetch="https://github.com/manmountain"/>`
  * change `<project path="device/arpi/rpi4" name="device_arpi_rpi4" revision="arpi-10" remote="arpi"/>`
  * to `<project path="device/arpi/rpi4car" name="device_arpi_rpi4car" revision="arpi-10" remote="arpicar"/>`
  * add remote `<remote name="linux-can" fetch="https://github.com/linux-can"/>`
  * add `<project path="vendor/can/can-utils" name="can-utils" revision="master" remote="linux-can"/>`

# Get the AOSP source 
```
  $ repo sync --current-branch --no-tags --no-clone-bundle --force-sync -j4
```

# Install kernel driver patch for [can bus hat](https://www.seeedstudio.com/2-Channel-CAN-BUS-FD-Shield-for-Raspberry-Pi-p-4072.html)
```
  $ cd kernel/arpi
  $ patch -p2 < ../../device/arpi/rpi4car/patches/mcp25xxfd-V8.2.patch
```

# Configure Kernel
```
  $ cd kernel/arpi
  $ ARCH=arm scripts/kconfig/merge_config.sh arch/arm/configs/bcm2711_defconfig kernel/configs/android-base.config kernel/configs/android-recommended.config
```

# Edit Kernel .config
  * set `CONFIG_CAN` to `CONFIG_CAN=y`
  * set `CONFIG_CAN_RAW` to `CONFIG_CAN_RAW=y`
  * set `CONFIG_CAN_BCM` to `CONFIG_CAN_BCM=y`
  * set `CONFIG_CAN_GW` to `CONFIG_CAN_GW=y`
  * set `CONFIG_CAN_J1939` to `CONFIG_CAN_J1939=y`
  * set `CONFIG_CAN_SLCAN` to `CONFIG_CAN_SLCAN=y`
  * set `CONFIG_CAN_DEV` to `CONFIG_CAN_DEV=y`
  * set `CONFIG_CAN_CALC_BITTIMING` to `CONFIG_CAN_CALC_BITTIMING=y`
  * add `CONFIG_CAN_MCP25XXFD=y`
  * set `CONFIG_CAN_MCP251X` to `CONFIG_CAN_MCP251X=y`
  * set `CONFIG_SPI_BCM2835` to `CONFIG_SPI_BCM2835=y`
  * set `CONFIG_SPI_BCM2835AUX` to `CONFIG_SPI_BCM2835AUX=y`

# Build Kernel
```
  $ ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- make -j4 zImage
  $ ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- make -j4 dtbs
```

# Get can-utils
```
  $ cd device/arpi/rpi4car/
  $ git clone https://github.com/linux-can/can-utils/
  $ mv can-utils-master can-utils
  $ uncomment can-utils section in rp4car.mk
  $ cd ../..
```

# Checks we can do to verify that the can-bus works
  * TODO

# Build Android source
```
  $ source build/envsetup.sh
  $ lunch rpi4car-userdebug
  $ make -j4 ramdisk systemimage vendorimage userdataimage
```
 Use -j[n] option with make, if build host has a good number of CPU cores.

# Write to sdcard
 Insert sdcard, get `<device>` with lsblk cmd and run
```
  $ device/arpi/rpi4car/mksdcard.sh <device>
```

