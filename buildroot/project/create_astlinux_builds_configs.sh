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
BUILDS_DIR=$HOME/astlinux-builds-configs

rm -rf $BUILDS_DIR

create_build() {
local build_file=$1
local build_file_dir=$(dirname $1)
local build_name=$(basename $1)
build_name=${build_name//.config/}
local build_dir=$BUILDS_DIR/output-${build_name}
mkdir -p $build_dir
make -C $BUILDROOT_DIR O=$build_dir pc_x86_64_bios_defconfig
cp -av $build_file ${build_dir}/.config
echo "BR2_BUILD_USE_CUSTOM_SCRIPTS=y" >> ${build_dir}/.config                  # add Custom Scripts Use before itself so existing parameters are not lost
echo "BR2_BUILD_USE_ASTLINUX_SCRIPTS=y" >> ${build_dir}/.config                # add Custom Scripts Use before itself so existing parameters are not lost
sed -e "s@BR2_PACKAGE_CURL@BR2_PACKAGE_LIBCURL_CURL@g" -i ${build_dir}/.config # BR2_PACKAGE_CURL is renamed to BR2_PACKAGE_LIBCURL_CURL
sed -e "s@BR2_ENABLE_LOCALE_WHITELIST=\"\"@BR2_ENABLE_LOCALE_WHITELIST=\"C en_US\"@g" -i ${build_dir}/.config
if grep -Fq "BR2_LINUX_KERNEL_CUSTOM_TARBALL_LOCATION=" ${build_dir}/.config; then
  sed -e '/BR2_LINUX_KERNEL_CUSTOM_TARBALL_LOCATION=/s/.*/BR2_LINUX_KERNEL_CUSTOM_TARBALL_LOCATION="https:\/\/www.kernel.org\/pub\/linux\/kernel\/projects\/cip\/6.12\/linux-cip-6.12.114-cip34.tar.xz"/' -i ${build_dir}/.config
  sed -s '/BR2_LINUX_KERNEL_CUSTOM_TARBALL_LOCATION/a BR2_LINUX_KERNEL_NEEDS_HOST_LIBELF=y' -i ${build_dir}/.config #libelf is required in linux-6.12
fi
if [[ $build_name == astlinux* ]]; then
  sed -e 's@BR2_ROOTFS_DEVICE_CREATION_DYNAMIC_UDEV=y@BR2_ROOTFS_DEVICE_CREATION_DYNAMIC_EUDEV=y@g' -i ${build_dir}/.config
  sed -e 's@BR2_PACKAGE_CURL=y@BR2_PACKAGE_LIBCURL_CURL=y@g'                                        -i ${build_dir}/.config
  sed -e 's@BR2_PACKAGE_JPEG=y@BR2_PACKAGE_LIBJPEG=y@g'                                             -i ${build_dir}/.config
  sed -e 's@BR2_PACKAGE_OPENSSL=y@BR2_PACKAGE_LIBOPENSSL=y@g'                                       -i ${build_dir}/.config
  sed -e 's@BR2_PACKAGE_OPENSSL_BIN=y@BR2_PACKAGE_LIBOPENSSL_BIN=y@g'                               -i ${build_dir}/.config
  sed -e 's@BR2_PACKAGE_OPENSSL_ENGINES=y@BR2_PACKAGE_LIBOPENSSL_ENGINES=y@g'                       -i ${build_dir}/.config
  sed -e 's@BR2_PACKAGE_UDEV=y@BR2_PACKAGE_EUDEV=y@g'                                               -i ${build_dir}/.config
  sed -e 's@BR2_PACKAGE_ZLIB=y@BR2_PACKAGE_LIBZLIB=y@g'                                             -i ${build_dir}/.config
fi
# initscripts is automatically selected if using busybox init or sysv init
# disable urandom scripts which are enabled by default
echo "# BR2_PACKAGE_URANDOM_SCRIPTS is not set" >> ${build_dir}/.config

(
  cd $build_dir
  make olddefconfig
  cp -av .config .config-before-script-changes
  make savedefconfig
  sed -e "/^BR2_WGET=/d"                                                                                                  -i defconfig # remove the existing WGET parameters
  sed -e "/^BR2_SVN=/d"                                                                                                   -i defconfig # remove the existing SVN parameters
  sed -e "/^BR2_GNU_MIRROR=/d"                                                                                            -i defconfig # remove the existing BR2_GNU_MIRROR parameters
  sed -e "s@astlinux/x-tools-1.25.0-5.10-2.31/x86_64-unknown-linux-gnu@x86_64-buildroot-linux-gnu_sdk-buildroot-13.5.0@g" -i defconfig # change the toolchain
  sed -e "s@x86_64-unknown-linux-gnu@x86_64-buildroot-linux-gnu@g"                                                        -i defconfig # change the toolchain
  sed -e '/BR2_TOOLCHAIN_EXTERNAL_CUSTOM_PREFIX/a BR2_TOOLCHAIN_EXTERNAL_GCC_13=y\nBR2_TOOLCHAIN_EXTERNAL_HEADERS_6_12=y' -i defconfig
  sed -e '/BR2_TOOLCHAIN_EXTERNAL_CUSTOM_GLIBC/a # BR2_TOOLCHAIN_EXTERNAL_INET_RPC is not set'                            -i defconfig
  sed -e '/BR2_TOOLCHAIN_EXTERNAL_CXX/a BR2_TOOLCHAIN_EXTERNAL_FORTRAN=y\nBR2_TOOLCHAIN_EXTERNAL_OPENMP=y'                -i defconfig
  cp -av defconfig .config
  make olddefconfig
  sed -e "s#(CONFIG_DIR)/defconfig#(TOPDIR)/configs/pc_x86_64_astlinux_${build_name//-/_}_defconfig#" -i .config
  make saveconfig
)
echo "( cd ${build_dir} && make saveconfig )" >> $BUILDS_DIR/backup_configs.sh
}

create_build $BUILDROOT_DIR/project/configs-astlinux/runnix.config
create_build $BUILDROOT_DIR/project/configs-astlinux/runnix-iso.config
create_build $BUILDROOT_DIR/project/configs-astlinux/x86_64-configs/initrd.config
create_build $BUILDROOT_DIR/project/configs-astlinux/x86_64-configs/astlinux-ast18se.config
create_build $BUILDROOT_DIR/project/configs-astlinux/x86_64-configs/astlinux-ast20.config

chmod +x $BUILDS_DIR/backup_configs.sh
