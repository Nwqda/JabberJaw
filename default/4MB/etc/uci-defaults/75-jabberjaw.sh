#!/bin/sh
# Firstboot setup script for the Jabberjaw by Naqwada Security

# Change root password
echo -e "jabberjaw\njabberjaw\n" | passwd

# Change the hostname
uci set system.@system[0].hostname=JabberJaw
uci commit system
echo $(uci get system.@system[0].hostname) > /proc/sys/kernel/hostname

# Macchanger script executable
chmod +x /etc/init.d/macchanger
# Trick script to capture wan down/up event from kernel
chmod +x /etc/init.d/rt3050-event-tracker

# Hak5 scripts executable 
chmod +x /usr/bin/LED
chmod +x /usr/bin/NETMODE


# Ensure the script is deleted after execution
exit 0
