#!/usr/bin/env bash

# https://stackoverflow.com/questions/59895/how-do-i-get-the-directory-where-a-bash-script-is-located-from-within-the-script

get_script_dir()
{
    local SOURCE_PATH="${BASH_SOURCE[0]}"
    local SYMLINK_DIR
    local SCRIPT_DIR
    # Resolve symlinks recursively
    while [ -L "$SOURCE_PATH" ]; do
        # Get symlink directory
        SYMLINK_DIR="$( cd -P "$( dirname "$SOURCE_PATH" )" >/dev/null 2>&1 && pwd )"
        # Resolve symlink target (relative or absolute)
        SOURCE_PATH="$(readlink "$SOURCE_PATH")"
        # Check if candidate path is relative or absolute
        if [[ $SOURCE_PATH != /* ]]; then
            # Candidate path is relative, resolve to full path
            SOURCE_PATH=$SYMLINK_DIR/$SOURCE_PATH
        fi
    done
    # Get final script directory path from fully resolved source path
    SCRIPT_DIR="$(cd -P "$( dirname "$SOURCE_PATH" )" >/dev/null 2>&1 && pwd)"
    echo "$SCRIPT_DIR"
}

script_dir=$(get_script_dir)
script_base_dir=$(dirname $script_dir)

BUILDROOT_DIR=$script_base_dir

ASTLINUX_FOLDER=$BUILDROOT_DIR

process_file() {
while IFS= read -r line; do
    # Process each line here
    echo "Processing: $line"
    grep -rl "config $line$" $ASTLINUX_FOLDER/package | grep "\.in$\|\.ext$"
done < <(cat $1)
}

cat $ASTLINUX_FOLDER/x86_64-configs/astlinux-ast18se.config \
    $ASTLINUX_FOLDER/x86_64-configs/astlinux-ast20.config \
    $ASTLINUX_FOLDER/x86_64-configs/initrd.config \
    $ASTLINUX_FOLDER/runnix.config \
    $ASTLINUX_FOLDER/runnix-iso.config | grep "^BR2_PACKAGE_" | grep "=y" | sed -e 's@=y@@g' | sort -u \
    > /tmp/temp.config
process_file /tmp/temp.config
