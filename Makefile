#
# MIT License
#
# (C) Copyright 2019-2023 Hewlett Packard Enterprise Development LP
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
# MIT License

NAME ?= cray-csm-sles15sp5-barebones-recipe
DOCKER_VERSION ?= $(shell head -1 .docker_version)
CHART_VERSION ?= $(shell head -1 .chart_version)

PRODUCT_VERSION ?= $(shell sh ./.productVersionScript)
BUILD_DATE ?= $(shell date +'%Y%m%d%H%M%S')
GIT_BRANCH ?= local
GIT_TAG ?= $(shell git rev-parse --short HEAD)
IMG_VER ?= ${PRODUCT_VERSION}-${BUILD_DATE}-g${GIT_TAG}

IMAGE_NAME ?= cray-shasta-csm-sles15sp5-barebones
DISTRO ?= sles15

DOCKERFILE ?= Dockerfile_csm-sles15sp5-barebones.image-recipe
BUILD_IMAGE ?= arti.hpc.amslabs.hpecorp.net/cos-docker-master-local/cray-kiwi:latest
BUILD_SCRIPT ?= scripts/runKiwiBuild.sh
DOWNLOAD_SCRIPT ?= scripts/runImageDownload.sh
RECIPE_DIRECTORY ?= kiwi-ng/cray-sles15sp5-barebones

CHART_NAME ?= cray-csm-barebones-recipe-install
CHART_PATH ?= kubernetes
HELM_UNITTEST_IMAGE ?= quintush/helm-unittest:3.3.0-0.2.5

all : runbuildprep lint kiwi_image chart
kiwi_image: kiwi_build_prep kiwi_download_images kiwi_build_image kiwi_build_manifest kiwi_docker_image
chart: chart_setup chart_package chart_test

runbuildprep:
	./cms_meta_tools/scripts/runBuildPrep.sh

lint:
	./cms_meta_tools/scripts/runLint.sh

kiwi_build_prep:
	ls -ald build build/output build/output/build build/output/build/image-root build/output/build/image-root/etc build/output/build/image-root/etc/lvm build/output/build/image-root/etc/lvm/archive || true
	ls -al build/output || true
	docker run -v ${PWD}:/base \
		${BUILD_IMAGE}
		rm -rf /base/build
	ls -ald build build/output build/output/build build/output/build/image-root build/output/build/image-root/etc build/output/build/image-root/etc/lvm build/output/build/image-root/etc/lvm/archive || true
	ls -al build/output || true
	./scripts/runBuildPrep-image-recipe.sh
	ls -ald build build/output build/output/build build/output/build/image-root build/output/build/image-root/etc build/output/build/image-root/etc/lvm build/output/build/image-root/etc/lvm/archive || true

kiwi_download_images:
	ls -ald build build/output build/output/build build/output/build/image-root build/output/build/image-root/etc build/output/build/image-root/etc/lvm build/output/build/image-root/etc/lvm/archive || true
	ls -al build/output || true
	./scripts/runImageDownload.sh
	ls -ald build build/output build/output/build build/output/build/image-root build/output/build/image-root/etc build/output/build/image-root/etc/lvm build/output/build/image-root/etc/lvm/archive || true

