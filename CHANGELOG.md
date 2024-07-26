# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.1.2] - 2024-07-26
### Added
- CASMCMS-9066: Add `procps` to `bootstrap` package list in `kiwi-ng/cray-sles15sp5-barebones/config-template.xml.j2`,
  to fix build failure.

## [2.1.1] - 2024-04-24
### Changed
- CASMCMS-8973: Remove unnecessary build artifacts before creating final Docker image, to avoid permission problems.
- CASMCMS-8973: Remove redundant `DOCKER_VERSION` variable assignment from Jenkinsfile

## [2.1.0] - 2023-06-14

### Changed
- CASMCMS-8365 - add arm64 recipe support to barebones image recipes.

## [2.0.0] - 2023-05-23

### Changed

- CASMCMS-7922: Use version 2.5 of cray-ims-load-artifacts and version 4.0 of cray-import-kiwi-recipe-image, in
  order to create BOS session templates using BOS v2.

## [1.10.0] - 2023-05-23

### Changed

- CASMCMS-8646: Use version 2.4 of cray-ims-load-artifacts

## [1.9.0] - 2023-04-26

### Changed

- CASM-3868: Use version 2.3 of cray-ims-load-artifacts

## [1.8.0] - 2023-04-06

### Changed

- Update to use update_external_version to get latest patch version of base chart
- Update chart maintainers
- CASMTRIAGE-5163: Change to version 3.2 of the base chart (cray-import-kiwi-recipe-image)

## [1.7.4] - 2023-03-17

### Changed

- CASMCMS-8472: Build using artifactory authentication instead of unauthenticated mirrors, where possible

## [1.7.3] - 2023-03-14

### Changed

- CASMCMS-8252: Enabled building of unstable artifacts
- CASMCMS-8252: Updated header of update_versions.conf to reflect new tool options
- CASMCMS-8463: Use ims-load-artifacts version 2.2
- CASMCMS-8465: Use artifactory remote mirrors to avoid authentication issues

### Fixed

- Spelling corrections.
- CASMCMS-8252: Update Chart with correct image and chart version strings during builds.

### Removed

- CASMCMS-8463: Removed vestigial files from old versioning system.

## [1.7.2] - 2023-02-24

### Changed

- CASMTRIAGE-4950 - update the csm version in the recipe name.

## [1.7.1] - 2022-12-21

### Added

- Add Artifactory authentication to Jenkinsfile
- CASMTRIAGE-4750 - fix the name of the SP4 repos in the kiwi recipe.

## [1.7.0] - 2022-08-11

- CASMCMS-8075 - update the image and recipe to use sles15sp4.

## [1.6.0] - 2022-07-29

### Changed

- CASMTRIAGE-3756 - correct built image file permissions.
- CASMCMS-7970 - ims update cray.dev.com addresses

## [1.5.0] - 2022-07-01

### Added

- Update ims-load-artifacts to 1.4 to include templated recipe arguments.
