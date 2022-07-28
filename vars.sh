#
# MIT License
#
# (C) Copyright 2020-2022 Hewlett Packard Enterprise Development LP
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
export VERSION="csm-1.3"

# For developing for a master distribution, use 'master' here.
# For developing for a release distribution, use product release version
#  - ${GIT_BRANCH} comes from the Jenkins pipeline
#  - List versions of dependencies here as well
if [ "${GIT_BRANCH:-master}" == "master" ]
then
    export CSM_RELEASE_VERSION="master"
    export COS_RELEASE_VERSION="master"
else
    export CSM_RELEASE_VERSION="1.5"
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
export BLOBLET_CSM="http://dst.us.cray.com/dstrepo/bloblets/${PRODUCT_CSM}/${RELEASE_PREFIX}/${CSM_RELEASE_VERSION}"
export BLOBLET_COS="http://dst.us.cray.com/dstrepo/bloblets/${PRODUCT_COS}/${RELEASE_PREFIX}/${COS_RELEASE_VERSION}"
export BLOBLET_OS="http://dst.us.cray.com/dstrepo/bloblets/os/dev/mirrors"
