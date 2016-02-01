#!/bin/bash

if test $(id -u) != "0"; then
  echo "Please supply root's password to install this package. "
  su -c "$0"
  ret=$?
  exit $ret
fi

MODNAME=rr272x_1x
#`grep TARGETNAME product/*/linux/Makefile | sed s'# ##'g | cut -d\= -f2 | sed s'#\r##'`

#echo $MODNAME

if [ "$MODNAME" == "" ]; then
  echo "Could not determine driver name"
fi

rm -rf product/*/linux/*.ko
rm -rf product/*/linux/.build

rm -rf /usr/share/hptdrv/$MODNAME
mkdir -p /usr/share/hptdrv/
cp -R `pwd` /usr/share/hptdrv/$MODNAME
rm -f /usr/share/hptdrv/$MODNAME/install.sh
chown -R 0:0 /usr/share/hptdrv/$MODNAME

#touch /etc/sysconfig/hptdrv || exit 1
#echo MODLIST=\"$MODNAME\" > /etc/sysconfig/hptdrv

rm -f /etc/init.d/hptdrv-monitor
cp dist/hptdrv-function /usr/share/hptdrv/
cp dist/hptdrv-monitor /etc/init.d/
cp dist/hptdrv-rebuild /usr/sbin/
cp dist/hptdrv-update /etc/cron.daily/
chmod 755 /etc/init.d/hptdrv-monitor /usr/sbin/hptdrv-rebuild /etc/cron.daily/hptdrv-update /usr/share/hptdrv/hptdrv-function

. /usr/share/hptdrv/hptdrv-function
echo "Checking and installing required toolchain and utility ..."

checkandinstall() {
  if ! type $1 >/dev/null 2>&1; then
    #echo "Installing program $1 ..."
    installtool $1 || return 1
  else
    echo "Found program $1 (`type -p $1`)"
    return 0
  fi
}

checkandinstall make
checkandinstall gcc
checkandinstall perl
checkandinstall wget

#touch /var/lock/subsys/hptdrv-monitor
if type update-rc.d >/dev/null 2>&1; then
  update-rc.d -f hptdrv-monitor remove >/dev/null 2>&1
  update-rc.d hptdrv-monitor defaults >/dev/null 2>&1
elif type systemctl >/dev/null 2>&1; then
  if test -d "/lib/systemd/system"; then
    # ubuntu14.10
    cp dist/hptdrv-monitor.service /lib/systemd/system/
  else
    cp dist/hptdrv-monitor.service /usr/lib/systemd/system/
  fi
  # suse 13.1 bug
  if test -f "/usr/lib/systemd/system/network@.service"; then
    mkdir -p "/usr/lib/systemd/system/network@.service.d/"
    cp dist/50-before-network-online.conf "/usr/lib/systemd/system/network@.service.d/"
  fi
  systemctl daemon-reload >/dev/null 2>&1
  systemctl enable hptdrv-monitor
  systemctl start hptdrv-monitor > /dev/null 2>&1
elif type insserv >/dev/null 2>&1; then
  insserv -r /etc/init.d/hptdrv-monitor
  insserv /etc/init.d/hptdrv-monitor
else
  ln -sf ../init.d/hptdrv-monitor /etc/rc0.d/K01hptdrv-monitor
  ln -sf ../init.d/hptdrv-monitor /etc/rc6.d/K01hptdrv-monitor
  ln -sf ../init.d/hptdrv-monitor /etc/rc1.d/S01hptdrv-monitor
  ln -sf ../init.d/hptdrv-monitor /etc/rc2.d/S01hptdrv-monitor
  ln -sf ../init.d/hptdrv-monitor /etc/rc3.d/S01hptdrv-monitor
  ln -sf ../init.d/hptdrv-monitor /etc/rc4.d/S01hptdrv-monitor
  ln -sf ../init.d/hptdrv-monitor /etc/rc5.d/S01hptdrv-monitor
fi

/etc/init.d/hptdrv-monitor start

/etc/init.d/hptdrv-monitor force-stop

# vim: expandtab ts=2 sw=2 ai
