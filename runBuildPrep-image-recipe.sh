#!/usr/bin/env sh
# Copyright 2020-2021 Hewlett Packard Enterprise Development LP
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

source ./vars.sh

# Set the cray-sles15sp2-csm-barebones image version from build time environment variables

sed -i s/CRAY.VERSION.HERE/${CSM_RELEASE_VERSION}/g kiwi-ng/cray-sles15sp2-barebones/config-template.xml.j2

# Set the cray-ims-load-artifacts image version
ims_load_artifacts_image_tag="1.3.2"
sed -i s/@ims_load_artifacts_image_tag@/${ims_load_artifacts_image_tag}/g Dockerfile_csm-sles15sp2-barebones.image-recipe

# Set the product version in the DockerDockerfile_csm-sles15sp2-barebones.image-recipe file
sed -i s/@product_version@/${VERSION}/g Dockerfile_csm-sles15sp2-barebones.image-recipe
