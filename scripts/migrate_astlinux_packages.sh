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

BUILDROOT_FILES_DIR=$BUILDROOT_DIR/output-files
BUILDROOT_FILES_EXTRACT_DIR=$HOME/output-files

# notes AstLinux pulled on 2026-11-07
ASTVER=astlinux-338e17c4efd61b63fbecb66d3132a32e68440d83
BUILDROOTVER=buildroot-2025.02.20

MERGE_FOLDER=m-buildroot-merge-${BUILDROOTVER//buildroot-/}-${ASTVER//astlinux-/}
BASE_BUILDROOT_FOLDER=m-buildroot-orig-${BUILDROOTVER//buildroot-/}-${ASTVER//astlinux-/}

# --- start of check_and_download_file function

check_and_download_file() {
local URL=$1
local LOCAL_FILE=$2

if [ -f "$LOCAL_FILE" ]; then
    echo "✔ File '$LOCAL_FILE' already exists locally. Skipping download."
else
echo "⬇ File '$LOCAL_FILE' not found. Attempting to download..."

wget --tries=3 --waitretry=5 -O "$LOCAL_FILE" "$URL"

WGET_STATUS=$?

if [ $WGET_STATUS -eq 0 ]; then
    echo "✔ Download successful: '$LOCAL_FILE' saved."
else
    echo "❌ Error: Download failed with exit code $WGET_STATUS."
    
    [ -f "$LOCAL_FILE" ] && rm "$LOCAL_FILE"
    
    exit $WGET_STATUS
fi
fi
}

# --- end of check_and_download_file function
# --- start of process function

process() {
local dir_name=$1
local pkg_src_dir=$2
local pkg_name=$(basename $pkg_src_dir)
local pkg_rename_name=$3
local pkg_name_upper="${pkg_name^^}"
pkg_name_upper=${pkg_name_upper//-/_}

if [ "$pkg_rename_name" == "" ]; then pkg_rename_name=$pkg_name; fi

local pkg_rename_name_upper="${pkg_rename_name^^}"
pkg_rename_name_upper=${pkg_rename_name_upper//-/_}

mkdir -p $MERGE_FOLDER/$dir_name/$pkg_rename_name

echo "copying $ASTVER/$dir_name/$pkg_src_dir to $MERGE_FOLDER/$dir_name/$pkg_rename_name/$custom_folder_name"
mkdir -p $MERGE_FOLDER/$dir_name/$pkg_rename_name/$custom_folder_name
cp -a $ASTVER/$dir_name/$pkg_src_dir/* $MERGE_FOLDER/$dir_name/$pkg_rename_name/$custom_folder_name/

( 
  cd $MERGE_FOLDER/$dir_name/$pkg_rename_name/$custom_folder_name;
  if [[ "$pkg_name" != "$pkg_rename_name" ]]; then
    mv ${pkg_name}.mk ${pkg_rename_name}.mk
    sed -e "s@${pkg_name_upper}@${pkg_rename_name_upper}@g" -e "s@\"$pkg_name\"@\"$pkg_rename_name\"@g" -i *.in *.ext *.mk
  fi
  
  touch .gitkeep

  # below changes have to be done for all files before merging with buildroot files so both are separate
  # add custom-patch-dir
  sed -e "/${pkg_rename_name_upper}_SITE /a ${pkg_rename_name_upper}_CUSTOM_PATCH_DIR = $custom_folder_name" \
      -e "/${pkg_rename_name_upper}_SITE:=/a ${pkg_rename_name_upper}_CUSTOM_PATCH_DIR = $custom_folder_name" \
      -i *.mk
  # change default package path for files to custom_folder_name  
  if [[ "$pkg_src_dir" != "$pkg_name" ]]; then
    sed -e "s@$dir_name/$pkg_src_dir@$dir_name/$pkg_name@g" \
	    -i *.in *.ext *.mk
  fi
  if [[ "$pkg_name" != "$pkg_rename_name" ]]; then
    sed -e "s@$dir_name/$pkg_name@$dir_name/$pkg_rename_name@g" \
	    -i *.in *.ext *.mk
  fi
    
  sed -e "s@$dir_name/$pkg_rename_name@$dir_name/$pkg_rename_name/$custom_folder_name@g" \
	  -i *.in *.ext *.mk
)

if [ -d $BUILDROOTVER/$dir_name/$pkg_rename_name ]; then
  if [ -f $MERGE_FOLDER/$dir_name/$pkg_rename_name/Config.in ]; then
cat << 'EOF' > $MERGE_FOLDER/$dir_name/$pkg_rename_name/Config.in.temp
if BR2_BUILD_USE_CUSTOM_SCRIPTS
if BR2_BUILD_USE_ASTLINUX_SCRIPTS

EOF

cat $MERGE_FOLDER/$dir_name/$pkg_rename_name/${custom_folder_name}/Config.in >> $MERGE_FOLDER/$dir_name/$pkg_rename_name/Config.in.temp
rm -f $MERGE_FOLDER/$dir_name/$pkg_rename_name/${custom_folder_name}/Config.in

cat << 'EOF' >> $MERGE_FOLDER/$dir_name/$pkg_rename_name/Config.in.temp

endif

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS

if !BR2_BUILD_USE_CUSTOM_SCRIPTS

EOF
cat $MERGE_FOLDER/$dir_name/$pkg_rename_name/Config.in >> $MERGE_FOLDER/$dir_name/$pkg_rename_name/Config.in.temp

cat << 'EOF' >> $MERGE_FOLDER/$dir_name/$pkg_rename_name/Config.in.temp

endif #!BR2_BUILD_USE_CUSTOM_SCRIPTS
EOF
mv $MERGE_FOLDER/$dir_name/$pkg_rename_name/Config.in.temp $MERGE_FOLDER/$dir_name/$pkg_rename_name/Config.in
  else
    echo "$MERGE_FOLDER/$dir_name/$pkg_rename_name/Config.in does not exist!"
  fi

  if [ -f $MERGE_FOLDER/$dir_name/$pkg_rename_name/$pkg_rename_name.mk ]; then

cat << 'EOF' > $MERGE_FOLDER/$dir_name/$pkg_rename_name/$pkg_rename_name.mk.temp
ifeq ($(BR2_BUILD_USE_CUSTOM_SCRIPTS),y)
ifeq ($(BR2_BUILD_USE_ASTLINUX_SCRIPTS),y)

EOF

cat $MERGE_FOLDER/$dir_name/$pkg_rename_name/${custom_folder_name}/${pkg_rename_name}.mk >> $MERGE_FOLDER/$dir_name/$pkg_rename_name/$pkg_rename_name.mk.temp
rm -f $MERGE_FOLDER/$dir_name/$pkg_rename_name/${custom_folder_name}/${pkg_rename_name}.mk

cat << 'EOF' >> $MERGE_FOLDER/$dir_name/$pkg_rename_name/$pkg_rename_name.mk.temp

endif #BR2_BUILD_USE_ASTLINUX_SCRIPTS

else #BR2_BUILD_USE_CUSTOM_SCRIPTS

EOF
cat $MERGE_FOLDER/$dir_name/$pkg_rename_name/${pkg_rename_name}.mk >> $MERGE_FOLDER/$dir_name/$pkg_rename_name/$pkg_rename_name.mk.temp

cat << 'EOF' >> $MERGE_FOLDER/$dir_name/$pkg_rename_name/$pkg_rename_name.mk.temp

endif #BR2_BUILD_USE_CUSTOM_SCRIPTS
EOF
mv $MERGE_FOLDER/$dir_name/$pkg_rename_name/$pkg_rename_name.mk.temp $MERGE_FOLDER/$dir_name/$pkg_rename_name/$pkg_rename_name.mk

  else
    echo "$MERGE_FOLDER/$dir_name/$pkg_rename_name/$pkg_rename_name.mk does not exist!"
	exit 1
  fi
else
  mv $MERGE_FOLDER/$dir_name/$pkg_rename_name/${custom_folder_name}/Config.in             $MERGE_FOLDER/$dir_name/$pkg_rename_name/Config.in
  mv $MERGE_FOLDER/$dir_name/$pkg_rename_name/${custom_folder_name}/${pkg_rename_name}.mk $MERGE_FOLDER/$dir_name/$pkg_rename_name/$pkg_rename_name.mk
  touch $MERGE_FOLDER/$dir_name/$pkg_rename_name/$pkg_rename_name.hash
fi

  # create base folder before making any changes
  mkdir -p $BASE_BUILDROOT_FOLDER/$dir_name/$pkg_rename_name
  cp -a $MERGE_FOLDER/$dir_name/$pkg_rename_name/* $BASE_BUILDROOT_FOLDER/$dir_name/$pkg_rename_name/

  # rename (HOST_DIR)/usr to (HOST_DIR)
  sed -e 's@(HOST_DIR)/usr@(HOST_DIR)@g'                                          -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk

  # rename GENTARGETS to generic-package
  sed -e '/GENTARGETS,boot,.*,host)).*$/c\$(eval $(host-generic-package))'        -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk
  sed -e '/GENTARGETS,package,.*,host)).*$/c\$(eval $(host-generic-package))'     -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk

  sed -e '/GENTARGETS,boot/c\$(eval $(generic-package))'                          -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk
  sed -e '/GENTARGETS,package/c\$(eval $(generic-package))'                       -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk

  # rename AUTOTARGETS to autotools-package
  sed -e '/AUTOTARGETS,boot,.*,host)).*$/c\$(eval $(host-autotools-package))'     -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk
  sed -e '/AUTOTARGETS,package,.*,host)).*$/c\$(eval $(host-autotools-package))'  -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk

  sed -e '/AUTOTARGETS,boot/c\$(eval $(autotools-package))'                       -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk
  sed -e '/AUTOTARGETS,package/c\$(eval $(autotools-package))'                    -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk

  # rename host-pkg-config to host-pkgconf
  sed -e 's@host-pkg-config@host-pkgconf@g' \
      -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk

  # rename BR2_PREFER_STATIC_LIB to BR2_STATIC_LIBS
  sed -e 's@BR2_PREFER_STATIC_LIB@BR2_STATIC_LIBS@g' \
      -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.in $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.ext $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk

  # rename _OPT to _OPTS - there will be false positives?
  sed -e 's@_OPT @_OPTS @g' -e 's@_OPT)@_OPTS)@g' \
      -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.in $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.ext $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk

  # rename LINUX_VERSION_PROBED to LINUX_VERSION - looks like this is supported?
  #sed -e 's@LINUX_VERSION_PROBED@LINUX_VERSION@g' -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk

  # rename KERNEL_ARCH to NORMALIZED_ARCH
  sed -e 's@KERNEL_ARCH@NORMALIZED_ARCH@g' \
      -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.in $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.ext $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk

  # rename BR2_NEEDS_GETTEXT_IF_LOCALE to $(TARGET_NLS_DEPENDENCIES) 
  sed -e 's@BR2_NEEDS_GETTEXT$@BR2_NEEDS_GETTEXT_IF_LOCALE@g' \
      -e 's@BR2_NEEDS_GETTEXT @BR2_NEEDS_GETTEXT_IF_LOCALE@g' \
      -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.in $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.ext $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk

  # rename $(if $(BR2_NEEDS_GETTEXT_IF_LOCALE),gettext) to $(TARGET_NLS_DEPENDENCIES) 
  sed -e 's@$(if $(BR2_NEEDS_GETTEXT_IF_LOCALE),gettext)@$(TARGET_NLS_DEPENDENCIES)@g' \
      -e 's@$(if $(BR2_NEEDS_GETTEXT),gettext)@$(TARGET_NLS_DEPENDENCIES)@g' \
      -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.in $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.ext $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk

  # rename $(if $(BR2_NEEDS_GETTEXT_IF_LOCALE),LIBS=-lintl) to LIBS=$(TARGET_NLS_LIBS) 
  sed -e 's@$(if $(BR2_NEEDS_GETTEXT_IF_LOCALE),LIBS=-lintl)@LIBS=$(TARGET_NLS_LIBS)@g' \
      -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.in $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.ext $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk

  # rename BR2_INET_IPV6 to BR2_TOOLCHAIN
  sed -e 's@BR2_INET_IPV6@BR2_TOOLCHAIN@g' \
      -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.in $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.ext $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk

  # rename BR2_PACKAGE_PYTHON to BR2_PACKAGE_PYTHON3
  sed -e 's@BR2_PACKAGE_PYTHON$@BR2_PACKAGE_PYTHON3@g' \
      -e 's@BR2_PACKAGE_PYTHON @BR2_PACKAGE_PYTHON3 @g' \
      -e 's@BR2_PACKAGE_PYTHON)@BR2_PACKAGE_PYTHON3)@g' \
      -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.in $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.ext $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk
  
  # removal of BR2_LARGFILE
  sed -e 's@depends on !(BR2_LARGEFILE && BR2_USE_WCHAR)@depends on !BR2_USE_WCHAR@g' \
      -e 's@depends on !BR2_LARGEFILE || !BR2_USE_WCHAR@depends on !BR2_USE_WCHAR@g' \
      -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.in $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.ext $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk
}

# ---- end of process function

mkdir -p $BUILDROOT_FILES_DIR
check_and_download_file https://github.com/astlinux-project/astlinux/archive/${ASTVER//astlinux-/}.tar.gz $BUILDROOT_FILES_DIR/${ASTVER}.tar.gz
check_and_download_file https://buildroot.org/downloads/${BUILDROOTVER}.tar.gz $BUILDROOT_FILES_DIR/${BUILDROOTVER}.tar.gz

mkdir -p $BUILDROOT_FILES_EXTRACT_DIR
cd $BUILDROOT_FILES_EXTRACT_DIR

echo "Extract Dir : $BUILDROOT_FILES_EXTRACT_DIR"

if [ ! -d ${ASTVER} ]; then
  echo "extracting $BUILDROOT_FILES_DIR/${ASTVER}.tar.gz ..."
  tar -xf $BUILDROOT_FILES_DIR/${ASTVER}.tar.gz || exit 1
fi
if [ ! -d ${BUILDROOTVER} ]; then
  echo "extracting $BUILDROOT_FILES_DIR/${BUILDROOTVER}.tar.gz ..."
  tar -xf $BUILDROOT_FILES_DIR/${BUILDROOTVER}.tar.gz || exit 1
fi

#rm -rf $ASTVER
#rm -rf $BUILDROOTVER
rm -rf $MERGE_FOLDER $BASE_BUILDROOT_FOLDER

#tar -xf ${ASTVER}.tar.gz

custom_folder_name=astlinux

# use buildroot as baseline folder
cp -a $BUILDROOTVER $MERGE_FOLDER
cp -a $BUILDROOTVER $BASE_BUILDROOT_FOLDER

cp -a ${ASTVER}/project $MERGE_FOLDER/
cp -a ${ASTVER}/scripts $MERGE_FOLDER/

#process linux

process boot runnix
process boot syslinux

process package acme                
process package acpid               
process package arnofw              
process package arp-scan            
process package asterisk            
process package asterisk-codec-silk 
process package asterisk-fop2       
process package autoconf            
process package automake            
process package avahi               
process package bash                
process package bc                  
process package bfdetect            
process package bison               
process package bridge-utils        
process package busybox             
process package ca-certificates     
process package chrony              
process package clix                
process package dahdi-linux         
process package dahdi-tools         
process package darkstat            
process package ddclient            
process package dhcpdump            
process package dialog              
process package dnscrypt-proxy      
process package dnsmasq             
process package dosfstools          
process package dropbear            
process package e2fsprogs           
process package empty               
process package ethtool             
process package ex-vi               
process package expat               
process package fakeroot            
process package fdisk               
process package flex                
process package fossil              
process package fping               
process package fxload              
process package genext2fs           
process package gntp-send           
process package gnu-efi             
process package gperf               
process package htop                
process package htpasswd            
process package iftop               
process package iksemel             
process package iperf               
process package iperf3              
process package iprange             
process package iproute2            
process package ipset               
process package iptables            
process package jansson             
process package jitterentropy-rngd  
process package jpeg                libjpeg
process package keepalived          
process package kexec               
process package kmod                
process package libcap              
process package libcurl             
process package libdaemon           
process package libdnet             
process package libedit             
process package libffi              
process package libfuse             
process package libglib2            
process package libical             
process package libidn              
process package libmnl              
process package libpcap             
process package libpng              
process package libpri              
process package libqrencode         
process package libretls            
process package libsodium           
process package libsrtp             
process package libtool             
process package liburiparser        
process package libusb              
process package libusb-compat       
process package libxml2             
process package lighttpd            
process package linux-firmware      
process package lm-sensors          
process package logrotate           
process package lua                 
process package luabitop            
process package luaexpat            
process package luafilesystem       
process package luasec              
process package luasocket           
process package lxc                 
process package lzo                 
process package m4                  
process package mac2vendor          
process package miniupnpd           
process package monit               
process package msmtp               
process package mtr                 
process package multimedia/beep     
process package multimedia/libmad   
process package multimedia/sox      
process package nano                
process package nasm                
process package ncurses             
process package ne                  
process package neon                
process package netcalc             
process package netsnmp             
process package newt                
process package ngrep               
process package nut                 
process package openldap            
process package openssh             
process package openssl             libopenssl
process package openvmtools         
process package openvpn             
process package p910nd              
process package pciutils            
process package pcre                
process package pcre2               
process package perl                
process package phoneprov-tools     
process package php                 
process package pjsip               
process package pjsip-ast20         
#process package pkg-config         - replaced by pkgconf
process package popt                
process package pppd                
process package prosody             
process package qemu-guest-agent    
process package r8125               
process package rsync               
process package s3fs                
process package screen              
process package shellinabox         
process package sipgrep             
process package sipsak              
process package slang               
process package smartmontools       
process package sngrep              
process package spandsp             
process package sqlite              
process package sqliteodbc          
process package squashfs            
process package statserial          
process package strace              
process package strongswan          
process package stunnel             
process package sudo                
process package system-vendor       
process package tarsnap             
process package tcpdump             
process package tiff                
process package tinyproxy           
process package udev                eudev
process package unbound             
process package unionfs             
process package unixodbc            
process package usbutils            
process package util-linux          
process package vnstat              
process package vsftpd              
process package webinterface        
process package whois               
process package wide-dhcpv6         
process package wireguard-tools     
process package xorriso             
process package zabbix              
process package zlib                libzlib
process package zoneinfo            

mkdir -p $MERGE_FOLDER/docs
cp -a $ASTVER/docs/ChangeLog.txt $MERGE_FOLDER/docs/

mkdir -p $MERGE_FOLDER/project/configs-astlinux
cp -a $ASTVER/runnix* $MERGE_FOLDER/
cp -a $ASTVER/x86_64-configs $MERGE_FOLDER/
cp -a $ASTVER/runnix* $MERGE_FOLDER/project/configs-astlinux/
cp -a $ASTVER/x86_64-configs $MERGE_FOLDER/project/configs-astlinux/


# disable all packages where they are part of toolchain build
# autoconf, automake, binutils, bison, gawk, gcc, glibc, gmp, isl, libtool, linux, m4, mpc, mpfr, patchef
sed -e 's@BR2_BUILD_USE_CUSTOM_SCRIPTS@BR2_BUILD_USE_CUSTOM_SCRIPTS1@g' -i $MERGE_FOLDER/package/autoconf/autoconf.mk
sed -e 's@BR2_BUILD_USE_CUSTOM_SCRIPTS@BR2_BUILD_USE_CUSTOM_SCRIPTS1@g' -i $MERGE_FOLDER/package/automake/automake.mk
sed -e 's@BR2_BUILD_USE_CUSTOM_SCRIPTS@BR2_BUILD_USE_CUSTOM_SCRIPTS1@g' -i $MERGE_FOLDER/package/bison/bison.mk
#sed -e 's@BR2_BUILD_USE_CUSTOM_SCRIPTS@BR2_BUILD_USE_CUSTOM_SCRIPTS1@g' -i $MERGE_FOLDER/package/gawk/gawk.mk
#sed -e 's@BR2_BUILD_USE_CUSTOM_SCRIPTS@BR2_BUILD_USE_CUSTOM_SCRIPTS1@g' -i $MERGE_FOLDER/package/gmp/gmp.mk
#sed -e 's@BR2_BUILD_USE_CUSTOM_SCRIPTS@BR2_BUILD_USE_CUSTOM_SCRIPTS1@g' -i $MERGE_FOLDER/package/isl/isl.mk
sed -e 's@BR2_BUILD_USE_CUSTOM_SCRIPTS@BR2_BUILD_USE_CUSTOM_SCRIPTS1@g' -i $MERGE_FOLDER/package/libtool/libtool.mk
sed -e 's@BR2_BUILD_USE_CUSTOM_SCRIPTS@BR2_BUILD_USE_CUSTOM_SCRIPTS1@g' -i $MERGE_FOLDER/package/m4/m4.mk
#sed -e 's@BR2_BUILD_USE_CUSTOM_SCRIPTS@BR2_BUILD_USE_CUSTOM_SCRIPTS1@g' -i $MERGE_FOLDER/package/mpc/mpc.mk
#sed -e 's@BR2_BUILD_USE_CUSTOM_SCRIPTS@BR2_BUILD_USE_CUSTOM_SCRIPTS1@g' -i $MERGE_FOLDER/package/mpfr/mpfr.mk
#sed -e 's@BR2_BUILD_USE_CUSTOM_SCRIPTS@BR2_BUILD_USE_CUSTOM_SCRIPTS1@g' -i $MERGE_FOLDER/package/patchelf/patchelf.mk

# libopenssl - disable entire libopenssl package
#sed -e '4,13s/^/#/' -e 's@if BR2_PACKAGE_OPENSSL$@if BR2_PACKAGE_LIBOPENSSL@g' -i $MERGE_FOLDER/package/libopenssl/Config.in
sed -e '1,45s/^/#/' -e '280s/^/#/' -i $MERGE_FOLDER/package/libopenssl/Config.in
#sed -e 's@BR2_BUILD_USE_CUSTOM_SCRIPTS@BR2_BUILD_USE_CUSTOM_SCRIPTS1@g' -i $MERGE_FOLDER/package/libopenssl/libopenssl.mk


# BR2_LARGEFILE removed
sed -e 's@depends on BR2_LARGEFILE@#depends on BR2_LARGEFILE@g' \
    -e 's@comment "dosfstools requires a toolchain with LARGEFILE and WCHAR support"@comment "dosfstools requires a toolchain with WCHAR support"@g' \
    -i $MERGE_FOLDER/package/dosfstools/Config.in
sed -e 's@depends on BR2_LARGEFILE@#depends on BR2_LARGEFILE@g' -i $MERGE_FOLDER/package/e2fsprogs/Config.in
sed -e 's@depends on BR2_LARGEFILE@#depends on BR2_LARGEFILE@g' \
    -e 's@comment "ipset requires a toolchain with LARGEFILE support"@#comment "ipset requires a toolchain with LARGEFILE support"@g' \
    -e 's@depends on !BR2_LARGEFILE@#depends on !BR2_LARGEFILE@g' -i $MERGE_FOLDER/package/ipset/Config.in
sed -e 's@depends on BR2_LARGEFILE@#depends on BR2_LARGEFILE@g' \
    -e 's@comment "libmnl requires a toolchain with LARGEFILE support"@#comment "libmnl requires a toolchain with LARGEFILE support"@g' \
    -e 's@depends on !BR2_LARGEFILE@#depends on !BR2_LARGEFILE@g' -i $MERGE_FOLDER/package/libmnl/Config.in
sed -e 's@depends on BR2_LARGEFILE@#depends on BR2_LARGEFILE@g' \
    -e 's@comment "squashfs requires a toolchain with LARGEFILE support"@#comment "squashfs requires a toolchain with LARGEFILE support"@g' \
    -e 's@depends on !BR2_LARGEFILE@#depends on !BR2_LARGEFILE@g' -i $MERGE_FOLDER/package/squashfs/Config.in
sed -e 's@depends on BR2_LARGEFILE@#depends on BR2_LARGEFILE@g' -i $MERGE_FOLDER/package/util-linux/Config.in

# fix trailing slashes error
sed -e 's@http://www.mavetju.org/download/@http://www.mavetju.org/download@g' -i $MERGE_FOLDER/package/dhcpdump/dhcpdump.mk
sed -e 's@http://anduin.linuxfromscratch.org/sources/BLFS/svn/p/@http://anduin.linuxfromscratch.org/sources/BLFS/svn/p@g' -i $MERGE_FOLDER/package/popt/popt.mk
sed -e 's@http://www.uclibc.org/@http://www.uclibc.org@g' -i $MERGE_FOLDER/package/slang/slang.mk
sed -e 's@http://www.ibiblio.org/pub/Linux/system/serial/@http://www.ibiblio.org/pub/Linux/system/serial@g' -i $MERGE_FOLDER/package/statserial/statserial.mk

# BR2_PACKAGE_CURL -> BR2_PACKAGE_LIBCURL
sed -e 's@BR2_PACKAGE_CURL@BR2_PACKAGE_LIBCURL_CURL@g' -i $MERGE_FOLDER/package/ddclient/Config.in
sed -e 's@BR2_PACKAGE_CURL@BR2_PACKAGE_LIBCURL_CURL@g' -i $MERGE_FOLDER/package/libcurl/Config.in $MERGE_FOLDER/package/libcurl/libcurl.mk
sed -e 's@BR2_PACKAGE_CURL@BR2_PACKAGE_LIBCURL@g' -i $MERGE_FOLDER/package/zabbix/zabbix.mk

# GETTEXT changes
sed -e 's@select BR2_PACKAGE_GETTEXT if BR2_NEEDS_GETTEXT_IF_LOCALE@#select BR2_PACKAGE_GETTEXT if BR2_NEEDS_GETTEXT_IF_LOCALE@g' -i $MERGE_FOLDER/package/libidn/Config.in
sed -e 's@select BR2_PACKAGE_GETTEXT if BR2_NEEDS_GETTEXT_IF_LOCALE@#select BR2_PACKAGE_GETTEXT if BR2_NEEDS_GETTEXT_IF_LOCALE@g' \
    -e 's@select BR2_PACKAGE_LIBINTL if BR2_NEEDS_GETTEXT_IF_LOCALE@#select BR2_PACKAGE_LIBINTL if BR2_NEEDS_GETTEXT_IF_LOCALE@g' -i $MERGE_FOLDER/package/libglib2/Config.in
sed -e 's@$(if $(BR2_NEEDS_GETTEXT),gettext libintl)@$(TARGET_NLS_DEPENDENCIES)@g' -i $MERGE_FOLDER/package/libglib2/libglib2.mk

# hash file updates
echo ""                                                                                                          >> $MERGE_FOLDER/linux/linux.hash
echo "sha256  801ba01e82a8e25738d4f30d2640e537cc06bb13f9dbf0f6fce5095f3fb1f168  linux-cip-6.12.114-cip34.tar.xz" >> $MERGE_FOLDER/linux/linux.hash

echo ""                                                                                                                                                            >> $MERGE_FOLDER/package/gcc/gcc.hash
echo "# From https://gcc.gnu.org/pub/gcc/releases/gcc-13.5.0/sha512.sum"                                                                                           >> $MERGE_FOLDER/package/gcc/gcc.hash
echo "sha512  709237ff8f10d46eb10cad53a71bdcacbd3d56f4559e9a5bb3323f743fdba78b7e505586135560b27e88320927a065ec4f5e45273d5504b542f67c7326eb683c  gcc-13.5.0.tar.xz" >> $MERGE_FOLDER/package/gcc/gcc.hash

echo "sha256  6188d0f0c180db7a30467b5b6065a3cb5d2665b937d2e8c40366efb52bf689fe  beep-1.4.12.tar.gz"            >> $MERGE_FOLDER/package/beep/beep.hash
echo "sha256  6a3b917a8b7ec1229e62f681ad64699d1b7df298ba2875f24442e103b45c45b3  bfdetect_src.tar.gz"           >> $MERGE_FOLDER/package/bfdetect/bfdetect.hash
echo "sha256  81fcba02196e6a43ed6099e4a182a8b35ca60a0ac2ce1e9977cb3cf22f388e9d  clix-2013-03-30.tar.gz"        >> $MERGE_FOLDER/package/clix/clix.hash
echo "sha256  5c8e66d4c478b6d7e58f4c842823a09125509bf6851017ff70e32b32ce95b01b  darkstat-3.0.722.tar.gz"       >> $MERGE_FOLDER/package/darkstat/darkstat.hash
echo "sha256  16e80157ee62d0e257eca7b765e079946e8386205a4c360e87f5c23bb8626d99  ddclient-curl-3.8.3-08.tar.gz" >> $MERGE_FOLDER/package/ddclient/ddclient.hash
echo "sha256  da4be7cf67e94572463b19e56850aa36dc4e39eb0d933d3688fe8574bb632409  ex-050325.tar.bz2"             >> $MERGE_FOLDER/package/ex-vi/ex-vi.hash
echo "sha256  b90c40beb75308b0eba46b5add6e54a7a9e65ac90ce86ec8d78ae2a4bb8bae60  fossil-src-2.22.tar.gz"        >> $MERGE_FOLDER/package/fossil/fossil.hash
echo "sha256  e3dd69c635e16a7d723dc5ae1c4c6ff4a216204fd8fc0f130eafc1022d303837  gntp-send-0.3.4.tar.gz"        >> $MERGE_FOLDER/package/gntp-send/gntp-send.hash
echo "sha256  458c1b8fb3349076a6cecf26c29db1d561315d84e16bfcfba419f327f502e244  iksemel-1.4.tar.gz"            >> $MERGE_FOLDER/package/iksemel/iksemel.hash
echo "sha256  85ba349ec5081c1fbbf3dae197fd162e70d18baa38b4e38a30e05b82b8a395ee  iprange-2.1.1.tar.gz"          >> $MERGE_FOLDER/package/iprange/iprange.hash
echo "sha256  8956a72fa609057e9cb1df90c30505eebf30f37df386211779bfed5b3207a95a  oui-2026-09-16.txt"            >> $MERGE_FOLDER/package/mac2vendor/mac2vendor.hash
echo "sha256  eb1cad5c63d6ead915c617b3da32ef97dc1e4272e73dd13af07bc75566ebf30c  2.2.4.tar.gz"                  >> $MERGE_FOLDER/package/sipgrep/sipgrep.hash

# below is bug fixes at package level
# --- boot folder
# runnix - do not enable by default
sed -e 's@default y@#default y@g' -i $MERGE_FOLDER/boot/runnix/Config.in

# --- package folder
# iptables - change IPTABLES_TARGET_INSTALL to IPTABLES_TARGET_INSTALL_INIT as it is giving issue in buildroot.
sed -e 's@IPTABLES_TARGET_INSTALL@IPTABLES_TARGET_INSTALL_INIT@g' -i $MERGE_FOLDER/package/iptables/iptables.mk

# libusb
sed -e 's@BR2_ROOTFS_DEVICE_CREATION_DYNAMIC_UDEV@BR2_PACKAGE_HAS_UDEV@g' -i $MERGE_FOLDER/package/libusb/libusb.mk

# lua
sed -e '6i\	select BR2_PACKAGE_HAS_LUAINTERPRETER' -i $MERGE_FOLDER/package/lua/Config.in

# luasec
sed -e 's@depends on BR2_PACKAGE_OPENSSL@select BR2_PACKAGE_OPENSSL@g' -i $MERGE_FOLDER/package/luasec/Config.in

# mac2vendor - change DL_DIR to MAC2VENDOR_DL_DIR
sed -e 's@(DL_DIR)@(MAC2VENDOR_DL_DIR)@g' -i $MERGE_FOLDER/package/mac2vendor/mac2vendor.mk

# neon
sed -e 's@depends on BR2_PACKAGE_NEON@#depends on BR2_PACKAGE_NEON@g' \
	-e '11i\if BR2_PACKAGE_NEON\n' \
	-e '53i\endif\n' \
	-i $MERGE_FOLDER/package/neon/Config.in
sed -e '27,34s/^/#/' -e '53s/^/#/' -i $MERGE_FOLDER/package/neon/Config.in

# prosody - circular dependency issue
sed -e 's@select BR2_PACKAGE_LUA$@#select BR2_PACKAGE_LUA@g' -i $MERGE_FOLDER/package/prosody/Config.in

# php
sed -e '24,28s/^/#/' -e '62s/^/#/' -i $MERGE_FOLDER/package/php/Config.in









