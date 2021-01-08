# Copyright 2020 Hewlett Packard Enterprise Development LP

export PRODUCT_CSM="csm"
export PRODUCT_COS="cos"
export VERSION="shasta-1.4"

# For developing for a master distribution, use 'master' here.
# For developing for a release distribution, use product release version
#  - ${PARENT_BRANCH} comes from the DST pipeline
#  - List versions of dependencies here as well
if [ "${PARENT_BRANCH:-master}" == "master" ]
then
    export CSM_RELEASE_VERSION="master"
    export COS_RELEASE_VERSION="master"
else
    export CSM_RELEASE_VERSION="1.4"
    export COS_RELEASE_VERSION="1.4"
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
