#!/bin/bash

#Usage
if [ -z "$1" ]; then
	echo "Usage: build.sh path/to/jenkins.war"
	exit 1
fi

# Set up build tools
DEV_DIR=`xcode-select -print-path`
PACKAGEMAKER="$DEV_DIR/Applications/Utilities/PackageMaker.app/Contents/MacOS/PackageMaker"

# Get the Jenkins version number
cp "$1" $(dirname $0)/jenkins.war.tmp
pushd $(dirname $0)
if [ -z "$2" ]; then
  version=$(unzip -p $(dirname $0)/jenkins.war.tmp META-INF/MANIFEST.MF | grep Implementation-Version | cut -d ' ' -f2 | tr - .)
else
  version="$2"
fi
echo Version is $version
PKG_NAME="JenkinsInstaller-${version}.pkg"
PKG_TITLE="Jenkins ${version}"
rm $(dirname $0)/jenkins.war.tmp

# Fiddle with the package document so it points to the jenkins.war file provided
PACKAGEMAKER_DOC="$(dirname $0)/JenkinsInstaller.pmdoc"
sed s,"pt=\".*\" m=","pt=\"${1}\" m=",g $PACKAGEMAKER_DOC/01jenkins-contents.xml > $PACKAGEMAKER_DOC/01jenkins-contents.xml.tmp
mv -f $PACKAGEMAKER_DOC/01jenkins-contents.xml.tmp $PACKAGEMAKER_DOC/01jenkins-contents.xml
sed s,"<installFrom mod=\"true\">.*</installFrom>","<installFrom mod=\"true\">${1}</installFrom>",g $PACKAGEMAKER_DOC/01jenkins.xml > $PACKAGEMAKER_DOC/01jenkins.xml.tmp
mv -f $PACKAGEMAKER_DOC/01jenkins.xml.tmp $PACKAGEMAKER_DOC/01jenkins.xml

# Build the package
${PACKAGEMAKER} \
	-v \
	--doc ${PACKAGEMAKER_DOC} \
	--out ${PKG_NAME} \
	--version "${version}" \
	--title ${PKG_TITLE}

