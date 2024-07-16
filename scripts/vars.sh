#
# MIT License
#
# (C) Copyright 2020-2024 Hewlett Packard Enterprise Development LP
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

export PRODUCT_CSM="csm"
export PRODUCT_COS="cos"
export VERSION="csm-1.6"

export SLES_VERSION="15"
export SLES_SPNUM=5
export SLES_SP="SP${SLES_SPNUM}"
export SLES_SP_LOWER="sp${SLES_SPNUM}"
export SLES_ARCH="x86_64"

# Variables for MTL generated compute images
# NOTE: COMPUTE_IMAGE_ID gets imported from https://raw.githubusercontent.com/Cray-HPE/csm/release/CSM_REL/assets.sh
export COMPUTE_IMAGE_SERVER="https://artifactory.algol60.net/artifactory/csm-images/stable/compute/"

# For developing for a master distribution, use 'master' here.
# For developing for a release distribution, use product release version
#  - ${GIT_BRANCH} comes from the Jenkins pipeline
#  - List versions of dependencies here as well
if [ "${GIT_BRANCH:-master}" == "master" ]
then
    export CSM_RELEASE_VERSION="master"
    export COS_RELEASE_VERSION="master"
else
    export CSM_RELEASE_VERSION="1.6"
    export COS_RELEASE_VERSION="2.2"
fi

# DST prefixes in bloblet locations
if [ "${CSM_RELEASE_VERSION}" == "master" ]
then
    export RELEASE_PREFIX="dev"
else
    export RELEASE_PREFIX="release"
fi

# Artifact Bloblet Locations for UAN and its dependencies
## NOTE: ARTIFACTORY_USER and ARTIFACTORY_TOKEN are defined in the jenkinsfile
##  by the 'withCredentials' function and passed through the docker call in
##  the Makefile.
export BLOBLET_CSM="https://${ARTIFACTORY_USER}:${ARTIFACTORY_TOKEN}@artifactory.algol60.net/artifactory/csm-rpms/hpe/stable/sle-${SLES_VERSION}sp${SLES_SPNUM}"
export BLOBLET_COS="https://arti.hpc.amslabs.hpecorp.net/artifactory/${PRODUCT_COS}-rpm-stable-local/release/${PRODUCT_COS}-${COS_RELEASE_VERSION}"
export BLOBLET_OS="https://${ARTIFACTORY_USER}:${ARTIFACTORY_TOKEN}@artifactory.algol60.net/artifactory/sles-mirror"
