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

### Versioning
Use [SemVer](http://semver.org/). The version is located in the [.version](.version) file. Other files either
read the version string from this file or have this version string written to them at build time using the 
[update_versions.sh](update_versions.sh) script, based on the information in the 
[update_versions.conf](update_versions.conf) file.

### Copyright and License
This project is copyrighted by Hewlett Packard Enterprise Development LP and is under the MIT
license. See the [LICENSE](LICENSE) file for details.

When making any modifications to a file that has a Cray/HPE copyright header, that header
must be updated to include the current year.

When creating any new files in this repo, if they contain source code, they must have
the HPE copyright and license text in their header, unless the file is covered under
someone else's copyright/license (in which case that should be in the header). For this
purpose, source code files include Dockerfiles, Ansible files, RPM spec files, and shell
scripts. It does **not** include Jenkinsfiles, OpenAPI/Swagger specs, or READMEs.

When in doubt, provided the file is not covered under someone else's copyright or license, then
it does not hurt to add ours to the header.
