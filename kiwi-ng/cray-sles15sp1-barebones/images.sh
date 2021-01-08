#!/usr/bin/env bash
# Copyright 2019, Cray Inc. All Rights Reserved.
echo "Generating initrd..."

# Query installed rpm to get kernel version. DST pipeline could install
# multiple kernels, so we need to be sure we are using the latest
# installed kernel
lead=`rpm -q kernel-default --last --queryformat "%{VERSION}-%{RELEASE}\n" | grep -v kernel | awk -F_ '{ print $1 }'`
kver=`echo ${lead} | awk -F. '{ print $1"."$2"."$3"-default" }'`

# Lets check for a known module to insure we are using an complete kernel install
libpath="/lib/modules/${kver}/kernel/net/sunrpc/sunrpc.ko"

echo "KERNEL VERSION  : ${kver}"
echo "LIB MODULES PATH : ${libpath}"

initrd_install="\
/usr/bin/awk \
/usr/bin/chmod \
/usr/bin/curl \
/usr/bin/date \
/usr/bin/expr \
/usr/bin/getopt \
/usr/bin/grep \
/usr/bin/jq \
/usr/bin/sed \
/usr/bin/sleep \
/usr/bin/wc \
"

# Bail if kernel module not found
if [ -e "${libpath}" ]; then
  # Generate the initrd
  dracut \
   --force \
   --install "${initrd_install}" \
   --no-hostonly \
   --no-hostonly-cmdline \
   --add-drivers 'squashfs overlay' \
   --add 'network nfs crayfs' \
   --kver ${kver} -I '/bin/grep' \
   --xz -f /boot/initrd
else
  echo "Unable to validate presence of kernel modules directory ... aborting build\n"
  exit 1
fi
