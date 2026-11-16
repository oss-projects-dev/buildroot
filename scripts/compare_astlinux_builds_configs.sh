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

diff -ruN $BUILDROOT_DIR/configs-backup/pc_x86_64_astlinux_runnix_defconfig.config           $BUILDROOT_DIR/runnix.config
diff -ruN $BUILDROOT_DIR/configs-backup/pc_x86_64_astlinux_runnix_iso_defconfig.config       $BUILDROOT_DIR/runnix-iso.config
diff -ruN $BUILDROOT_DIR/configs-backup/pc_x86_64_astlinux_initrd_defconfig.config           $BUILDROOT_DIR/x86_64-configs/initrd.config
diff -ruN $BUILDROOT_DIR/configs-backup/pc_x86_64_astlinux_astlinux_ast18se_defconfig.config $BUILDROOT_DIR/x86_64-configs/astlinux-ast18se.config
diff -ruN $BUILDROOT_DIR/configs-backup/pc_x86_64_astlinux_astlinux_ast20_defconfig.config   $BUILDROOT_DIR/x86_64-configs/astlinux-ast20.config

