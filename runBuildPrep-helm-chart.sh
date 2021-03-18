#!/usr/bin/env sh
# Copyright 2019-2021 Hewlett Packard Enterprise Development LP
source ./vars.sh

# Set the product name and version
sed -i s/@product_name@/csm/g kubernetes/cray-csm-barebones-recipe-install/values.yaml
sed -i s/@product_version@/${CSM_RELEASE_VERSION}/g kubernetes/cray-csm-barebones-recipe-install/values.yaml

# Debug
cat kubernetes/cray-csm-barebones-recipe-install/values.yaml
