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

echo "Generating Cray initrd..."

# For CentOS we need to create the random and urandom device for rpm to work.
# RPM is used to determine the kernel versions installed. 
mknod -m 666 /dev/random c 1 8
mknod -m 666 /dev/urandom c 1 9

# Remove old kernels and just keep the most recently installed one
package-cleanup -y --oldkernels --count=1

# Find latest kernel rev, should only be one at this point
array=`rpm -q kernel --last --queryformat "%{VERSION}-%{RELEASE}\n" | grep -v kernel`
echo "array: $array"
IFS=$'\n' sorted=($(sort <<<"${array[*]}"))
unset IFS

kver=`echo "${sorted[0]}" | sed 's/ //g'`
echo "kver: $kver"

echo "Running dracut"
dracut -f --no-hostonly --no-hostonly-cmdline --add-drivers 'squashfs overlay' -a "network nfs" /boot/initramfs-cray.img ${kver}.x86_64

echo "Running mkdumprd"
mkdumprd /boot/initramfs-${kver}.x86_64kdump.img ${kver}.x86_64