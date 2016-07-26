#!/bin/bash

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

# Pretty ascii art
echo "AndroidUser00110001 GApps";

# Define paths && variables
APPDIRS="dialer/priv-app/Dialer
         facelock/arm/app/FaceLock
         googletts/arm/app/GoogleTTS
         googletts/x86/app/GoogleTTS
         googlehome/app/GoogleHome
         latinimegoogle/arm/app/LatinImeGoogle
         latinimegoogle/arm64/app/LatinImeGoogle
         prebuiltbugle/arm/app/PrebuiltBugle
         prebuiltbugle/arm64/app/PrebuiltBugle
         prebuiltgmscore/arm/priv-app/PrebuiltGmsCore
         prebuiltgmscore/arm64/priv-app/PrebuiltGmsCore
         prebuiltgmscore/x86/priv-app/PrebuiltGmsCore
         setupwizard/phone/priv-app/SetupWizard
         setupwizard/tablet/priv-app/SetupWizard
         velvet/arm/priv-app/Velvet
         velvet/arm64/priv-app/Velvet
         velvet/tv-arm/priv-app/Velvet
         velvet/tv-x86/priv-app/Velvet
         velvet/x86/priv-app/Velvet
         system/app/ChromeBookmarksSyncAdapter
         system/app/GoogleCalendarSyncAdapter
         system/app/GoogleContactsSyncAdapter
         system/app/PrebuiltExchange3Google
         system/priv-app/ConfigUpdater
         system/priv-app/GoogleBackupTransport
         system/priv-app/GoogleFeedback
         system/priv-app/GoogleLoginService
         system/priv-app/GoogleOneTimeInitializer
         system/priv-app/GooglePartnerSetup
         system/priv-app/GoogleServicesFramework
         system/priv-app/HotwordEnrollment
         system/priv-app/Phonesky"
TARGETDIR=$(realpath .)
GAPPSDIR="$TARGETDIR"/files
TOOLSDIR="$TARGETDIR"/tools
STAGINGDIR="$TARGETDIR"/staging
FINALDIR="$TARGETDIR"/out
ZIPNAME1TITLE=AndroidUser00110001_GApps
ZIPNAME1VERSION=6.x.x
ZIPNAME1DATE=$(date +%-m-%-e-%-y)_$(date +%H:%M)
#ZIPNAME2TITLE=AndroidUser00110001_GApps
#ZIPNAME2VERSION=6.X.X
ZIPNAME1="$ZIPNAME1TITLE"_"$ZIPNAME1VERSION"_"$ZIPNAME1DATE".zip
#ZIPNAME2="$ZIPNAME2TITLE"_"$ZIPNAME2VERSION".zip
JAVAHEAP=3072m
SIGNAPK="$TOOLSDIR"/signapk.jar
MINSIGNAPK="$TOOLSDIR"/minsignapk.jar
TESTKEYPEM="$TOOLSDIR"/testkey.x509.pem 
TESTKEYPK8="$TOOLSDIR"/testkey.pk8

dcapk() {
  TARGETDIR=$(realpath .)
  TARGETAPK="$TARGETDIR"/$(basename "$TARGETDIR").apk
  unzip -q -o "$TARGETAPK" -d "$TARGETDIR" "lib/*"
  zip -q -d "$TARGETAPK" "lib/*"
  cd "$TARGETDIR"
  zip -q -r -D -Z store -b "$TARGETDIR" "$TARGETAPK" "lib/"
  rm -rf "${TARGETDIR:?}"/lib/
  mv -f "$TARGETAPK" "$TARGETAPK".orig
  zipalign -f -p 4 "$TARGETAPK".orig "$TARGETAPK"
  rm -f "$TARGETAPK".orig
}

# Define beginning time
BEGIN=$(date +%s)

# Begin the magic
export PATH="$TOOLSDIR":$PATH
cp -rf "$GAPPSDIR"/* "$STAGINGDIR"

for dirs in $APPDIRS; do
  cd "$STAGINGDIR/${dirs}";
  dcapk 1> /dev/null 2>&1;
done

7za a -tzip -x!placeholder -r "$STAGINGDIR"/"$ZIPNAME1" "$STAGINGDIR"/./* 1> /dev/null 2>&1
java -Xmx"$JAVAHEAP" -jar "$SIGNAPK" -w "$TESTKEYPEM" "$TESTKEYPK8" "$STAGINGDIR"/"$ZIPNAME1" "$STAGINGDIR"/"$ZIPNAME1".signed
rm -f "$STAGINGDIR"/"$ZIPNAME1"
zipadjust "$STAGINGDIR"/"$ZIPNAME1".signed "$STAGINGDIR"/"$ZIPNAME1".fixed 1> /dev/null 2>&1
rm -f "$STAGINGDIR"/"$ZIPNAME1".signed
java -Xmx"$JAVAHEAP" -jar "$MINSIGNAPK" "$TESTKEYPEM" "$TESTKEYPK8" "$STAGINGDIR"/"$ZIPNAME1".fixed "$STAGINGDIR"/"$ZIPNAME1"
rm -f "$STAGINGDIR"/"$ZIPNAME1".fixed
mv -f "$STAGINGDIR"/"$ZIPNAME1" "$FINALDIR"
#cp -f "$FINALDIR"/"$ZIPNAME1" "$FINALDIR"/"$ZIPNAME2"
find "$STAGINGDIR"/* ! -name "placeholder" -exec rm -rf {} +

# Define ending time
END=$(date +%s)

# All done
echo " "
echo "All done creating GApps!"
echo "Total time elapsed: $(echo $(($END-$BEGIN)) | awk '{print int($1/60)"mins "int($1%60)"secs "}') ($(echo "$END - $BEGIN" | bc) seconds)"
echo "Completed GApp zips are located in the "$FINALDIR" directory"
cd
