# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
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

[1.4.9] - (no date)
