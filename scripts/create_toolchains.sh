
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
BUILDS_DIR=$HOME/output-builds/toolchain-builds-defconfigs

rm -rf $BUILDS_DIR

create_build_dir() {
  mkdir -p $BUILDS_DIR/output-${1}
  make -C $BUILDROOT_DIR O=$BUILDS_DIR/output-${1} ${2}
  echo "( cd $BUILDS_DIR/output-${1} && make saveconfig )" >> $BUILDS_DIR/backup_configs.sh
}

create_build_dir toolchain13 pc_x86_64_toolchain13_defconfig
create_build_dir toolchain14 pc_x86_64_toolchain14_defconfig
create_build_dir toolchain15 pc_x86_64_toolchain15_defconfig

chmod +x $BUILDS_DIR/backup_configs.sh
