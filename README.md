# Project GOAL
Create a cheap and reliable hardware emulator for Android Automotive development

# TODO
  * WiFi ✔️
  * Can-Bus ✅
  * Vehicle Hal ⚙️
  * Secondary screen ❌
  * GPS ➖
  * Bluetooth ❌
  * Camera Support ➖
  * Support more Can-Bus Hat's ⚙️

  ✔️ working
  ✅ working but need some love
  ⚙️ ongoing development
  ❌ not working
  ➖ not tested / unknown status

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

# Edit .config
  * add `CONFIG_CAN_MCP25XXFD=y`
  * change `CONFIG_CAN_DEV` to `CONFIG_CAN_DEV=y`
  * change `CONFIG_SPI_BCM2835` to `CONFIG_SPI_BCM2835=y`
  * change `CONFIG_SPI_BCM2835AUX` to `CONFIG_SPI_BCM2835AUX=y`

# Build Kernel
```
  $ ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- make -j4 zImage
  $ ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- make -j4 dtbs
  $ ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- make -j4 modules
```

# Install modules to temp directory and copy to device
```
  $ mkdir kmods
  $ make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=kmods modules_install
  $ cp kmods/lib/modules/5.4.47-v7l+/kernel/drivers/net/can/can-dev.ko ../../device/arpi/rpi4car/modules/
  $ cp kmods/lib/modules/5.4.47-v7l+/kernel/drivers/net/can/spi/mcp25xxfd/mcp25xxfd.ko ../../device/arpi/rpi4car/modules/
  $ rm -rf kmods
  $ cd ../..
```

# Checks we can do to verify that the driver has been added to the vendor image after build
   * Check that `dev-can.ko` and `mcp25xxfd.ko` is present in the `/lib/modules` directory of the vendor partition of your sd card.

# Build Android source
```
  $ source build/envsetup.sh
  $ lunch rpi4car-eng
  $ make -j4 ramdisk systemimage vendorimage userdataimage
```
 Use -j[n] option with make, if build host has a good number of CPU cores.

# Write to sdcard
 Insert sdcard, get `<device>` with lsblk cmd and run
```
  $ device/arpi/rpi4car/mksdcard.sh <device>
```

