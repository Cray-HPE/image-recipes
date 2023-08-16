#!/usr/bin/env python3
#
# MIT License
#
# (C) Copyright 2023 Hewlett Packard Enterprise Development LP
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

import sys
import argparse
import time
import os
from typing import Tuple

from requests.packages import urllib3
import requests

# Download the given file from the given url
def downloadFile(urlDir: str, localDir: str, filename: str) -> None:
    '''
    This function downloads the files as a stream in chunks. If there is a failed read
    it will attempt to resume from the last successful location.
    '''

    # Open the requests session. NOTE: if there are required creds for the site, they should
    # be present in the .netrc file.
    session = requests.session()
    session.verify = False
    url = urlDir + filename
    local_filename = localDir + filename
    print(f"Downloading: {url} to {local_filename}")

    # Open the output file and start reading from the remote server
    chunk_size=1024*1024
    max_retries = 10
    written = 0
    retries = 0
    lastFailedSize = 0
    failedChunkSleep = 5  # after a failed chunk give it 5 sec to try again
    with open(local_filename, 'wb') as outf:
        while retries < max_retries:
            try:
                # Set up there the read should start - always go the end of the file
                resume_header = {'Range': 'bytes=%d-' % written}

                # Open the read
                with session.get(url, headers=resume_header, stream=True) as r:
                    # make sure the get is successful
                    r.raise_for_status()

                    # try to read the rest of the file
                    for chunk in r.iter_content(chunk_size=chunk_size):
                        outf.write(chunk)
                        written += chunk_size

                    # if everything reads, break from the while loop
                    break
            except requests.exceptions.ChunkedEncodingError:
                # if we are making progress, keep trying
                if lastFailedSize != written:
                    retries = 0
                    lastFailedSize = written
                else:
                    # if there are repeated failures only try max_retries times
                    retries += 1
                    time.sleep(failedChunkSleep)
                print(f"  chunked encoding error: written:{written} - retry:{retries}")

        # if we failed out record and exit
        if retries == max_retries:
            print(f"ERROR - Failed to download {url} - exiting")
            sys.exit(1)

def findImagesInDir(url: str) -> Tuple[dict, dict]:
    print(f"Searching for images in: {url}")

    # Get the http listing of the dir
    # NOTE: creds need to be set up in .netrc file for this to work
    session = requests.session()
    session.verify = False
    r = session.get(url)
    r.raise_for_status()

    # Find images for both arch types
    aarch64 = dict()
    x86 = dict()

    # split the http response into lines and pick out files
    str = r.content.decode('utf-8')
    lines = str.splitlines()
    for line in lines:
        # html references to files start with '<a href="' - pull out the filename after that
        if len(line)>9 and line[:9]=='<a href="':
            # pull out the filename from the http reference link
            filename = line[9:9+line[9:].find('"')]

            # filter which files we want to keep
            if 'aarch64' in filename:
                addImageFile(aarch64, filename)
            elif 'x86_64' in filename:
                addImageFile(x86, filename)

    return x86, aarch64

def addImageFile(d: dict, filename: str) -> None:
    # Figure out if this is a file we want and what type it is
    if 'kernel' in filename:
        d['kernel'] = filename
    if 'squashfs' in filename:
        d['squashfs'] = filename
    elif 'initrd' in filename:
        d['initrd'] = filename

def validateKey(d: dict, key: str, name: str) -> None:
    # Make sure the key exists in the dict - exit on fail
    if key in d:
        print(f"Found {key} file for {name}: {d[key]}")
    else:
        print(f"Did not find {key} file for {name} - exiting")
        sys.exit(1)

def validateFiles(x86: dict, aarch64: dict) -> None:
    # Make sure we found all file types for both architectures
    validateKey(x86, "kernel", "x86_64")
    validateKey(x86, "initrd", "x86_64")
    validateKey(x86, "squashfs", "x86_64")
    validateKey(aarch64, "kernel", "aarch64")
    validateKey(aarch64, "initrd", "aarch64")
    validateKey(aarch64, "squashfs", "aarch64")

def checkPathWritable(targetPath: str) -> None:
    if not os.access(path=targetPath, mode=os.W_OK):
        print(f"Unable to access {targetPath} for write - exiting")
        sys.exit(1)

def main():
    '''
    This script downloads files from artifactory.algol60.net to include in the
    barebones image/recipe install package. To include other images just create
    a new dir under 'download' and the subdir name will be the name of the image
    and the contents of the dir will be uploaded as the image.
    
    Currently this script pulls in 2 images, a pre-built csm only compute image
    with both x86_64 and aarch64 versions.
    '''
    # this is an insecure connection - disable the warning
    requests.packages.urllib3.disable_warnings(requests.packages.urllib3.exceptions.InsecureRequestWarning)

    # Create command line arg parser
    parser = argparse.ArgumentParser()
    parser.add_argument('--targetDir', type=str, help='Directory to download images into.')
    parser.add_argument('--compute-image-version', type=str, help='Version of the compute image to download')
    parser.add_argument('--compute-image-server', type=str, help='Server address to download images from')
    parser.add_argument('--csm-version', type=str, help='CSM Version this is being packaged for')
    args = parser.parse_args(sys.argv[1:])

    # Pull the args from the input
    version = args.compute_image_version
    server = args.compute_image_server
    targetDir = args.targetDir
    csmVer = args.csm_version
    print(f"Building package for: {csmVer}")
    print(f"Input server: {server}, version: {version}, target dir:{targetDir}")

    # Make sure the local dirs are OK
    x86Dir = f"{targetDir}/compute-{csmVer}-{version}-x86_64/"
    aarch64Dir = f"{targetDir}/compute-{csmVer}-{version}-aarch64/"
    checkPathWritable(targetDir)
    os.makedirs(name=x86Dir, exist_ok=True)
    os.makedirs(name=aarch64Dir, exist_ok=True)
    checkPathWritable(x86Dir)
    checkPathWritable(aarch64Dir)

    # Find the files present in the repo
    urlDir = server + version + "/"
    x86, aarch64 = findImagesInDir(urlDir)

    # Make sure all the files for both x86 and aarch64 were found
    validateFiles(x86, aarch64)

    # Download the files found
    downloadFile(urlDir, x86Dir, x86['kernel'])
    downloadFile(urlDir, x86Dir, x86['initrd'])
    downloadFile(urlDir, x86Dir, x86['squashfs'])
    downloadFile(urlDir, aarch64Dir, aarch64['kernel'])
    downloadFile(urlDir, aarch64Dir, aarch64['initrd'])
    downloadFile(urlDir, aarch64Dir, aarch64['squashfs'])

if __name__ == '__main__':
    main()
