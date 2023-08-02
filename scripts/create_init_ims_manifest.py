#!/usr/bin/env python3
#
# MIT License
#
# (C) Copyright 2020-2023 Hewlett Packard Enterprise Development LP
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
import argparse
import yaml
import hashlib
import re
import os
import stat
import sys

from pathlib import Path

ARTIFACT_MAPPING = {
    "Image":           "application/vnd.cray.image.kernel",
    "kernel":          "application/vnd.cray.image.kernel",
    "vmlinuz":         "application/vnd.cray.image.kernel",
    "initrd":          "application/vnd.cray.image.initrd",
    "squashfs":        "application/vnd.cray.image.rootfs.squashfs",
    "tar.xz":          "application/vnd.cray.image.rootfs.tar",
    "boot_parameters": "application/vnd.cray.image.parameters.boot",
}

def create_manifest(files, downloadDir, distro, image_name):
    # create the base manifest information
    manifest_info = {
        'version': "1.1.0",
        'images': {
        },
        'recipes': {
        }
    }

    # handle the files from the recipes and built images
    add_built_files(manifest_info=manifest_info, files=files, distro=distro, image_name=image_name)

    # handle the images downloaded but not built here
    add_downloaded_images(manifest_info=manifest_info, downloadDir=downloadDir)

    # write out the manifest file
    with open(r'manifest.yaml', 'w') as file:
        yaml.dump(manifest_info, file)

def add_downloaded_images(manifest_info: dict, downloadDir: str) -> None:
    '''
    Each subdir of the downloadDir will be treated as a separate image to be
    imported. The name of the subdir will be interpreted as the name of the
    resulting image. The arch of the image (x86_64 or aarch64) must be in either
    the subdir name, or at least one of the image file names. If there are conflicts
    this will exit with a failure.
    '''
    # get the subdirs of downloadDir
    print(f"Walking: {downloadDir}")
    for path,dirs,files in os.walk(downloadDir):
        print(f"Processing Path: {path}, Dirs: {dirs}, Files: {files}")
        if len(files) == 0:
            print(f"  No files found - skipping")
            continue

        # pickle away the image name
        imageName = str(Path(path).relative_to(downloadDir))
        imageArch = None
        artifact_list = []

        print(f" ImageName: {imageName}")
        # see if the dir name has the arch in it
        if 'x86_64' in imageName:
            imageArch = 'x86_64'
        elif 'aarch64' in imageName:
            imageArch = 'aarch64'

        # process each img file
        for imgFile in files:
            # Pull the arch from the filename - compare with current arch
            fileFullPath = os.path.join(path,imgFile)
            print(f"  Processing file: {imgFile}")
            if 'x86_64' in imgFile:
                if imageArch is None:
                    imageArch = 'x86_64'
                elif imageArch != 'x86_64':
                    print(f"Error in {fileFullPath} - incompatible arch. Exiting")
                    sys.exit(1)
            elif 'aarch64' in imgFile:
                if imageArch is None:
                    imageArch = 'aarch64'
                elif imageArch != 'aarch64':
                    print(f"Error in {fileFullPath} - incompatible arch. Exiting")
                    sys.exit(1)

            # process the type of file
            for key, value in ARTIFACT_MAPPING.items():
                if key in imgFile:
                    print(f"  Found artifact {key}:{value}")
                    artifact_list.append(update_artifact_list(fileFullPath, value, imageName))

        # make sure an arch was specified
        if imageArch is None:
            print(f"Was not able to determine arch of {path}")
            sys.exit(1)

        # record this image in the manifest
        manifest_info['images'][f'{imageName}'] = {'artifacts' : artifact_list, 'arch':f'{imageArch}'}

