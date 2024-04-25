#!/usr/bin/bash

SQUASH_WORK_DIR="`pwd`/SquashTM_work"
SQUASH_DIR="$SQUASH_WORK_DIR/squash-tm"
SQUASH_DOWNLOAD_URL="https://nexus.squashtest.org/nexus/repository/public-releases/tm/core/squash-tm-distribution/6.0.1.RELEASE/"
SQUASH_DOWNLOAD_FILE="squash-tm-6.0.1.RELEASE.tar.gz"


echo "------------------------------------------------------------------------"
echo "Preparing work dir in [$SQUASH_WORK_DIR]"
if [ -d "$SQUASH_WORK_DIR" ]; then rm -Rf $SQUASH_WORK_DIR; fi
mkdir $SQUASH_WORK_DIR
cd $SQUASH_WORK_DIR


echo "------------------------------------------------------------------------"
echo "Download release [$SQUASH_DOWNLOAD_URL$SQUASH_DOWNLOAD_FILE]"
wget "$SQUASH_DOWNLOAD_URL$SQUASH_DOWNLOAD_FILE"


echo "------------------------------------------------------------------------"
echo "Unpack download ... and delete download"
tar -xvzf $SQUASH_DOWNLOAD_FILE
rm $SQUASH_DOWNLOAD_FILE
cd $SQUASH_DIR


echo "------------------------------------------------------------------------"
echo "Remove windows specific files (exe, bat, maria db)"
find . -name "*.exe" -exec rm {} \;
find . -name "*.bat" -exec rm {} \;
find database-scripts -name "mariadb*" -exec rm {} \;


echo "------------------------------------------------------------------------"
echo "TODO - Patch config files"


echo "------------------------------------------------------------------------"
echo "TODO - Cleanup work dir in [$SQUASH_WORK_DIR]"


