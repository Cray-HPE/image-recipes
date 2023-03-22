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
# Process values for the Kiwi image build depending on the build environment
# (cje=Jenkins pipeline, shasta=shasta on-system image).
# This is a generic script that takes in j2 templates and renders them.
import os
import sys

import argparse
from pprint import pprint
from jinja2 import Environment, FileSystemLoader, Template
import yaml

# Create command line arg parser
parser = argparse.ArgumentParser(usage='./{0} [--input <input>] [--output <output>] <values_file>'.format(sys.argv[0]))
parser.add_argument('-i', '--input')
parser.add_argument('-o', '--output')
parser.add_argument('values_file')
args = parser.parse_args(sys.argv[1:])

# Seed the template rendering values with the environment variables
values = {"env": os.environ}

# Get input values and template them if required
with open(args.values_file, 'r') as data:
    values.update(yaml.safe_load(data))

# Template the repos from the values_file
repos = []
for repo in values['repos']:
    repo["path"] = Template(repo["path"]).render(**values)
    repo["alias"] = Template(repo["alias"]).render(**values)
    repo["details"] = Template(repo["details"]).render(**values)
    repos.append(repo)
    pprint(repo)

# Replace the repos in the values dictionary
values['repos'] = repos

# Load the template file
env = Environment(loader=FileSystemLoader('./'))
template = env.get_template(args.input)

# Generate output file
with open(args.output, 'w') as output:
    output.write(template.render(**values))
    output.write('\n')
