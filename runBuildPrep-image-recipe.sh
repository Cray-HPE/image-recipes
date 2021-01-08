#!/usr/bin/env sh
# Copyright 2020 Hewlett Packard Enterprise Development LP
source ./vars.sh

# Set the cray-sles15sp1-csm-barebones image version from build time environment variables

sed -i s/CRAY.VERSION.HERE/${CSM_RELEASE_VERSION}/g kiwi-ng/cray-sles15sp1-barebones/config-template.xml.j2

# Set the cray-ims-load-artifacts image version
wget http://car.dev.cray.com/artifactory/shasta-premium/SCMS/noos/noarch/dev/master/cms-team/manifest.txt
ims_load_artifacts_image_tag=$(grep cray-ims-load-artifacts manifest.txt | sed s/.*://g | tr -d '[:space:]')
sed -i s/@ims_load_artifacts_image_tag@/${ims_load_artifacts_image_tag}/g Dockerfile_csm-sles15sp1-barebones.image-recipe
rm manifest.txt

# Set the product version in the DockerDockerfile_csm-sles15sp1-barebones.image-recipe file
sed -i s/@product_version@/${VERSION}/g Dockerfile_csm-sles15sp1-barebones.image-recipe
