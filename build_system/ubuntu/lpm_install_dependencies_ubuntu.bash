#!/bin/bash -i
#
set -e
#set -v

# ....Project root logic...........................................................................................
TMP_CWD=$(pwd)

if [[ "$(basename $(pwd))" != "build_system" ]]; then
  cd ../
fi


# ....Load environment variables from file.........................................................................
set -o allexport
source ./.env
source ./.env.prompt
set +o allexport

# skip GUI dialog by setting everything to default
export DEBIAN_FRONTEND=noninteractive

# ....Helper function..............................................................................................
# import shell functions from Libpointmatcher-build-system utilities library
source ./function_library/prompt_utilities.bash
source ./function_library/terminal_splash.bash
source ./function_library/general_utilities.bash

# Set environment variable LPM_IMAGE_ARCHITECTURE
source ./lpm_utility_script/lpm_export_which_architecture.bash

# ====Begin========================================================================================================
SHOW_SPLASH_IDU="${SHOW_SPLASH_IDU:-true}"

if [[ "${SHOW_SPLASH_IDU}" == 'true' ]]; then
  norlab_splash "${LPM_SPLASH_NAME}" "https://github.com/${LPM_LIBPOINTMATCHER_SRC_DOMAIN}/${LPM_LIBPOINTMATCHER_SRC_REPO_NAME}"
fi

print_formated_script_header "lpm_install_dependencies_ubuntu.bash (${LPM_IMAGE_ARCHITECTURE})" "${LPM_LINE_CHAR_INSTALLER}"

# ................................................................................................................
teamcity_service_msg_blockOpened "Install development utilities"
#if [[ ${IS_TEAMCITY_RUN} == true ]]; then
#  echo "##teamcity[blockOpened name='${MSG_BASE_TEAMCITY} Install development utilities']"
#else
#  echo
#  print_msg "Install development utilities"
#  echo
#fi

