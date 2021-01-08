# Copyright 2019, Cray Inc. All Rights Reserved.
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