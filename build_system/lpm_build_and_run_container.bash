#!/bin/bash -i
#
# Build and run a single container based on docker compose docker-compose.libpointmatcher.build.yaml
#
# Usage:
#   $ bash lpm_build_and_run_container.bash [<optional flag>] [-- <any docker cmd+arg>]
#
# Arguments:
#   [--libpointmatcher-version latest]    The libpointmatcher release tag (default: see LPM_VERSION)
#   [--os-name ubuntu]                    The operating system name. Either 'ubuntu' or 'osx' (default: see OS_NAME)
#   [--os-version jammy]                  Name named operating system version, see .env for supported version (default: see OS_VERSION)
#   [-- <any docker cmd+arg>]             Any argument passed after '--' will be passed to docker compose as docker command and arguments
#                                         (default: see DOCKER_COMPOSE_CMD_ARGS)
#   [-h, --help]                          Get help
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
source ./function_library/general_utilities.bash

function print_help_in_terminal() {
  echo -e "\n
\$ ${0} [<optional flag>] [-- <any docker cmd+arg>]
  \033[1m
    <optional argument>:\033[0m
      -h, --help                              Get help
      --libpointmatcher-version latest        The libpointmatcher release tag (default to latest 'latest')
      --os-name ubuntu                        The operating system name. Either 'ubuntu' or 'osx' (default to 'ubuntu')
      --os-version jammy                      Name named operating system version, see .env for supported version
                                              (default to 'jammy')
  \033[1m
    [-- <any docker cmd+arg>]\033[0m                 Any argument passed after '--' will be passed to docker compose as docker
                                              command and arguments (default to '${DOCKER_COMPOSE_CMD_ARGS}')
"
}

# ....Pass parameters..............................................................................................


# ....Script command line flags....................................................................................
echo -e "${0}: all arg >> ${MSG_DIMMED_FORMAT}$*${MSG_END_FORMAT}" # ToDo: on task end >> delete this line ←
echo

#for arg in "$@"; do
while [ $# -gt 0 ]; do
  echo -e "'\$*' before: ${MSG_DIMMED_FORMAT}$*${MSG_END_FORMAT}" # ToDo: on task end >> delete this line ←
  echo -e "\$1: ${1}    \$2: $2" # ToDo: on task end >> delete this line ←
  echo -e "\$arg: ${arg}" # ToDo: on task end >> delete this line ←

  case $1 in
  --libpointmatcher-version)
    echo "got --libpointmatcher-version" # ToDo: on task end >> delete this line ←
    LPM_VERSION="${2}"
    shift # Remove argument (--libpointmatcher-version)
    shift # Remove argument value
    ;;
  --os-name)
    echo "got --os-name" # ToDo: on task end >> delete this line ←
    OS_NAME="${2}"
    shift # Remove argument (--os-name)
    shift # Remove argument value
    ;;
  --os-version)
    echo "got --os-version" # ToDo: on task end >> delete this line ←
    OS_VERSION="${2}"
    shift # Remove argument (--os-version)
    shift # Remove argument value
    ;;
  -h | --help)
    print_help_in_terminal
    exit
    ;;
  --) # no more option
    shift
    echo -e "'\$*' after (and break): ${MSG_DIMMED_FORMAT}$*${MSG_END_FORMAT}" # ToDo: on task end >> delete this line ←
    DOCKER_COMPOSE_CMD_ARGS="$*"
    break
    ;;
  *) # Default case
    break
    ;;
  esac

  echo -e "'\$*' after: ${MSG_DIMMED_FORMAT}$*${MSG_END_FORMAT}" # ToDo: on task end >> delete this line ←
  echo -e "after \$1: ${1}    \$2: $2" # ToDo: on task end >> delete this line ←
  echo

done

echo -e "'\$*' on DONE: ${MSG_DIMMED_FORMAT}$*${MSG_END_FORMAT}" # ToDo: on task end >> delete this line ←

# ToDo: on task end >> delete next bloc ↓↓
echo -e "
${MSG_DIMMED_FORMAT}
LPM_VERSION=${LPM_VERSION}
OS_NAME=${OS_NAME}
OS_VERSION=${OS_VERSION}
DOCKER_COMPOSE_CMD_ARGS=${DOCKER_COMPOSE_CMD_ARGS}
${MSG_END_FORMAT}
"


# ====Begin========================================================================================================
print_formated_script_header 'lpm_build_and_run_container.bash' =

# ..................................................................................................................
# Set environment variable LPM_IMAGE_ARCHITECTURE
source ./lpm_utility_script/lpm_which_architecture.bash

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

print_msg_warning "cwd › $(pwd)" # ToDo: on task end >> delete this line ←
tree -L 1
echo -e "DOCKER_COMPOSE_CMD_ARGS › ${MSG_DIMMED_FORMAT}${DOCKER_COMPOSE_CMD_ARGS}${MSG_END_FORMAT}" # ToDo: on task end >> delete this line ←


show_and_execute_docker "compose -f docker-compose.libpointmatcher.build.yaml ${DOCKER_COMPOSE_CMD_ARGS}"

echo
print_msg "Exit $0"
draw_horizontal_line_across_the_terminal_window =
# ====Teardown=====================================================================================================
cd "${TMP_CWD}"

