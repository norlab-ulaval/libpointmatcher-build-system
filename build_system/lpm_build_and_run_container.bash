#!/bin/bash
#
# Build and run a single container based on docker compose docker-compose.libpointmatcher.build.yaml
#
# Usage:
#   $ bash lpm_build_and_run_container.bash [<optional flag>] [-- <any docker cmd+arg>]
#
# Arguments:
#   [--libpointmatcher-version="latest"]     The libpointmatcher release tag (default: see LPM_VERSION)
#   [--os-name="ubuntu"]                     The operating system name. Either 'ubuntu' or 'osx' (default: see OS_NAME)
#   [--os-version="jammy"]                  Name named operating system version, see .env for supported version (default: see OS_VERSION)
#   [-- <any docker cmd+arg>]       Any argument passed after '--' will be passed to docker compose as docker command and arguments
#                                   (default: see DOCKER_COMPOSE_CMD_ARGS)
#   [-h, --help]                    Get help
#   [--debug-docker]                BUILDKIT_PROGRESS=plain
#
set -e
#set -v
#set -x

# ....Default......................................................................................................
LPM_VERSION='latest'
OS_NAME='ubuntu'
OS_VERSION='20.04'
DOCKER_COMPOSE_CMD_ARGS='up --build --force-recreate'

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

function print_help_in_terminal() {
  echo -e "\$ ${0} [<optional flag>] [<any other flag>]"
  echo ""
  echo -e "    \033[1m<optional argument>:\033[0m"
  echo "      --libpointmatcher-version=\"latest\"     The libpointmatcher release tag (default to latest 'latest')"
  echo "      --os-name=\"ubuntu\"                     The operating system name. Either 'ubuntu' or 'osx' (default to 'ubuntu')"
  echo "      --os-version=\"jammy\"                  Name named operating system version, see .env for supported version (default to 'jammy')"
  echo "      [-- <any docker cmd+arg>]     Any argument passed after '--' will be passed to docker compose as docker command and arguments (default to '${DOCKER_COMPOSE_CMD_ARGS}')"
  echo "      -h, --help                    Get help"
  echo "      --debug-docker                Set BUILDKIT_PROGRESS=plain"
  echo ""
}

# ....Pass parameters..............................................................................................


# ....Script command line flags....................................................................................
## todo: on task end >> comment next dev bloc ↓↓
#echo "${0}: all arg >>" \
#  && echo "${@}"

for arg in "$@"; do
  case $arg in
  # (Priority) ToDo: fixme!!
  --libpointmatcher-version)
    LPM_VERSION="${arg}"
    shift
    ;;
  # (Priority) ToDo: fixme!!
  --os-name)
    OS_NAME="${arg}"
    shift
    ;;
  # (Priority) ToDo: fixme!!
  --os-version)
    OS_VERSION="${arg}"
    shift
    ;;
  # (Priority) ToDo: fixme!!
#  --debug-docker)
#    export BUILDKIT_PROGRESS=plain
#    shift
#    ;;
  -h | --help)
    print_help_in_terminal
    exit
    ;;
  --) # no more option
    shift
#    DOCKER_COMPOSE_CMD_ARGS="${arg}"
    DOCKER_COMPOSE_CMD_ARGS="${@}"
    break
    ;;
  *) # Default case
    break
    ;;
  esac

  shift
done

# ====Begin========================================================================================================
print_formated_script_header 'lpm_build_and_run_container.bash' =

# ..................................................................................................................
# Set environment variable LPM_IMAGE_ARCHITECTURE
source ./lpm_which_architecture.bash

# ..................................................................................................................
print_msg "Build images specified in 'docker-compose.libpointmatcher.build.yaml'"

# Note: Used for documentation inside container. LPM_VERSION will be used to fetch the repo at release tag (ref task NMO-252)
export LPM_VERSION

# (Priority) ToDo: implement other OS support (ref task NMO-213 OsX arm64-Darwin CD components and NMO-210 OsX x86 CD components)
export DEPENDENCIES_BASE_IMAGE="${OS_NAME}"
export DEPENDENCIES_BASE_IMAGE_TAG="${OS_VERSION}"

export LPM_IMAGE_TAG="${LPM_VERSION}-${DEPENDENCIES_BASE_IMAGE}${OS_VERSION}-${LPM_IMAGE_ARCHITECTURE}"

print_msg "Building tag ${MSG_DIMMED_FORMAT}${LPM_IMAGE_TAG}${MSG_END_FORMAT}"
print_msg "Environment variables set for this build run:\n${MSG_DIMMED_FORMAT}$(printenv | grep -i -e LPM_ -e DEPENDENCIES_BASE_IMAGE -e BUILDKIT)${MSG_END_FORMAT}"

## docker compose [-f <theComposeFile> ...] [options] [COMMAND] [ARGS...]
## docker compose [-f <theComposeFile> ...] build --no-cache --push
## docker compose build [OPTIONS] [SERVICE...]
## docker compose run [OPTIONS] SERVICE [COMMAND] [ARGS...]

# ////DEV TEST: $ Docker compose////////////////////////////////////////////////////////////////////////////////////
FULL_DOCKER_COMMAND="compose -f docker-compose.libpointmatcher.build.yaml ${DOCKER_COMPOSE_CMD_ARGS}"
print_msg "Execute ${MSG_DIMMED_FORMAT}$ docker ${FULL_DOCKER_COMMAND}${MSG_END_FORMAT}"

# shellcheck disable=SC2086
docker ${FULL_DOCKER_COMMAND}

print_msg_done "${MSG_DIMMED_FORMAT}$ docker ${FULL_DOCKER_COMMAND}${MSG_END_FORMAT}"

## ////DEV TEST: $ Docker build//////////////////////////////////////////////////////////////////////////////////////
#print_msg "Execute TEST ${MSG_DIMMED_FORMAT}$ docker build -f ubuntu/Dockerfile.dependencies -t ${LPM_IMAGE_TAG} . ${MSG_END_FORMAT}"
#docker build -f ubuntu/Dockerfile.dependencies -t "${LPM_IMAGE_TAG}" .



draw_horizontal_line_across_the_terminal_window =
# ====Teardown=====================================================================================================
cd "${TMP_CWD}"

