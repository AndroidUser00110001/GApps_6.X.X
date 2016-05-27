#!/sbin/sh

# This file contains parts from the scripts taken from the Open GApps Project by mfonville.
#
# The Open GApps scripts are free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# These scripts are distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# Functions & variables
tmp_path=/tmp

file_getprop() { grep "^$2" "$1" | cut -d= -f2; }

rom_build_prop=/system/build.prop

arch=$(file_getprop $rom_build_prop "ro.product.cpu.abi=")

# Libs
if (echo "$arch" | grep -qi "armeabi"); then
  cp -rf $tmp_path/libs/lib/* /system/lib
  mkdir -p /system/vendor/lib
  cp -rf $tmp_path/libs/vendor/lib/* /system/vendor/lib
elif (echo "$arch" | grep -qi "arm64"); then
  cp -rf $tmp_path/libs/lib64/* /system/lib64
  mkdir -p /system/vendor/lib
  mkdir -p /system/vendor/lib64
  cp -rf $tmp_path/libs/vendor/lib/* /system/vendor/lib
  cp -rf $tmp_path/libs/vendor/lib64/* /system/vendor/lib64
fi

# Make required symbolic links
if (echo "$arch" | grep -qi "armeabi"); then
  mkdir -p /system/app/FaceLock/lib/arm
  mkdir -p /system/app/LatinIME/lib/arm
  ln -sfn /system/lib/libfacelock_jni.so /system/app/FaceLock/lib/arm/libfacelock_jni.so
  ln -sfn /system/lib/libjni_delight4decoder.so /system/app/LatinIME/lib/arm/libjni_delight4decoder.so
elif (echo "$arch" | grep -qi "arm64"); then
  mkdir -p /system/app/FaceLock/lib/arm64
  mkdir -p /system/app/LatinIME/lib/arm64
  ln -sfn /system/lib64/libfacelock_jni.so /system/app/FaceLock/lib/arm64/libfacelock_jni.so
  ln -sfn /system/lib64/libjni_delight4decoder.so /system/app/LatinIME/lib/arm64/libjni_delight4decoder.so
fi

# Cleanup
rm -rf /tmp/libs