kiwi_build_image:
	ls -ald build build/output build/output/build build/output/build/image-root build/output/build/image-root/etc build/output/build/image-root/etc/lvm build/output/build/image-root/etc/lvm/archive || true
	ls -al build/output || true
	docker run --rm --privileged \
		-e PARENT_BRANCH=${GIT_BRANCH} -e PRODUCT_VERSION=${PRODUCT_VERSION} \
		-e IMG_VER=${IMG_VER} -e BUILD_DATE=${BUILD_DATE} -e GIT_TAG=${GIT_TAG} \
		-e ARTIFACTORY_USER=${ARTIFACTORY_USER} -e ARTIFACTORY_TOKEN=${ARTIFACTORY_TOKEN} \
		-e BUILD_ARCH="x86_64" -v ${PWD}/build:/build -v ${PWD}:/base \
		${BUILD_IMAGE} \
		/bin/bash /base/${BUILD_SCRIPT} ${RECIPE_DIRECTORY}

	ls -ald build build/output build/output/build build/output/build/image-root build/output/build/image-root/etc build/output/build/image-root/etc/lvm build/output/build/image-root/etc/lvm/archive || true
	ls -al build/output || true
	# build aarch64 recipe only
	docker run --rm --privileged \
		-e PARENT_BRANCH=${GIT_BRANCH} -e PRODUCT_VERSION=${PRODUCT_VERSION} \
		-e IMG_VER=${IMG_VER} -e BUILD_DATE=${BUILD_DATE} -e GIT_TAG=${GIT_TAG} \
		-e ARTIFACTORY_USER=${ARTIFACTORY_USER} -e ARTIFACTORY_TOKEN=${ARTIFACTORY_TOKEN} \
		-e BUILD_ARCH="aarch64" -v ${PWD}/build:/build -v ${PWD}:/base \
		${BUILD_IMAGE} \
		/bin/bash /base/${BUILD_SCRIPT} ${RECIPE_DIRECTORY}

	ls -ald build build/output build/output/build build/output/build/image-root build/output/build/image-root/etc build/output/build/image-root/etc/lvm build/output/build/image-root/etc/lvm/archive || true
	ls -al build/output || true

kiwi_build_manifest:
	ls -ald build build/output build/output/build build/output/build/image-root build/output/build/image-root/etc build/output/build/image-root/etc/lvm build/output/build/image-root/etc/lvm/archive || true
	ls -al build/output || true
	$(eval FILES := $(shell find build/output/* -maxdepth 0 | tr '\r\n' ' ' ))
	ls -ald build build/output build/output/build build/output/build/image-root build/output/build/image-root/etc build/output/build/image-root/etc/lvm build/output/build/image-root/etc/lvm/archive || true
	ls -al build/output || true
	docker run --rm --privileged \
		-e PARENT_BRANCH=${GIT_BRANCH} -e PRODUCT_VERSION=${PRODUCT_VERSION} \
		-e IMG_VER=${IMG_VER} -e BUILD_TS=${BUILD_DATE} -e GIT_TAG=${GIT_TAG} \
		-v ${PWD}/build:/build -v ${PWD}/download:/download -v ${PWD}:/root \
		--workdir /root \
		${BUILD_IMAGE} \
		bash -c 'ls -al /build && ls -la /download && ls -la && pwd && python3 scripts/create_init_ims_manifest.py --distro "${DISTRO}" --files "${FILES}" --downloadDir "download" ${IMAGE_NAME}-${PRODUCT_VERSION}'
	ls -ald build build/output build/output/build build/output/build/image-root build/output/build/image-root/etc build/output/build/image-root/etc/lvm build/output/build/image-root/etc/lvm/archive || true
	cat manifest.yaml

kiwi_docker_image:
	ls -ald build build/output build/output/build build/output/build/image-root build/output/build/image-root/etc build/output/build/image-root/etc/lvm build/output/build/image-root/etc/lvm/archive || true
	DOCKER_BUILDKIT=1 docker build --pull ${DOCKER_ARGS} -f ${DOCKERFILE} --tag '${NAME}:${DOCKER_VERSION}' .

chart_setup:
	mkdir -p ${CHART_PATH}/.packaged
	./scripts/runBuildPrep-helm-chart.sh

chart_package:
	helm dep up ${CHART_PATH}/${CHART_NAME}
	helm package ${CHART_PATH}/${CHART_NAME} -d ${CHART_PATH}/.packaged --app-version ${DOCKER_VERSION} --version ${CHART_VERSION}

chart_test:
	helm lint "${CHART_PATH}/${CHART_NAME}"
	docker run --rm -v ${PWD}/${CHART_PATH}:/apps ${HELM_UNITTEST_IMAGE} -3 ${CHART_NAME}
