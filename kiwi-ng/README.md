# Sles12sp5 Barebones Recipe

## Building

Build your image using the [ims build container](https://github.com/Cray-HPE/ims) 
or manually using kiwi-ng as shown below.

    $ sudo kiwi-ng --type tbz system build --description /image-recipes/kiwi-ng/cray-sles12sp5-barebones --target /tmp/image-root/
    ...
    [ INFO    ]: 11:36:00 | --> image_packages: /tmp/image-root/cray-sles12sp5-barebones.x86_64-1.0.0.packages
    [ INFO    ]: 11:36:00 | --> image_verified: /tmp/image-root/cray-sles12sp5-barebones.x86_64-1.0.0.verified
    [ INFO    ]: 11:36:00 | --> root_archive: /tmp/image-root/cray-sles12sp5-barebones.x86_64-1.0.0.tar.xz
    [ INFO    ]: 11:36:00 | --> root_archive_md5: /tmp/image-root/cray-sles12sp5-barebones.x86_64-1.0.0.md5

## Populate NFS Root File System share

Currently we are using the "Q2 NFS Share" method of distributing the root file system to the booting node.
This is expected to change and be replaced with something that allows better scale and performance. However
exactly what and how that will work is TBD. The ShastaCMS team is no longer responsible for fan out of the
root file systems so any change to this procedure is dependent upon other Cray teams.

See the Q2 Demo Script for procedures to setup NFS.

Untar the archive into an appropriately named subdirectory under /var/lib/nfsroot


    # tar xf cray-sles12sp5-barebones.x86_64-1.0.0.tar.xz  -C /var/lib/nfsroot/cmp1_barebones_image

Add to the /etc/exports file your NFS directory you will be mounting on the compute node using the above path:


    # cat /etc/exports
    ...
    /var/lib/nfsroot/cmp1_sles12sp5_image/ *(rw,sync,no_root_squash,no_subtree_check)
    
    
"exportfs -a" will add your new directory to available exports


    # exportfs -a

## Booting


Export the following variables for your system, making sure to update the values appropriately. 

    $ export $SMS_SERVER_FQDN=sms2.squirt.next.cray.com
    $ export SMS_SERVER_IP=10.100.176.12
    $ export BOOTIF=A4:BF:01:28:95:80
    $ export IMAGE_ROOT=/var/lib/nfsroot/cmp1_barebones_image
    
Run the [cn_helper](https://stash.us.cray.com/projects/SMTEST/repos/robot/browse/utils/cn_helper.py) 
script to upload the kernel, initrd and kernel command line parameters. Note that
the kernel and initrd are being pulled directly from the nfsroot.
    
    $ python cn_helper.py $SMS_SERVER_FQDN 7 $IMAGE_ROOT/boot/vmlinuz \
                          $IMAGE_ROOT/boot/initramfs-cray.img \ 
                          "console=tty0 console=ttyS0,115200n8 initrd={} \
                          root=nfs:$SMS_SERVER_IP:$IMAGE_ROOT:rw nofb \ 
                          selinux=0 rd.shell BOOTIF=$BOOTIF ip=eth1:dhcp crashkernel=256M" 

Powercycle the node and watch the console log.


    $ ipmitool -Ilanplus -H cmp1-bmc.squirt.next.cray.com -U root -P <image-root-password> sol activate
    ...
    Welcome to SUSE Linux Enterprise Server 12 sp5  (x86_64) - Kernel 4.4.143-94.47-default (ttyS0).

    linux login: root
    Password:
    #################################################
    # Welcome                                       #
    #################################################
    
    You have logged into a Cray Barebones Image
    
    This node is running SLES 12sp5 SuSE Linux System.
    
    Please contact your IT system admin for any support requests.
    
    linux:~ #
