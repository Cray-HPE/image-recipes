# Copyright 2021 Hewlett Packard Enterprise Development LP
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
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# (MIT License)

function run_cmd
{
    local rc=0
    "$@" || rc=$?
    if [ $rc -ne 0 ]; then
        echo "ERROR: Command failed with rc $rc: $*" 1>&2
    fi
    return $rc
}

function replace_tag_in_file
{
    # $1 tag string
    # $2 actual value
    # $3 target file

    local setx=${-//[^x]/}
    # If set, temporarily disable set -x, to reduce clutter
    [ -z "$setx" ] || set +x
    
    local tag actual target error tmpfile fakeloop
    if [ $# -ne 3 ]; then
        echo "PROGRAMMING LOGIC ERROR: $0 function requires exactly 3 arguments but received $#: $*" 1>&2
        [ -z "$setx" ] || set -x
        return 1
    fi
    error=0
    tag="$1"
    actual="$2"
    target="$3"
    if [ -z "$tag" ]; then
        echo "PROGRAMMING LOGIC ERROR: $0: tag argument may not be blank" 1>&2
        error=1
    fi
    
    # We allow the actual value to be blank, but issue a warning just in case
    if [ -z "$actual" ]; then
        echo "WARNING: $0: actual value is blank" 1>&2
    fi
    
    if [ -z "$target" ]; then
        echo "PROGRAMMING LOGIC ERROR: $0: target argument may not be blank"
        error=1
    elif [ ! -e "$target" ]; then
        echo "ERROR: $0: target file does not exist: '$target'" 1>&2
        error=1
    elif [ ! -f "$target" ]; then
        echo "ERROR: $0: target file exists but is not a regular file: '$target'" 1>&2
        ls -al "$target"
        error=1
    elif [ ! -s "$target" ]; then
        echo "ERROR: $0: target file is zero size: '$target'" 1>&2
        error=1
    fi

    if [ $error -ne 0 ]; then
        [ -z "$setx" ] || set -x
        return $error
    fi

    tmpfile="$target"
    while [ -e "$tmpfile" ]; do
        tmpfile="${target}.$$.$RANDOM.tmp"
    done

    echo "Setting '$tag' to '$actual' in '$target'"
    error=1
    for fakeloop in 1 ; do
        run_cmd cp "$target" "$tmpfile" || break
        run_cmd sed -i "s/${tag}/${actual}/g" "$target" || break
        echo "Changes:"
        if diff "$target" "$tmpfile" ; then
            echo "ERROR: sed command succeeded but no changes made to '$target'" 1>&2
            break
        fi
        run_cmd rm -f "$tmpfile" || break
        error=0
    done
    [ -z "$setx" ] || set -x
    return $error
}
