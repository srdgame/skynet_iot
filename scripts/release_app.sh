# !/usr/bin/env bash

set -e

if [ $# -lt 1 ] ; then
	echo "Usage: release_app.sh <feed dir> <app name>"
	exit 0
fi

# echo "Release App:" $1

BASE_DIR=`pwd`
FEEDS_DIR=$1
RELEASE_DIR=$BASE_DIR'/__release/'$1'/'$2

mkdir -p $RELEASE_DIR
# echo 'Base Dir:'$BASE_DIR
# echo 'Release Dir:'$BASE_DIR

# cd ./feeds/example_apps/$1
cd ./feeds/$FEEDS_DIR'/'$2

### Get the version by count the commits
VERSION=`git log --oneline | wc -l | tr -d ' '`

### Generate the revision by last commit
set -- $(git log -1 --format="%ct %h")
R_SECS="$(($1 % 86400))"
R_YDAY="$(date --utc --date="@$1" "+%y.%j")"
REVISION="$(printf 'git-%s.%05d-%s' "$R_YDAY" "$R_SECS" "$2")"

# echo 'Version:'$VERSION
# echo 'Revision:'$REVISION
echo "Release App:" $1 "Version:" $VERSION "Revision:" $REVISION


if [ -f "$RELEASE_DIR/$VERSION.zip" ]
then
	echo $1/$VERSION'.zip already released'
	exit
fi

mkdir ../__install_temp

git archive HEAD | tar -x -C ../__install_temp

cd ../__install_temp

# zip files
echo $VERSION > version
echo $REVISION >> version

zip -r -q $RELEASE_DIR/$VERSION.zip *

cd -
rm -rf ../__install_temp

md5sum -b $RELEASE_DIR/$VERSION.zip > $RELEASE_DIR/$VERSION.zip.md5
du $RELEASE_DIR/$VERSION.zip -sh
cat $RELEASE_DIR/$VERSION.zip.md5

## Copy to latest
cp -f $RELEASE_DIR/$VERSION.zip $RELEASE_DIR/latest.zip
cp -f $RELEASE_DIR/$VERSION.zip.md5 $RELEASE_DIR/latest.zip.md5
echo $VERSION > $RELEASE_DIR/latest.version

cd $BASE_DIR
