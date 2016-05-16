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

build_char=$(file_getprop $rom_build_prop "ro.build.characteristics")

prod_dev=$(file_getprop $rom_build_prop "ro.product.device")

# SetupWizard
if (echo "$build_char" | grep -qi "tablet"); then
  cp -rf $tmp_path/setupwizard/tablet/* /system
else
  cp -rf $tmp_path/setupwizard/phone/* /system
fi

# Fugu doesn't want SetupWizard
if (echo "$prod_dev" | grep -qi "fugu"); then
  rm -rf /system/priv-app/SetupWizard
fi

# Cleanup
rm -rf /tmp/setupwizard
