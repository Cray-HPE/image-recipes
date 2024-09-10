#!/usr/bin/env sh
#
# MIT License
#
# (C) Copyright 2023-2024 Hewlett Packard Enterprise Development LP
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

set -ex

# Get the other defined vars
source scripts/vars.sh

# Get the current version of the MTL compute image 'COMPUTE_IMAGE_ID'
source /dev/stdin <<< "$(curl -s https://raw.githubusercontent.com/Cray-HPE/csm/release/${CSM_MAJ_MIN}/assets.sh)"

# Get the other defined vars
source scripts/vars.sh

# Call downloadImages with the compute image version
mkdir -p download
scripts/downloadImages.py --targetDir download --csm-version ${VERSION} --compute-image-version ${COMPUTE_IMAGE_ID} --compute-image-server ${COMPUTE_IMAGE_SERVER}
