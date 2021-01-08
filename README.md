# Shasta Image Recipes

This repository maintains Cray developed image recipes for building bootable and 
non-bootable images to be used for Shasta based systems.

### Prerequisites

To build the recipes in this project, you will need to have access to a system
or virtual machine with the appropriate image building tools installed. It is
expected that, over time, recipes for a variety of different image building tools
will be available and maintained. Recipes for a particular image tool (kiwi-ng,
for example) will be kept under a common directory.

### Release Overrides

> IMPORTANT: Due to limitations of the DST Jenkins Pipeline, the `cray-csm-barebones-recipe-install` 
helm chart does not properly tag the correct docker image version for the 
`cray-csm-sles15sp1-barebones-recipe`. This unfortunately means that, the helm chart
cannot be installed without overriding this value either manually or via the CSM sysmgmt
manifest. Follow the instructions below to set the correct default override in the CSM 
sysmgmt manifest.

1. From the `kiwiImageRecipeBuildPipeline` job, find the docker image version for the
   `cray-csm-sles15sp1-barebones-recipe` image
   
    ```
    + docker push dtr.dev.cray.com/cray/cray-csm-sles15sp1-barebones-recipe:1.0.0-20201207175822_177d071
   ```
   
2. Update the [CSM sysmgmt.yaml manifest](https://stash.us.cray.com/projects/CSM/repos/csm/browse/manifests/sysmgmt.yaml)

   ```
      - name: cray-csm-barebones-recipe-install
        version: 1.0.10-20201201150554+4012455
        namespace: services
        values:      
          cray-import-kiwi-recipe-image:
            import_image:
              name: cray-csm-sles15sp1-barebones-recipe
              tag: 1.0.0-20201207175822_177d071
   ```