def add_built_files(manifest_info: dict, files: list, distro: str, image_name: str) -> None:
    # Process the file list building up recipe info and image artifacts
    # NOTE - for the time being, this is assuming possible multiple
    # recipes (same recipe, different arch versions) and one pre-built image
    artifact_list = []
    recipe_list = []
    for f_name in files:
        print(f"Processing {f_name}")
        # Not a fan of this next line, still thinking.
        if "recipe" in f_name:
            print(f"  Found recipe")
            recipe_list.append(update_recipe_list(f_name, distro))
            continue
        for key, value in ARTIFACT_MAPPING.items():
            if key in f_name:
                print(f"  Found artifact {key}:{value}")
                artifact_list.append(update_artifact_list(f_name, value))

    # Add recipes to the manifest
    # If there is only one, use the image-name provide
    if len(recipe_list) == 1:
        manifest_info['recipes'][f'{image_name}'] = recipe_list[0]
    else:
        # add appending the arch to each if there are more than one
        for recipe in recipe_list:
            name = f"{image_name}-{recipe['arch']}"
            manifest_info['recipes'][f'{name}'] =  recipe

    # Add images to the manifest
    # NOTE: only one image (arch:x86_64) created now, this will need to be updated
    #  if we start releasing multiple images.
    manifest_info['images'][f'{image_name}'] = {'artifacts' : artifact_list, 'arch':'x86_64'}

def update_artifact_list(artifact, arti_type, path_dir=None):
    original_artifact = artifact
    fix_file_perms(original_artifact)
    artifact = re.sub('^(.*[\\\/])', '', artifact)
    if path_dir != None:
        artifact = f'{path_dir}/{artifact}'
    print(f"    RE processed artifact name: {artifact}")
    new_item = {
        'link': {
            'path': f'/{artifact}',
            'type': 'file'
        },
        'md5': f'{get_md5sum(original_artifact)}',
        'type': f'{arti_type}'
    }
    return new_item


def update_recipe_list(recipe, distro):
    # strip out base direcotries from image name
    original_recipe = recipe
    recipe = re.sub('^(.*[\\\/])', '', recipe)
    
    # figure out arch from image name - default to x86_64
    arch = 'x86_64'
    if 'aarch64' in recipe or 'arm64' in recipe:
        arch = 'aarch64'

    # construct the recipe data object
    # NOTE: require_dkms is always false for the barebones images
    new_item = {
        'link': {
            'path': f'/{recipe}',
            'type': 'file'
        },
        'md5': f'{get_md5sum(original_recipe)}',
        'linux_distribution': f'{distro}',
        'recipe_type': 'kiwi-ng',
        'arch': f'{arch}',
        'require_dkms': False
    }

    return new_item


def fix_file_perms(filename):
    """
    Make sure the file is universally readable
    
    NOTE: this is required since the build env is running under the root
    user, but the images that package the artifacts are not.  Make sure
    all artifacts are publicly readable so the next comsumer can read them.
    """
    read_mask = stat.S_IRUSR | stat.S_IRGRP | stat.S_IROTH
    curr_perms = stat.S_IMODE(os.lstat(filename).st_mode)
    os.chmod(filename, curr_perms | read_mask)


def get_md5sum(filename):
    """ Utility for efficient md5sum of a file """
    hashmd5 = hashlib.md5()
    with open(filename, "rb") as afile:
        for chunk in iter(lambda: afile.read(4096), b""):
            hashmd5.update(chunk)
    return hashmd5.hexdigest()


def create_arg_parser():
    parser = argparse.ArgumentParser(description='Creates a manifest file to be consumed by the a docker image.')
    parser.add_argument('image_name', type=str,
                        help='Name of the kiwi image and kiwi recipe.')
    parser.add_argument('--files', type=str, help='List of files to update the manifest file with.')
    parser.add_argument('--downloadDir', type=str, help='Directory where downloaded images are stored.')
    parser.add_argument('--distro', type=str, help='Distribution type.')
    args = parser.parse_args()
    args.files = list(args.files.split())

    return args

def main():
    args = create_arg_parser()
    create_manifest(args.files, args.downloadDir, args.distro, args.image_name)

if __name__ == '__main__':
    main()
