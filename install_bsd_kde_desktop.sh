#!/bin/sh
#
# This is my Primary script for personal use in my home and my office.
#
# It is based on FreeBSD Lasterst releng and using both ports and Project pre-built binaries.
#
# This script uses KDE5 lastest version as the Desktop Enviroment.
#
# It is, as it stands now, very customized to my personal needs
# and has gone though several versions even before I started to
# number it. It's beginning purpose was for a rapid
# reinstall of a gui or rapid deployment on multiple machines in a
# small office.
#
# But as I worked on it, this script became more custom for my setup.
# Alter it as needed to fit your needs.
#
#
# As can be seen I have opted for a full desktop in xfce along with a few
# extra things that I prefer.
#
# This is not considered a light-weight install, but dependent on 
# the stuff you install you can keep your package count below 400.              
# That's not to bad imho.
#
#####################
# Location and lang #
#####################
# Setup language for all users made on system
# Skel/login_conf
echo 'Setup language for all users made on system Skel/login_conf'

cat << EOF >> /usr/share/skel/dot.login_conf
me:\
   :charset=UTF-8:\
   :lang=en_US.UTF-8:
EOF

#################################################
# Base system setup. fstab, rc, loader, sysctl, #
#################################################
# Setup /etc/rc.conf
echo 'Clear out default rc.conf and replace with custom rc.conf'
cp /dev/null /etc/rc.conf

# Change this to match your machine setup.
echo 'Write Johns machine specific custom rc.conf to file.'
echo '\
# File System Section.\
zfs_enable="YES"\
\
# load kernel modules.
#kld_list="i915kms vmm nmdm if_bridge"\
kld_list="i915kms"\
\
# Set system to route\
#gateway_enabled="YES"\
\
# VM and jail Networking\
#cloned_interfaces="bridge0 tap0 epair0a"\
#ifconfig_bridge0=" addm tap0 addm epair0a up"\
#ifconfig_bridge0_alias0="inet 10.0.4.1 netmask 255.255.255.0"\
\
# Networking Section-Interface startup and hostname.\
hostname="fletcher-6.localdoamin"\
background_dhclient="YES"\
ifconfig_em0="DHCP"\
#wlans_rtwn0="wlan0"\
#ifconfig_wlan0="WPA DHCP"\
#ifconfig_wlan0_ipv6="inet6 accept_rtadv"\
#create_args_wlan0="country US regdomain FCC"\
\
# Throttle CPU when it is idle, or jack it up if its busy.\
powerd_enable="YES"\
powerd_flags="-a hiadaptive -b adaptive -n adaptive"\
performance_cx_lowest="Cmax"\
economy_cx_lowest="Cmax"\

# Time-Start ntp and sync the clock.\
ntpdate_enable="YES"\
ntpd_enable="YES"\
ntpd_sync_on_start="YES"\
\
# Services needed by the desktop.\
# messaging system.\
dbus_enable="YES"\
# Load up the mouse\
mixer_enable="YES"\
# Load up the mouse.\
moused_enable="YES"\
moused_flags="-VH"\
# This is the display manager.\
sddm_enable="YES"\
# Load up the webcam\
webcamd_enable="YES"\
# Cups Printing\
cupsd_enable="YES"\

# Stuff to stop from starting\
syslogd_flags="-ss"\
sendmail_enable="NONE"\
sendmail_submit_enable="NO"\
sendmail_outbound_enable="NO"\
sendmail_msp_queue_enable="NO"\
\
# Remember to do file checks, but in the back ground please.\
fsck_y_enable="YES"\
background_fsck="YES"\
# Clear out the tmp folder on reboots.\
clear_tmp_enable="YES"\
Xorgclear_tmp_enable="YES"\
\
# Misc. startup\
' > /etc/rc.conf

# Setup /boot/loader.conf
cat << EOF >> /boot/loader.conf
kern.vty=vt
cryptodev_load="YES"
zfs_load="YES"
# Need for the webcam
cuse_load="YES"
EOF

# Setup /etc/sysctl.conf
echo 'Setup /etc/sysctl.conf'
cat << EOF >> /etc/sysctl.conf
# Enhance shared memory X11 interface
# grep memory /var/run/dmesg.boot
kern.ipc.shmmax=5859934592
# kern.ipc.shmmax / 4096
kern.ipc.shmall=2097152
# Enhance desktop responsiveness under high CPU use (200/224)
kern.sched.preempt_thresh=224
# Bump up maximum number of open files
kern.maxfiles=200000
# Disable PC Speaker
hw.syscons.bell=0
EOF

#####################
#  PKGNG            #
#####################
# In FreeBSD 10.2 the pkg repo is set to quarterly. I prefer to stay on latest.
# See https://forums.freebsd.org/threads/52843/ 
echo 'In FreeBSD 10.2 and forward the pkg repo is set to quarterly. I prefer to stay on latest.'
echo 'Make directory for the new file as descrbed in /etc/pkg/FreeBSD.conf'

mkdir -p /usr/local/etc/pkg/repos

echo 'Write file.'
cat << EOF >>  /usr/local/etc/pkg/repos/FreeBSD.conf
FreeBSD:{
  url: "pkg+http://pkg.FreeBSD.org/\${ABI}/latest"
}
EOF

# Set enviroment varible to allow bootstrapping / installing pkgng  
# on FreeBSD unattended and without answering Yes.
echo 'Bootstrapping / installing pkgng on FreeBSD unattended and without answering Yes.'
env ASSUME_ALWAYS_YES=YES pkg bootstrap


# Update pkgng repo on local system
echo 'Update pkgng repo on local system'
pkg update -f

# Load linux kernel module so packages that want it on install dont complain.
echo 'Loading linux kernel module'
kldload linux

# Install packages for desktop use.
pkg install -y 
	xorg-minimal\
	drm-kmod\
	plasma5-plasma\
	kde-baseapps\
	kdeutils\
	kdenetwork\
	kmix\
	sddm\
	octopkg\
	firefox\
	libreoffice\
	sudo\

#
####################
Restart            # 
####################
echo'rebooting now.....'
shutdown -r now

