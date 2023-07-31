#!/bin/bash
#
# Usage:
#   $ bash entrypoint_execute_lpm_unittest.bash [<any cmd>]
#
# Parameter
#   <any cmd> (Optional) Command executed in a subprocess at the end of the entrypoint script.
#
set -e # ToDo: on task end >> unmute this line ←

# ....Load environment variables from file.........................................................................
set -o allexport
source ../.env
set +o allexport

# ==== Build libpointmatcher checkout branch ======================================================================
source lpm_install_libpointmatcher_ubuntu.bash \
  --libpointmatcher-version ${LIBPOINTMATCHER_VERSION:?'err variable not set'} \
  ${LIBPOINTMATCHER_INSTALL_SCRIPT_FLAG}

# ====Continue=====================================================================================================
#exec "${@}"
exec "$@"
