#!/bin/bash
set -e

read -p "Enter your Edison's new hostname (this will be your rig's "name" in the future, so make sure to write it down): " -r
myedisonhostname=$REPLY
echo $myedisonhostname > /etc/hostname
sed -r -i"" "s/localhost( jubilinux)?$/localhost $myedisonhostname/" /etc/hosts

# if passwords are old, force them to be changed at next login
passwd -S edison | grep 20[01][0-6] && passwd -e root
# automatically expire edison account if its password is not changed in 3 days
passwd -S edison | grep 20[01][0-6] && passwd -e edison -i 3

# set timezone
dpkg-reconfigure tzdata

# TODO: remove this after Debian's IPv6 mirrors are stable again
mkdir -p /etc/apt/apt.conf.d/
echo 'Acquire::ForceIPv4 "true";' | tee /etc/apt/apt.conf.d/99force-ipv4

#dpkg -P nodejs nodejs-dev
apt-get update && apt-get -y dist-upgrade && apt-get -y autoremove
apt-get install -y sudo strace tcpdump screen acpid vim python-pip locate
adduser edison sudo
adduser edison dialout

sed -i "s/daily/hourly/g" /etc/logrotate.conf
sed -i "s/#compress/compress/g" /etc/logrotate.conf

#curl -s https://raw.githubusercontent.com/openaps/oref0/install-scripts/bin/openaps-packages.sh | bash -

# TODO: change back to dev after merging install-scripts to dev, then to master after next oref0 release
mkdir -p ~/src; cd ~/src && git clone -b install-scripts git://github.com/openaps/oref0.git || (cd oref0 && git checkout install-scripts && git pull)
~/src/oref0/bin/openaps-packages.sh
#echo "Press Enter to run oref0-setup with the current release (master branch) of oref0,"
echo "Press Enter to run oref0-setup with the install-scripts branch of oref0,"
read -p "or press ctrl-c to cancel. " -r
cd && ~/src/oref0/bin/oref0-setup.sh
