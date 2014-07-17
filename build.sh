#!/bin/bash

# Use a particular maven repository
LOCAL_REPO=$(pwd)/localRepo

# Make sure we have enough memory for Maven and that "javadoc" can
# can be found. We also don't want to use mirrors.
export MAVEN_OPTS="-Xmx2048m -Declipse.p2.mirrors=false -Declipse.javadoc=$(which javadoc)"

# Clone the Eclipse platform.
if [ ! -f ./eclipse.platform.releng.aggregator/.gitmodules ];
then
	git clone -b R4_4 --recurse-submodules https://git.eclipse.org/gitroot/platform/eclipse.platform.releng.aggregator.git
fi

pushd eclipse.platform.releng.aggregator

# clean up "dirt" from previous build
# see Bug 420078
git submodule foreach git clean -f -d -x
git submodule foreach git reset --hard HEAD
git clean -f -d -x
git reset --hard HEAD

# Update all source code repositories
git pull --recurse-submodules
git submodule update

# Apply the patches
pushd rt.equinox.binaries 
  git apply ../../rt.equinox.binaries.patch 
  git add .
  git commit -m "Commit for JGitBuildTimestampProvider to work"
popd
pushd rt.equinox.framework
  git apply ../../rt.equinox.framework.patch 
  git add .
  git commit -m "Commit for JGitBuildTimestampProvider to work"
popd
pushd eclipse.platform.swt.binaries
  git apply ../../eclipse.platform.swt.binaries.patch  
  git add .
  git commit -m "Commit for JGitBuildTimestampProvider to work"
popd
pushd eclipse.platform.ui
  git apply ../../eclipse.platform.ui.patch  
  git add .
  git commit -m "Commit for JGitBuildTimestampProvider to work"
popd
git apply ../eclipse.platform.releng.aggregator.patch

# run the build
mvn -Dmaven.repo.local=$LOCAL_REPO -e clean verify 

popd
