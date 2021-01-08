#!/usr/bin/env sh
# Copyright 2020 Hewlett Packard Enterprise Development LP

# Build the CSM barebones image, this is done in the pipeline, hence the
# /base directory prefix. See the pipeline definition here:
#   https://stash.us.cray.com/projects/DST/repos/jenkins-shared-library/browse/vars/kiwiImageRecipeBuildPipeline.groovy

/base/kiwi-ng/cray-sles15sp1-barebones/scripts/kiwi-image-build.sh