#!/bin/bash
#
# Utility script to create a multi-architecture docker builder
#
# usage:
#   $ bash ./lpm_utility_script/lpm_create_multiarch_docker_builder.bash
#

function lpm::create_multiarch_docker_builder() {
  # ....Project root logic.........................................................................
  local TMP_CWD
  TMP_CWD=$(pwd)

  # ....Project root logic.........................................................................
  LPM_PATH=$(git rev-parse --show-toplevel)
  cd "${LPM_PATH}/build_system" || exit

  # ....Load environment variables from file.......................................................
  set -o allexport
  source .env
  source .env.prompt
  set +o allexport

  # ....Load helper function.......................................................................
  # import shell functions from utilities library
  source ./function_library/prompt_utilities.bash

  # ====Begin======================================================================================
  print_formated_script_header 'lpm_create_multiarch_docker_builder.bash'

  # ...............................................................................................
  echo
  print_msg "Create a multi-architecture docker builder"
  echo

  docker buildx create \
    --name local-builder-multiarch-virtual \
    --driver docker-container \
    --platform linux/amd64,linux/arm64 \
    --bootstrap \
    --use

  docker buildx ls

  print_formated_script_footer 'lpm_create_multiarch_docker_builder.bash' "${NBS_LINE_CHAR_UTIL}"
  # ====Teardown===================================================================================
  cd "${TMP_CWD}"
}

# ::::main:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
lpm::create_multiarch_docker_builder