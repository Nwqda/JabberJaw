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
chmod +x /usr/bin/LED
chmod +x /usr/bin/NETMODE

# Disable AutoSSH
# /etc/init.d/autossh disable
# /etc/init.d/autossh stop

# Disable SSH server
# /etc/init.d/sshd disable
# /etc/init.d/sshd stop

# Disable odhcpd
# /etc/init.d/odhcpd disable
# /etc/init.d/odhcpd stop

# Disable uHTTPd web server
# /etc/init.d/uhttpd disable
# /etc/init.d/uhttpd stop

# Enable Shark service
# /etc/init.d/shark enable
# /etc/init.d/shark start


# Ensure the script is deleted after execution
exit 0
