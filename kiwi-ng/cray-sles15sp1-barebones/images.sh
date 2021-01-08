#!/usr/bin/env bash
# Copyright 2019-2020 Hewlett Packard Enterprise Development LP
echo "Generating initrd..."

function version_matches {
    kernel_rpm_version=$1
    kernel_module_object=$2
    kernel_module_version=$(echo "$kernel_module_object" | awk -F/ '{ print $4 }' | awk -F- '{ print $1 "-" $2 }')
    echo "KERNEL_RPM_VERSION : ${kernel_rpm_version}"
    echo "KERNEL MODULE OBJECT : $kernel_module_object"
    echo "KERNEL MODULE VERSION : $kernel_module_version"
    if [[ $kernel_rpm_version =~ $kernel_module_version.* ]]; then
        return 0
    fi
    return 1
}

function find_kernel_version {
    kernel_rpm_version=$(rpm -q kernel-default --last --queryformat "%{VERSION}-%{RELEASE}\n" | grep -v kernel)
    kernel_module_object=$(find /lib/modules -print | grep sunrpc.ko)

    num=$(echo "$kernel_module_object" | wc -l)
    if [[ $num -eq 0 ]]; then
        echo "Could not find any installed sunrpc.ko kernel objects"
    elif [[ $num -eq 1 ]]; then
        if version_matches "$kernel_rpm_version" "$kernel_module_object"; then
            echo "Match found"
            return 0
        fi
    else
        echo "Multiple kernel modules match. Checking to see if one matches the version of the kernel rpm."
        while IFS= read -r line; do
            if version_matches "$kernel_rpm_version" "$line"; then
                echo "Match found"
                return 0
            fi
        done <<< "$kernel_module_object"
    fi

    echo "ERROR: Did not find a kernel version to use."
    return 1
}

if ! find_kernel_version; then
    exit 1
fi

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

dracut \
 --force \
 --install "${initrd_install}" \
 --no-hostonly \
 --no-hostonly-cmdline \
 --add-drivers 'squashfs overlay' \
 --add 'network nfs crayfs' \
 --kver "${kernel_module_version}"-default -I '/bin/grep' \
 --xz -f /boot/initrd
