
# JabberJaw

JabberJaw is a re-code of the famous Shark Jack device developed by Hak5 which turn any OpenWrt compatible router into a portable network attack device.
As the Shark Jack firmware is a slightly modified version of OpenWrt (18.06-SNAPSHOT) it is possible to create your own custom firmware adapted to any router.

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
   MPR-A1 which integrates a 1800mah (4hours) battery and that you can
   find on Aliexpress for ~18$.

Last thing, because of limitation on small travel routers I will not implement a GUI to save space. Everything will be managed via SSH. 

### Recommended router.
Note: All router with 4MB of memory flash will need an external USB flash drive to extend the root filesystem. 

Device         | CPU (MHZ)         | Flash MB| RAM MB | Battery | More info|
-------------| -----------| -----------| -----------| -----------|-----------|
MPR-A1 | 360 |4|16|Yes (1800mah)|https://openwrt.org/toh/hame/mpr-a1
A5-V11 | 360 |4|16/32|No|https://openwrt.org/toh/unbranded/a5-v11
Buffalo WMR-300 | 580 |8|64|No|https://openwrt.org/toh/buffalo/wmr-300
Elecom WRH-300CR | 580 |16|64|No (But battery can be soldered)|https://openwrt.org/toh/hwdata/elecom/elecom_wrh-300cr

That's all for now but I'll add more relevant routers later. 

### Build your own JabberJaw firmware.

In the following tutorial I will take as example the Buffalo WMR-300 which is a small travel router that I will transform into a Shark Jack. In your case adapt the tutorial to your device.

The first thing to do is to clone the repository. Once cloned let’s download the OpenWrt image builder associated to the right architecture, in my case the architecture used by the WMR-300 is ramips/mt7620. And in order to save a maximum of space the version 18 of OpenWrt is recommended.
```bash
git clone https://github.com/Nwqda/JabberJaw.git
cd JabberJaw
wget https://downloads.openwrt.org/releases/18.06.9/targets/ramips/mt7620/openwrt-imagebuilder-18.06.9-ramips-mt7620.Linux-x86_64.tar.xz
tar xJf openwrt-imagebuilder-18.06.9-ramips-mt7620.Linux-x86_64.tar.xz
```

Before compiling our firmware one important thing to do is to modify the management of the leds. Indeed the Shark Jack uses a combo of several colors (Red, Green, Blue, Mixed) to recognize for example when the device is in the middle of execution of the payload and when the execution of the payload is completed the led will change color. And on this point again each device has different configuration. So you have to modify the file /usr/bin/LED in order to indicate the correct path of the leds management. To find out this for your device you have to decompile an OpenWrt firmware pre-build to your device and look at the different files stored in /sys/class/leds/.
I will write soon a complete article on my blog that will cover this step too.

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

### Under construction, the next part is coming soon...