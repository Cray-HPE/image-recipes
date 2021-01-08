# Copyright 2019, Cray Inc. All Rights Reserved.
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
