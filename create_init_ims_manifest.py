#!/usr/bin/env python3
#
# MIT License
#
# (C) Copyright 2020-2022 Hewlett Packard Enterprise Development LP
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
import json
import re
import os
import stat
import sys

ARTIFACT_MAPPING = {
    "kernel":          "application/vnd.cray.image.kernel",
    "vmlinuz":         "application/vnd.cray.image.kernel",
    "initrd":          "application/vnd.cray.image.initrd",
    "squashfs":        "application/vnd.cray.image.rootfs.squashfs",
    "tar.xz":          "application/vnd.cray.image.rootfs.tar",
    "boot_parameters": "application/vnd.cray.image.parameters.boot",
}

artifact_list = []


def create_manifest(files, distro, image_name, arch, require_dkms):
    # NOTE:
    # There are limitations to the inputs on this:
    # 1) All recipes must have 'recipe' in the name
    # 2) It is assumed there is just one recipe in the manifest
    # 3) All other files are assumed to be images in one boot package
    
    # Changes:
    # - allow more than one recipe
    # - pull arch from the name for images and recipes?
    
    global artifact_list
    recipe_info = {}
    for f_name in files:
        # Not a fan of this next line, still thinking.
        if "recipe" in f_name:
            recipe_info = update_recipe_list(f_name, distro, arch, require_dkms)
            continue
        for key, value in ARTIFACT_MAPPING.items():
            if key in f_name:
                artifact_list.append(update_artifact_list(f_name, value))

    dict_info = {
        'version': "1.0.0",
        'images': {
            f'{image_name}': {
                'artifacts': artifact_list
            }
        },
        'recipes': {
            f'{image_name}': recipe_info
        }
    }
    with open(r'manifest.yaml', 'w') as file:
        yaml.dump(dict_info, file)


def update_artifact_list(artifact, arti_type):
    original_artifact = artifact
    fix_file_perms(original_artifact)
    artifact = re.sub('^(.*[\\\/])', '', artifact)
    new_item = {
        'link': {
            'path': f'/{artifact}',
            'type': 'file'
        },
        'md5': f'{get_md5sum(original_artifact)}',
        'type': f'{arti_type}'
    }
    return new_item


def update_recipe_list(recipe, distro, arch, require_dkms):
    original_recipe = recipe
    recipe = re.sub('^(.*[\\\/])', '', recipe)
    new_item = {
        'link': {
            'path': f'/{recipe}',
            'type': 'file'
        },
        'md5': f'{get_md5sum(original_recipe)}',
        'linux_distribution': f'{distro}',
        'recipe_type': 'kiwi-ng',
        'arch': f'{arch}',
        'require_dkms': require_dkms
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
    parser.add_argument('--distro', type=str, help='Distribution type.')
    parser.add_argument('--arch', type=str, default='x86_64', help='arch: x86_64 or aarch64')
    parser.add_argument('--require-dkms', type=bool, default=False, help='If dkms is required to be enabled')
    args = parser.parse_args()
    args.files = list(args.files.split())

    return args

def main():
    print(sys.argv)
    args = create_arg_parser()
    print(f"files: {args.files}")
    print(f"distro: {args.distro}")
    print(f"image: {args.image_name}")
    print(f"arch: {args.arch}")
    print(f"dkms: {args.require_dkms}")
    
    create_manifest(args.files, args.distro, args.image_name, arch=args.arch, require_dkms=args.require_dkms)

if __name__ == '__main__':
    main()
