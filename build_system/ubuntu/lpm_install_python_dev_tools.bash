#!/bin/bash
#
# Install python development tools
#
# usage:
#   $ bash build_system/lpm_install_python_dev_tools.bash
#
set -e

# ....Project root logic...........................................................................................
TMP_CWD=$(pwd)

if [[ "$(basename $(pwd))" != "build_system" ]]; then
  cd ../
fi

# ....Helper function..............................................................................................
## import shell functions from Libpointmatcher-build-system utilities library
source ./function_library/prompt_utilities.bash
source ./function_library/general_utilities.bash

# ====Install python version based on ubuntu distro================================================================
if [[ $(uname) == 'Linux' ]]; then

  # Retrieve ubuntu version number
  UBUNTU_VERSION=$(grep '^VERSION_ID' /etc/os-release)
  if [[ ${UBUNTU_VERSION} == '18.04' ]]; then

    # ....Case › Ubuntu bionic ==> python 2........................................................................
    teamcity_service_msg_blockOpened "Install python development tools for Ubuntu distro (python 2)"

    sudo apt-get update &&
      sudo apt-get install --assume-yes \
        python-dev \
        python-numpy &&
      sudo rm -rf /var/lib/apt/lists/*

    # Work around to install pip in python2
    curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
    sudo python2 get-pip.py

    teamcity_service_msg_blockClosed
  else
    teamcity_service_msg_blockOpened "Install python development tools for Ubuntu distro (python 3)"

    if [[ ${UBUNTU_VERSION} == '20.04' ]]; then
      # ....Case › Ubuntu distro still have to deal with python 2 legacy code.....................................
      sudo apt-get update &&
        sudo apt-get install --assume-yes \
          python3-dev \
          python3-pip \
          python3-numpy \
          python-is-python3 &&
        sudo rm -rf /var/lib/apt/lists/*
    else
      # ....Case › python 3 is Ubuntu default python version......................................................
      sudo apt-get update &&
        sudo apt-get install --assume-yes \
          python3-dev \
          python3-pip \
          python3-numpy &&
        sudo rm -rf /var/lib/apt/lists/*
    fi

    teamcity_service_msg_blockClosed
  fi
fi

# ====Universal python install step (common to all OS version)======================================================
teamcity_service_msg_blockOpened "Upgrade pip"

# python3 -m pip install --upgrade pip
pip install --no-cache-dir --upgrade pip

teamcity_service_msg_blockClosed
# ====Install TeamCity and CI/CD utilities==========================================================================
if [[ ${IS_TEAMCITY_RUN} == true ]]; then
  teamcity_service_msg_blockOpened "Install TeamCity and CI/CD python tools"
  # Note: dont hardcode 'pip' version (2 vs 3) as this step is also used by bionic distro
  pip install --no-cache-dir --upgrade pytest
  pip install --no-cache-dir teamcity-messages
  teamcity_service_msg_blockClosed
fi

# ====Teardown=====================================================================================================
cd "${TMP_CWD}"
