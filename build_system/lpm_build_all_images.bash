#!/bin/bash
#
# Execute build matrix on docker compose docker-compose.libpointmatcher.build.yaml
#
# Usage:
#   $ bash lpm_build_all_images.bash [<any>]
#
# Arguments:
#   <any-docker-compose-flag> (Optional) any docker compose flag
#
set -e

# ....Project root logic...........................................................................................
TMP_CWD=$(pwd)

# ....Load environment variables from file.........................................................................
set -o allexport
source .env
source .env.prompt
set +o allexport

# ....Helper function..............................................................................................
# import shell functions from Libpointmatcher-build-system utilities library
source ./function_library/prompt_utilities.bash

# ====Begin========================================================================================================
print_formated_script_header 'lpm_build_all_images.bash' =

# ..................................................................................................................
# Set environment variable LPM_IMAGE_ARCHITECTURE
source ./lpm_which_architecture.bash
print_msg "Set env variable to LPM_IMAGE_ARCHITECTURE=${LPM_IMAGE_ARCHITECTURE:?'err: variable not set'}"

# ..................................................................................................................
print_msg "Build images specified in 'docker-compose.libpointmatcher.build.yaml' following the buildmatrix specified in the .env file"


for LPM_VERSION in "${LPM_LIBPOINTMATCHER_VERSIONS[@]}"; do

  # Note: LPM_VERSION is used for labeling inside container and will be used to fetch the repo at release tag (ref task NMO-252)
  export LPM_VERSION

  for OS_NAME in "${LPM_SUPPORTED_OS[@]}"; do

    # (Priority) ToDo: implement other OS support (ref task NMO-213 OsX arm64-Darwin CD components and NMO-210 OsX x86 CD components)
    export DEPENDENCIES_BASE_IMAGE="${OS_NAME}"

    for OS_VERSION in "${LPM_UBUNTU_SUPPORTED_VERSIONS[@]}"; do

      export DEPENDENCIES_BASE_IMAGE_TAG="${OS_VERSION}"

      #    export OS_TAG="${DEPENDENCIES_BASE_IMAGE}${OS_VERSION}" # ToDo: validate >> conversion to LPM_IMAGE_TAG
      export LPM_IMAGE_TAG="${LPM_VERSION}-${DEPENDENCIES_BASE_IMAGE}${OS_VERSION}-${LPM_IMAGE_ARCHITECTURE}"

      print_msg "Building tag ${MSG_DIMMED_FORMAT}${LPM_IMAGE_TAG}${MSG_END_FORMAT}"

      print_msg "Environment variables set for this build run:\n${MSG_DIMMED_FORMAT}$(printenv | grep -i -e LPM_ -e DEPENDENCIES_BASE_IMAGE -e BUILDKIT)${MSG_END_FORMAT}"

      FULL_DOCKER_COMMAND="compose -f docker-compose.libpointmatcher.build.yaml ${@}"
      print_msg "Execute ${MSG_DIMMED_FORMAT}$ docker ${FULL_DOCKER_COMMAND}${MSG_END_FORMAT}"

      # shellcheck disable=SC2086
      docker ${FULL_DOCKER_COMMAND}

      ## Legacy version
      # docker compose -f docker-compose.libpointmatcher.build.yaml build "${@}"

      print_msg_done "Build tag ${MSG_DIMMED_FORMAT}${LPM_IMAGE_TAG}${MSG_END_FORMAT} done"

    done
  done
done

print_msg_done "FINAL › All builds done"
draw_horizontal_line_across_the_terminal_window =
# ====Teardown=====================================================================================================
cd "${TMP_CWD}"
