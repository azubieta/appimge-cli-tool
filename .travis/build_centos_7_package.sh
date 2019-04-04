#!/usr/bin/env bash

# Find the right sources dir path
SOURCES_DIR=`realpath $0`
SOURCES_DIR=`dirname ${SOURCES_DIR}`
SOURCES_DIR=`dirname ${SOURCES_DIR}`

mkdir docker-centos7-build-release

export CENTOS7_PACKAGE_REQUIRES="boost-filesystem, libarchive, cairo, librsvg2"
export CENTOS7_PACKAGE_PROVIDES="libappimage.so.1.0()(64bit), libKF5Attica.so.5()(64bit)"

sudo docker build -t build/centos7 ${SOURCES_DIR}/.travis/docker/centos_7/

BUILD_SCRIPT="\
        cmake3 /source \
            -DINSTALL_LIBAPPIMAGE=On\
            -DINSTALL_ATTICA=On\
            -DCMAKE_INSTALL_PREFIX=/usr \
            -DCMAKE_BUILD_TYPE=Release \
            -DAPPIMAGEHUB_CLI_V_SUFFIX=\"-Centos-7\" \
            -DCPACK_RPM_PACKAGE_REQUIRES='${CENTOS7_PACKAGE_REQUIRES}' \
            -DCPACK_RPM_PACKAGE_PROVIDES='${CENTOS7_PACKAGE_PROVIDES}' &&\
         make -j`nproc` && \
         cpack3 -G RPM"

sudo docker run -v ${PWD}:/source -v ${PWD}/docker-build-release:/build build/centos7 /bin/bash -c $BUILD_SCRIPT
