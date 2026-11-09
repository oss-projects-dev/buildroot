# notes AstLinux pulled on 2026-11-07
ASTVER=astlinux-338e17c4efd61b63fbecb66d3132a32e68440d83
BUILDROOTVER=buildroot-2025.02.19

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

echo "copying $ASTVER/$dir_name/$pkg_src_dir to $MERGE_FOLDER/$dir_name/$pkg_rename_name"
cp -a $ASTVER/$dir_name/$pkg_src_dir/* $MERGE_FOLDER/$dir_name/$pkg_rename_name/

( 
  cd $MERGE_FOLDER/$dir_name/$pkg_rename_name;
  if [[ "$pkg_name" != "$pkg_rename_name" ]]; then
    mv ${pkg_name}.mk ${pkg_rename_name}.mk
	sed -e "s@${pkg_name_upper}_@${pkg_rename_name_upper}_@g" -i Config.in*
	sed -e "s@${pkg_name_upper}_@${pkg_rename_name_upper}_@g" -i ${pkg_rename_name}.mk
  fi
  
  mkdir $custom_folder_name
  #if compgen -G "*.patch" > /dev/null; then
  #  mv *.patch custom/
  #fi  
  mv * $custom_folder_name/

  # below changes have to be done for all files before merging with buildroot files so both are separate
  # add custom-patch-dir
  sed -e "/_SITE /a ${pkg_rename_name_upper}_CUSTOM_PATCH_DIR = $custom_folder_name" -i $custom_folder_name/*.mk
  # change default package path for files to custom_folder_name  
  sed -e "s@$dir_name/$pkg_rename_name@$dir_name/$pkg_rename_name/$custom_folder_name@g" -i $custom_folder_name/*.mk
)

if [ -d $BUILDROOTVER/$dir_name/$pkg_rename_name ]; then
  cp -a $BUILDROOTVER/$dir_name/$pkg_rename_name/* $MERGE_FOLDER/$dir_name/$pkg_rename_name/

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
  sed -e 's@(HOST_DIR)/usr@(HOST_DIR)@g' -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk

  # rename GENTARGETS to generic-package
  sed -e '/GENTARGETS,boot,.*,host)).*$/c\$(eval $(host-generic-package))'     -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk
  sed -e '/GENTARGETS,package,.*,host)).*$/c\$(eval $(host-generic-package))'  -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk

  sed -e '/GENTARGETS,boot/c\$(eval $(generic-package))'     -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk
  sed -e '/GENTARGETS,package/c\$(eval $(generic-package))'  -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk

  # rename AUTOTARGETS to autotools-package
  sed -e '/AUTOTARGETS,boot,.*,host)).*$/c\$(eval $(host-autotools-package))'     -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk
  sed -e '/AUTOTARGETS,package,.*,host)).*$/c\$(eval $(host-autotools-package))'  -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk

  sed -e '/AUTOTARGETS,boot/c\$(eval $(autotools-package))'     -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk
  sed -e '/AUTOTARGETS,package/c\$(eval $(autotools-package))'  -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk

  # rename host-pkg-config to host-pkgconf
  sed -e 's@host-pkg-config@host-pkgconf@g' -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk

  # rename BR2_PREFER_STATIC_LIB to BR2_STATIC_LIBS
  sed -e 's@BR2_PREFER_STATIC_LIB@BR2_STATIC_LIBS@g' -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.in
  sed -e 's@BR2_PREFER_STATIC_LIB@BR2_STATIC_LIBS@g' -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk

  # rename _OPT to _OPTS - there will be false positives?
  sed -e 's@_OPT @_OPTS @g' -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk

  # rename $(if $(BR2_NEEDS_GETTEXT_IF_LOCALE),gettext) to $(TARGET_NLS_DEPENDENCIES) 
  sed -e 's@$(if $(BR2_NEEDS_GETTEXT_IF_LOCALE),gettext)@$(TARGET_NLS_DEPENDENCIES)@g' -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk

  # rename $(if $(BR2_NEEDS_GETTEXT_IF_LOCALE),LIBS=-lintl) to LIBS=$(TARGET_NLS_LIBS) 
  sed -e 's@$(if $(BR2_NEEDS_GETTEXT_IF_LOCALE),LIBS=-lintl)@LIBS=$(TARGET_NLS_LIBS)@g' -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk

  # rename BR2_NEEDS_GETTEXT_IF_LOCALE to $(TARGET_NLS_DEPENDENCIES) 
  sed -e 's@BR2_NEEDS_GETTEXT@BR2_NEEDS_GETTEXT_IF_LOCALE@g' -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.mk

  # removal of BR2_LARGFILE
  sed -e 's@depends on !(BR2_LARGEFILE && BR2_USE_WCHAR)@depends on !BR2_USE_WCHAR@g' \
	  -e 's@depends on !BR2_LARGEFILE || !BR2_USE_WCHAR@depends on !BR2_USE_WCHAR@g' \
	  -e '/BR2_LARGEFILE/d' \
	  -i $MERGE_FOLDER/$dir_name/$pkg_rename_name/*.in
}

# ---- end of process function

check_and_download_file https://github.com/astlinux-project/astlinux/archive/${ASTVER//astlinux-/}.tar.gz ${ASTVER}.tar.gz

check_and_download_file https://buildroot.org/downloads/${BUILDROOTVER}.tar.gz ${BUILDROOTVER}.tar.gz

if [ ! -d ${ASTVER} ]; then
  echo "extracting ${ASTVER}.tar.gz ..."
  tar -xf ${ASTVER}.tar.gz || exit 1
fi
if [ ! -d ${BUILDROOTVER} ]; then
  echo "extracting ${BUILDROOTVER}.tar.gz ..."
  tar -xf ${BUILDROOTVER}.tar.gz || exit 1
fi

MERGE_FOLDER=m-buildroot-merge-${ASTVER//astlinux-/}-${BUILDROOTVER//buildroot-/}
BASE_BUILDROOT_FOLDER=m-buildroot-orig-${ASTVER//astlinux-/}-${BUILDROOTVER//buildroot-/}

#rm -rf $ASTVER
#rm -rf $BUILDROOTVER
rm -rf $MERGE_FOLDER $BASE_BUILDROOT_FOLDER

#tar -xf ${ASTVER}.tar.gz

custom_folder_name=astlinux

mkdir -p $MERGE_FOLDER

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
process package libedit             
process package libfuse             
process package libical             
process package libidn              
process package libmnl              
process package libpcap             
process package libpng              
process package libqrencode         
process package libretls            
process package libsodium           
process package libsrtp             
process package libtool             
process package liburiparser        
process package libusb              
process package libusb-compat       
#process package libxcrypt           
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
process package ngrep               
process package nut                 
process package openldap            
process package openssh             
process package openssl             libopenssl
process package openvpn             
process package p910nd              
process package pciutils            
process package pcre                
process package pcre2               
process package perl                
process package phoneprov-tools     
process package php                 
#process package pkg-config          - replaced by pkgconf
process package popt                
process package pppd                
process package prosody             
process package r8125               
process package rsync               
process package s3fs                
process package screen              
process package shellinabox         
process package sipgrep             
process package sipsak              
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
process package whois               
process package wide-dhcpv6         
process package wireguard-tools     
process package zabbix              
process package zlib                libzlib
process package zoneinfo            


# disable packages

# bug fixes
# lua
sed -e '6i\	select BR2_PACKAGE_HAS_LUAINTERPRETER' -i $MERGE_FOLDER/package/lua/Config.in
# luasec
sed -e 's@depends on BR2_PACKAGE_OPENSSL@select BR2_PACKAGE_OPENSSL@g' -i $MERGE_FOLDER/package/luasec/Config.in

# neon
sed -e 's@depends on BR2_PACKAGE_NEON@#depends on BR2_PACKAGE_NEON@g' \
	-e '11i\if BR2_PACKAGE_NEON\n' \
	-e '53i\endif\n' \
	-i $MERGE_FOLDER/package/neon/Config.in
sed -e '27,34s/^/#/' -e '53s/^/#/' -i $MERGE_FOLDER/package/neon/Config.in

# prosody
sed -e 's@select BR2_PACKAGE_LUA$@#select BR2_PACKAGE_LUA@g' -i $MERGE_FOLDER/package/prosody/Config.in

# php
sed -e '24,28s/^/#/' -e '62s/^/#/' -i $MERGE_FOLDER/package/php/Config.in

# curl
sed -e 's@BR2_PACKAGE_CURL@BR2_PACKAGE_LIBCURL_CURL@g' -i $MERGE_FOLDER/package/ddclient/Config.in
sed -e 's@BR2_PACKAGE_CURL@BR2_PACKAGE_LIBCURL_CURL@g' -i $MERGE_FOLDER/package/libcurl/Config.in

# fix trailing slashes errors
sed -e 's@http://www.mavetju.org/download/@http://www.mavetju.org/download@g' -i $MERGE_FOLDER/package/dhcpdump/dhcpdump.mk
sed -e 's@http://anduin.linuxfromscratch.org/sources/BLFS/svn/p/@http://anduin.linuxfromscratch.org/sources/BLFS/svn/p@g' -i $MERGE_FOLDER/package/popt/popt.mk
sed -e 's@http://www.ibiblio.org/pub/Linux/system/serial/@http://www.ibiblio.org/pub/Linux/system/serial@g' -i $MERGE_FOLDER/package/statserial/statserial.mk


# below are disabled packages
# libopenssl - disable entire libopenssl package
#sed -e '4,13s/^/#/' -e 's@if BR2_PACKAGE_OPENSSL$@if BR2_PACKAGE_LIBOPENSSL@g' -i $MERGE_FOLDER/package/libopenssl/Config.in
sed -e '1,45s/^/#/' -e '280s/^/#/' -i $MERGE_FOLDER/package/libopenssl/Config.in
sed -e 's@BR2_BUILD_USE_CUSTOM_SCRIPTS@BR2_BUILD_USE_CUSTOM_SCRIPTS1@g' -i $MERGE_FOLDER/package/libopenssl/libopenssl.mk

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

# m4 - disable entire libopenssl package
#sed -e '1,45s/^/#/' -e '280s/^/#/' -i $MERGE_FOLDER/package/libopenssl/Config.in
#sed -e 's@BR2_BUILD_USE_CUSTOM_SCRIPTS@BR2_BUILD_USE_CUSTOM_SCRIPTS1@g' -i $MERGE_FOLDER/package/libopenssl/libopenssl.mk