sudo apt-get update &&
  sudo apt-get install --assume-yes \
    lsb-release \
    build-essential \
    ca-certificates \
    curl \
    wget \
    git \
    g++ \
    gcc \
    make \
    cmake \
    cmake-gui &&
  sudo rm -rf /var/lib/apt/lists/*

cmake --version

teamcity_service_msg_blockClosed
#if [[ ${IS_TEAMCITY_RUN} == true ]]; then
#  echo "##teamcity[blockClosed name='${MSG_BASE_TEAMCITY} Install development utilities']"
#fi

# ................................................................................................................
teamcity_service_msg_blockOpened "Install development utilities (python)"
#if [[ ${IS_TEAMCITY_RUN} == true ]]; then
#  echo "##teamcity[blockOpened name='${MSG_BASE_TEAMCITY} Install development utilities (python)']"
#fi

source ./ubuntu/lpm_install_python_dev_tools.bash

## ToDo: assessment >> check if next bloc ↓↓ is needed
#sudo apt-get update \
#    && sudo apt-get install --assume-yes \
#        python3-opengl \
#        python3-numpy \
#        python-is-python3 \
#        python3-vcstool \
#    && sudo rm -rf /var/lib/apt/lists/*;

teamcity_service_msg_blockClosed
#if [[ ${IS_TEAMCITY_RUN} == true ]]; then
#  echo "##teamcity[blockClosed name='${MSG_BASE_TEAMCITY} Install development utilities (python)']"
#fi


# ................................................................................................................
# https://www.boost.org/doc/libs/1_79_0/more/getting_started/unix-variants.html
teamcity_service_msg_blockOpened "Install Libpointmatcher dependencies › Boost"
#if [[ ${IS_TEAMCITY_RUN} == true ]]; then
#  echo "##teamcity[blockOpened name='${MSG_BASE_TEAMCITY} Install Libpointmatcher dependencies › Boost']"
#else
#  echo
#  print_msg "Install Libpointmatcher dependencies › 'Boost'"
#  echo
#fi

sudo apt-get update &&
  sudo apt-get install --assume-yes \
    libboost-all-dev &&
  sudo rm -rf /var/lib/apt/lists/*

teamcity_service_msg_blockClosed
#if [[ ${IS_TEAMCITY_RUN} == true ]]; then
#  echo "##teamcity[blockClosed name='${MSG_BASE_TEAMCITY} Install Libpointmatcher dependencies › Boost']"
#fi

# ................................................................................................................
# https://eigen.tuxfamily.org/index.php
teamcity_service_msg_blockOpened "Install Libpointmatcher dependencies › Eigen"
#if [[ ${IS_TEAMCITY_RUN} == true ]]; then
#  echo "##teamcity[blockOpened name='${MSG_BASE_TEAMCITY} Install Libpointmatcher dependencies › Eigen']"
#else
#  echo
#  print_msg "Install Libpointmatcher dependencies › 'Eigen'"
#  echo
#fi

sudo apt-get update &&
  sudo apt-get install --assume-yes \
    libeigen3-dev &&
  sudo rm -rf /var/lib/apt/lists/*

teamcity_service_msg_blockClosed
#if [[ ${IS_TEAMCITY_RUN} == true ]]; then
#  echo "##teamcity[blockClosed name='${MSG_BASE_TEAMCITY} Install Libpointmatcher dependencies › Eigen']"
#fi


# ................................................................................................................
# https://github.com/ethz-asl/libnabo
teamcity_service_msg_blockOpened "Install Libpointmatcher dependencies › Libnabo"
#if [[ ${IS_TEAMCITY_RUN} == true ]]; then
#  echo "##teamcity[blockOpened name='${MSG_BASE_TEAMCITY} Install Libpointmatcher dependencies › Libnabo']"
#else
#  echo
#  print_msg "Install Libpointmatcher dependencies › 'Libnabo'"
#  echo
#fi

print_msg "Create required dir structure"
mkdir -p "${LPM_INSTALLED_LIBRARIES_PATH}"

# ToDo: assessment >> ANN and FLANN should be required only for `make test` benchmarks

## Note:ANN was not mentionned in doc --> probably because it's only used in benchmark test
## ANN is a library written in C++, which supports data structures and algorithms for both exact and approximate nearest neighbor searching in arbitrarily high dimensions.
## https://www.cs.umd.edu/~mount/ANN/
#cd "${LPM_INSTALLED_LIBRARIES_PATH}"
#wget https://www.cs.umd.edu/~mount/ANN/Files/1.1.2/ann_1.1.2.tar.gz
#tar xzf ann_1.1.2.tar.gz
#cd ann_1.1.2/
#make linux-g++
#sudo cp lib/libANN.a /usr/local/lib/
#sudo cp include/ANN/ANN.h /usr/local/include/
## shellcheck disable=SC2103
#cd ..
#
#
## Note:FLANN was not mentionned in doc --> probably because it's only used in benchmark test
## Fast Library for Approximate Nearest Neighbors - development
## FLANN is a library for performing fast approximate nearest neighbor searches in high dimensional spaces.
## https://github.com/flann-lib/flann
#sudo apt-get update \
#    && sudo apt-get install --assume-yes \
#        libflann-dev \
#    && sudo rm -rf /var/lib/apt/lists/*

cd "${LPM_INSTALLED_LIBRARIES_PATH}"
git clone https://github.com/ethz-asl/libnabo.git &&
  cd libnabo &&
  mkdir build && cd build

# git checkout 1.0.7

teamcity_service_msg_compilationStarted "cmake"
#if [[ ${IS_TEAMCITY_RUN} == true ]]; then echo "##teamcity[compilationStarted compiler='${MSG_BASE_TEAMCITY} cmake']"; fi

cmake -D CMAKE_BUILD_TYPE=RelWithDebInfo .. &&
  make -j $(nproc) &&
#  make test &&              # (CRITICAL) ToDo: on task end >> unmute this line ←
  sudo make install

teamcity_service_msg_compilationFinished
#if [[ ${IS_TEAMCITY_RUN} == true ]]; then echo "##teamcity[compilationFinished compiler='${MSG_BASE_TEAMCITY} cmake']"; fi

teamcity_service_msg_blockClosed
#if [[ ${IS_TEAMCITY_RUN} == true ]]; then
#  echo "##teamcity[blockClosed name='${MSG_BASE_TEAMCITY} Install Libpointmatcher dependencies › Libnabo']"
#fi

# ................................................................................................................
teamcity_service_msg_blockOpened "Install Libpointmatcher dev tools"
#if [[ ${IS_TEAMCITY_RUN} == true ]]; then
#  echo "##teamcity[blockOpened name='${MSG_BASE_TEAMCITY} Install Libpointmatcher dev tools']"
#else
#  echo
#  print_msg "Install libpointmatcher dev tools"
#  echo
#fi

sudo apt-get update &&
  sudo apt-get install --assume-yes \
    libyaml-cpp-dev &&
  sudo rm -rf /var/lib/apt/lists/*

teamcity_service_msg_blockClosed
#if [[ ${IS_TEAMCITY_RUN} == true ]]; then
#  echo "##teamcity[blockClosed name='${MSG_BASE_TEAMCITY} Install Libpointmatcher dev tools']"
#fi


print_msg_done "Libpointmatcher dependencies installed"
print_formated_script_footer "lpm_install_dependencies_ubuntu.bash (${LPM_IMAGE_ARCHITECTURE})" "${LPM_LINE_CHAR_INSTALLER}"
# ====Teardown=====================================================================================================
cd "${TMP_CWD}"

