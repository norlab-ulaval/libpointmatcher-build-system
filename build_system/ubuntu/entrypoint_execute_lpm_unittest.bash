#!/bin/bash -i
#
# Usage:
#   $ bash entrypoint_execute_lpm_unittest.bash [<any>]
#
# Parameter
#   <any> (Optional) Everything passed here will be executed at the end of this script
#
set -e

# ====Build system tools===========================================================================================
cd "${LPM_INSTALLED_LIBRARIES_PATH}/${LPM_LIBPOINTMATCHER_SRC_REPO_NAME}/build_system"

# ....Load environment variables from file.........................................................................
set -o allexport
source .env
set +o allexport

# ....Helper function..............................................................................................
## import shell functions from Libpointmatcher-build-system utilities library
source ./function_library/prompt_utilities.bash

# ==== Execute libpointmatcher unit-test===========================================================================
cd "${LPM_INSTALLED_LIBRARIES_PATH}/${LPM_LIBPOINTMATCHER_SRC_REPO_NAME}"
sudo chmod +x ./utest/listVersionsUbuntu.sh
utest/listVersionsUbuntu.sh

cd "${LPM_INSTALLED_LIBRARIES_PATH}/${LPM_LIBPOINTMATCHER_SRC_REPO_NAME}/build"

if [[ -d ./utest ]]; then
  print_msg "Starting Libpointmatcher GTest unit-test"
  sudo chmod +x utest/utest
  utest/utest --path "${LPM_INSTALLED_LIBRARIES_PATH}/${LPM_LIBPOINTMATCHER_SRC_REPO_NAME}/examples/data/"
else
  print_msg_warning "Directory ${MSG_DIMMED_FORMAT}utest${MSG_END_FORMAT} was not created during compilation. Skipping test."
fi

# ====Continue=====================================================================================================
#exit "$(echo $?)"
exec "$@"
