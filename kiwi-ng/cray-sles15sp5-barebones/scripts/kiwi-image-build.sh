#!/bin/bash
#
# MIT License
#
# (C) Copyright 2020-2023 Hewlett Packard Enterprise Development LP
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
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# Builds OS Image from the Kiwi recipe and packages recipe as tgz
#
# Artifacts that will be packaged up should be placed in /base/build/output

set -ex
source /base/vars.sh

# Set up arch vars as needed
export ARCH=x86_64
export SLES_ARCH="x86_64"
if [ $BUILD_ARCH = 'aarch64' ];
then
    export ARCH=amd64
    export SLES_ARCH="aarch64"
fi
echo "BUILD_ARCH=${BUILD_ARCH}, ARCH=${ARCH}"

IMAGE_NAME=cray-shasta-csm-barebones-sles${SLES_VERSION}${SLES_SP_LOWER}.${SLES_ARCH}-${IMG_VER}

# Setup build directories
mkdir -p /base/build/output /base/build/unpack

# Set the value of the directory of the kiwi description and go there
DESC_DIR=/base/kiwi-ng/cray-sles${SLES_VERSION}${SLES_SP_LOWER}-barebones
cd $DESC_DIR

# Preprocess the Kiwi description config file (for on system use)
scripts/config-process.py \
    --input config-template.xml.j2 \
    --output config.xml \
    values-shasta.yaml.j2

# Preprocess the Zypper configuration file for the image (for on system use)
mkdir -p $DESC_DIR/root/root/bin
scripts/config-process.py \
    --input zypper-addrepo.sh.j2 \
    --output root/root/bin/zypper-addrepo.sh \
    values-shasta.yaml.j2
chmod 755 root/root/bin/zypper-addrepo.sh

# Package up the recipe after file templating is complete.
# 'recipe' must be in the name for it to be captured by the script that creates
# the import manifest for IMS.
tar -C $DESC_DIR -zcvf /base/build/output/${IMAGE_NAME}-recipe.tgz --exclude=*.j2  --exclude=scripts *
tar -ztvf /base/build/output/${IMAGE_NAME}-recipe.tgz
echo "Outputting recipe: /base/build/output/${IMAGE_NAME}-recipe.tgz"

# Only build the image if this is for x86_64
if [ $BUILD_ARCH = 'x86_64' ];
then
    # Preprocess the Kiwi description config file (for DST pipeline use)
    rm config.xml
    scripts/config-process.py \
        --input config-template.xml.j2 \
        --output config.xml \
        values-cje.yaml.j2

    # Build OS image with Kiwi NG (add --debug for lots 'o output)
    time /usr/bin/kiwi-ng --debug --type tbz system build --description $DESC_DIR --target-dir /build/output

    # Build squashfs from OS image tarball and place in /base/build/output for
    # packaging in later pipeline steps.
    cd /base/build/unpack
    TARBALL=$(echo /build/output/*.tar.xz)
    time tar --extract --xz --numeric --file $TARBALL
    time mksquashfs . ${IMAGE_NAME}.squashfs -comp xz -no-progress
    cp ${IMAGE_NAME}.squashfs /base/build/output/

    # Copy kernel and initrd to output directory
    cp boot/initrd  /base/build/output/${IMAGE_NAME}.initrd
    cp boot/vmlinuz /base/build/output/${IMAGE_NAME}.vmlinuz

    # We don't need to deliver the tar.xz version. Remove it to
    # save space in the docker image that delivers the image to the system.
    rm /base/build/output/*.tar.xz
fi