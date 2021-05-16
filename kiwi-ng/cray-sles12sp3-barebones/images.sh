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

# Query installed rpm to get kernel version.
leads=`rpm -q kernel-default --last --queryformat "%{VERSION}-%{RELEASE}\n" \
    | grep -v kernel | awk '{ sub(/[ \t]+$/, ""); print }' | sed -e 's/\(.*-.*\)\..*/\1/'`
kernel_version="${leads}-default"

# Lets check for a known module to insure we are using an complete kernel install
mypath="/lib/modules/${kernel_version}/kernel/net/sunrpc/sunrpc.ko"

echo "KERNEL VERSION  : ${kernel_version}"
echo "LIB MODULES PATH : $mypath"

# Bail if kernel module not found
if [ -e "${mypath}" ]; then
   dracut --no-hostonly --no-hostonly-cmdline -a "network nfs" --kver ${kernel_version} -I '/bin/grep' --xz -f /boot/initramfs-cray.img
else
   echo "Unable to validate presence of kernel modules directory ... aborting build\n"
   exit 1
fi
