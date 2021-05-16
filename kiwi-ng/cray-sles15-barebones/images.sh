#!/usr/bin/env bash
# Copyright 2019, 2021 Hewlett Packard Enterprise Development LP
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# (MIT License)

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

# Bail if kernel module not found
if [ -e "${libpath}" ]; then
  # Generate the initrd
  dracut --no-hostonly --no-hostonly-cmdline --add-drivers 'squashfs overlay' -a 'network nfs crayfs' --kver ${kver} -I '/bin/grep' --xz -f /boot/initrd
else
  echo "Unable to validate presence of kernel modules directory ... aborting build\n"
  exit 1
fi
