
# JabberJaw

JabberJaw is a re-code of the famous Shark Jack device developed by Hak5 which turn any OpenWrt compatible router into a portable network attack device.
As the Shark Jack firmware is a slightly modified version of OpenWrt (18.06-SNAPSHOT) it is possible to create your own custom firmware tailored to any router.

![JabberJaw network attack tool](https://i.ibb.co/QCxmTjW/jabberjaw.png)

### The difference between JabberJaw and Shark Jack.

If the Shark Jack firmware is based on OpenWrt and therefore common to many routers, the hardware is custom made. A special sliding button allows to switch the Shark Jack in Arming mode (payloads management) and in Attack mode (payloads execution). In a classic router we rarely find this kind of functionality. But where JabberJaw makes the difference is that it uses the router's WiFi, where Shark Jack is limited because there is no integrated WiFi. JabberJaw creates a hotspot called "JabberJaw" which is used as the Arming mode of Shark Jack in our case, and the Attack mode is always active and the payload is automatically executed when you connect an Ethernet port to another Ethernet port.

Note: it is also possible to hide the SSID of the Arming mode in order to make JabberJaw undetectable and to be able to connect to it remotely.

Another major problem is the battery, the Shark Jack has a small battery built in (12minutes) where almost all "classic" routers do not. In order to solve this problem, I found 3 options.

 - The first and least convenient one is to simply stick a small
   external battery to the device.
   
  -  The second option is to solder a small battery to the motherboard, in
   almost all travel routers there is a slot for this on the motherboard
   and not used.
   
  -   The last option which is the easiest is to buy the Chinese router
   MPR-A1 (Or A2) which integrates a 1800mah (4hours) battery and that you can
   find on Aliexpress for ~18$.
   - Another easy option is the PQI AirPen (A400) which is more powerful than the MPR-A1 and also includes a 450mah battery. Can be found for around ~15$ on second hand websites.

Last thing, because of limitation on small travel routers I will not implement a GUI to save space. Everything will be managed via SSH. 

### Recommended router.
Note: All router with 4MB of memory flash will need an external USB flash drive to extend the root filesystem. 

Device         | CPU (MHZ)         | Flash MB| RAM MB | Battery | More info|
-------------| -----------| -----------| -----------| -----------|-----------|
PQI AirPen | 400 |8|64|Yes (450mah)|https://openwrt.org/toh/hwdata/pqi/pqi_air_pen
MPR-A1 | 360 |4|16|Yes (1800mah)|https://openwrt.org/toh/hame/mpr-a1
A5-V11 | 360 |4|16/32|No|https://openwrt.org/toh/unbranded/a5-v11
Buffalo WMR-300 | 580 |8|64|No|https://openwrt.org/toh/buffalo/wmr-300
Elecom WRH-300CR | 580 |16|64|No (But small battery can be soldered)|https://openwrt.org/toh/hwdata/elecom/elecom_wrh-300cr
VoCore2 | 580 |16|128|No (But small battery can be soldered)|https://openwrt.org/toh/hwdata/vocore/vocore_vocore2

That's all for now but I'll add more relevant routers later. 
A list of potential interesting micro router with build in battery and compatible OpenWrt:
https://openwrt.org/toh/views/toh_battery-powered

### Build your own JabberJaw firmware.

In the following tutorial I will take as example the Buffalo WMR-300 which is a small travel router that I will transform into a Shark Jack device. In your case, adapt the tutorial to your device.

The first thing to do is to clone this repository. Once cloned, let’s download the OpenWrt image builder associate to the right architecture, in my case the architecture used by the WMR-300 is ramips/mt7620. And in order to save a maximum of memory space the version 18 of OpenWrt is recommended.
```bash
git clone https://github.com/Nwqda/JabberJaw.git
cd JabberJaw
wget https://downloads.openwrt.org/releases/18.06.9/targets/ramips/mt7620/openwrt-imagebuilder-18.06.9-ramips-mt7620.Linux-x86_64.tar.xz
tar xJf openwrt-imagebuilder-18.06.9-ramips-mt7620.Linux-x86_64.tar.xz
```

Before compiling the firmware one important thing to do is to modify the management of the leds. Indeed the Shark Jack uses a combo of several colors (Red, Green, Blue, Mixed) to recognize for example when the device is in the middle of the payload execution and when the execution of the payload is completed the led will change again by another color. And on this point, each device has different configuration. So to handle this it is important to modify the file /usr/bin/LED in order to indicate the correct leds management path. To find out this for your device you can download and decompile an OpenWrt firmware pre-build to your device and look at the different files stored in /sys/class/leds/.

I will write soon a complete article on my blog that will cover this step too.<br>
Update: Here is the detailled article: https://samy.link/blog/jabberjaw-convert-your-router-in-portable-network-attack-dev <br>

File /usr/bin/LED:
```bash
#!/bin/bash
# Original Shark Jack leds path
RED_LED="/sys/class/leds/shark:red:system/brightness"
GREEN_LED="/sys/class/leds/shark:green:system/brightness"
BLUE_LED="/sys/class/leds/shark:blue:system/brightness"

# Buffalo WMR-300 leds path
# Replace those 3 variables to make it compatible 
# with the LED of your device.
RED_LED="/sys/class/leds/wmr-300:red:aoss/brightness"
GREEN_LED="/sys/class/leds/wmr-300:green:aoss/brightness"
BLUE_LED="/sys/class/leds/wmr-300:green:status/brightness"
```
Once the path of the LEDs correctly filled we can now build the image.
In order to reduce the size of the image as much as possible, since Nmap is quiet heavy (2.2MB), it is important to choose meticulously the packages to include in our firmware. The LUCI GUI web interface will be removed in favor of Nmap which is the cornerstone of JabberJaw.

```bash
cd openwrt-imagebuilder-18.06.9-ramips-mt7620.Linux-x86_64
make image PROFILE=wmr-300 PACKAGES="base-files busybox dnsmasq dropbear firewall fstools bash coreutils-sleep iptables kernel kmod-gpio-button-hotplug kmod-ipt-offload kmod-leds-gpio kmod-mt76 kmod-rt2800-pci kmod-rt2800-soc libc libgcc logd mtd netifd odhcp6c  opkg swconfig uci uclient-fetch wpad-mini nmap macchanger -luci -ppp -ppp-mod-pppoe -ip6tables -odhcpd-ipv6only" FILES=../JabberJaw/wmr-300/
```
Note: This build with packages is only for devices that have at least 8MB of flash memory. For devices with 4MB the initial packages chosen will be different because it will be necessary to have a USB stick connected to the device during the first boot to extend the root filesystem. Once done another script will install the missing dependencies. 
No worries, I will include the right make command for each device. If you need help with this don't hesitate to create a ticket in the "Issues" section.

```
Configuring terminfo.
Configuring libubox.
Configuring libuclient.
Configuring uclient-fetch.
Configuring libpthread.
Configuring opkg.
Configuring libubus.
Configuring libjson-c.
Configuring libblobmsg-json.
Configuring ubusd.
Configuring ubus.
Configuring busybox.
Configuring libncurses.
Configuring libreadline.
Configuring bash.
Configuring libuci.
Configuring libnl-tiny.
Configuring swconfig.
Configuring kmod-nf-conntrack.
Configuring kmod-nf-flow.
Configuring kmod-lib-crc-ccitt.
Configuring iw-full.
Configuring kmod-nf-reject.
Configuring kmod-nf-ipt.
Configuring kmod-ipt-core.
Configuring kmod-ipt-conntrack.
Configuring jshn.
Configuring netifd.
Configuring libjson-script.
Configuring ubox.
Configuring procd.
Configuring jsonfilter.
Configuring usign.
Configuring openwrt-keyring.
Configuring fstools.
Configuring fwtool.
Configuring base-files.
Configuring kmod-nf-nat.
Configuring libpcre.
Configuring macchanger.
Configuring wireless-regdb.
Configuring kmod-cfg80211.
Configuring hostapd-common.
Configuring kmod-mac80211.
Configuring kmod-lib-crc-itu-t.
Configuring kmod-rt2x00-lib.
Configuring kmod-rt2800-lib.
Configuring coreutils.
Configuring dnsmasq.
Configuring kmod-mt76-core.
Configuring kmod-mt76x02-common.
Configuring kmod-mt76x2-common.
Configuring kmod-mt76x2.
Configuring kmod-mt7603.
Configuring kmod-mt76.
Configuring kmod-eeprom-93cx6.
Configuring kmod-rt2x00-mmio.
Configuring kmod-rt2x00-pci.
Configuring kmod-rt2800-mmio.
Configuring rt2800-pci-firmware.
Configuring kmod-rt2800-pci.
Configuring libxtables.
Configuring libip4tc.
Configuring libip6tc.
Configuring kmod-nf-conntrack6.
Configuring kmod-ipt-nat.
Configuring firewall.
Configuring odhcp6c.
Configuring uci.
Configuring wpad-mini.
Configuring libpcap.
Configuring libstdcpp.
Configuring zlib.
Configuring nmap.
Configuring dropbear.
Configuring mtd.
Configuring kmod-leds-gpio.
Configuring kmod-gpio-button-hotplug.
Configuring logd.
Configuring coreutils-sleep.
Configuring iptables.
Configuring kmod-rt2800-soc.
Configuring kmod-ipt-offload.

Finalizing root filesystem...

Building images...
Unable to open feeds configuration at openwrt-imagebuilder-18.06.9-ramips-mt7620.Linux-x86_64/scripts/feeds line 48.
Parallel mksquashfs: Using 1 processor
Creating 4.0 filesystem on openwrt-imagebuilder-18.06.9-ramips-mt7620.Linux-x86_64/build_dir/target-mipsel_24kc_musl/linux-ramips_mt7620/root.squashfs, block size 262144.
Pseudo file "/dev" exists in source filesystem "openwrt-imagebuilder-18.06.9-ramips-mt7620.Linux-x86_64/build_dir/target-mipsel_24kc_musl/root-ramips/dev".
Ignoring, exclude it (-e/-ef) to override.
[===========================================================================================================================\] 653/653 100%
Exportable Squashfs 4.0 filesystem, xz compressed, data block size 262144
  compressed data, compressed metadata, compressed fragments, no xattrs
  duplicates are removed
Filesystem size 4717.57 Kbytes (4.61 Mbytes)
  24.19% of uncompressed filesystem size (19498.60 Kbytes)
Inode table size 6644 bytes (6.49 Kbytes)
  22.47% of uncompressed inode table size (29573 bytes)
Directory table size 8830 bytes (8.62 Kbytes)
  48.79% of uncompressed directory table size (18099 bytes)
Number of duplicate files found 90
Number of inodes 882
Number of files 604
Number of fragments 21
Number of symbolic links  200
Number of device nodes 1
Number of fifo nodes 0
Number of socket nodes 0
Number of directories 77
Number of ids (unique uids + gids) 1
Number of uids 1
  unknown (0)
Number of gids 1
  unknown (0)
2820+1 records in
2820+1 records out
1444324 bytes (1.4 MB, 1.4 MiB) copied, 0.0180661 s, 79.9 MB/s
9435+1 records in
9435+1 records out
4830790 bytes (4.8 MB, 4.6 MiB) copied, 0.0307931 s, 157 MB/s
padding image to 005fd000
padding image to 005fe000
padding image to 00600000

Calculating checksums...

```

Voila, you can now install your JabberJaw firmware into your device :)


WiFi default password: jabberjaw<br>
SSH default IP: 172.16.24.1<br>
SSH default port: 22<br>
SSH default password: jabberjaw<br>

### Video PoC

[![Video PoC JabberJaw network attack tool](https://i.ibb.co/7gXHL9q/500px-youtube-social-play.png)](https://www.youtube.com/watch?v=B5So8t2lyR4)

- The Mac address of the device will change automatically after each reboot.
- All Shark Jack payloads from Hak5 are compatible with JabberJaw.

### What's next?

For now, I have included the minimum to run all payloads using Nmap properly. The next step will be to add Tmate (https://tmate.io/) in order to have a remote access on the device and extend the JabberJaw capabilities. Also it is possible, but not sure yet, that I could create a custom web interface to manage some important stuff such as payloads, change password, change the SSID etc.. This will be useful for the uninitiated OpenWrt users.

### Note
FOR EDUCATIONAL PURPOSE ONLY.
