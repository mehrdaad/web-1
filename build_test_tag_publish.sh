#!/bin/bash -Eeu

readonly SH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/sh" && pwd)"
source ${SH_DIR}/versioner_env_vars.sh
export $(versioner_env_vars)

"${SH_DIR}/containers_down.sh"
"${SH_DIR}/build_images.sh"
"${SH_DIR}/tag_image.sh"
if [ "${1:-}" == '--build-only' ] || [ "${1:-}" == '-bo' ] ; then
  exit 0
fi
"${SH_DIR}/setup_dependent_images.sh"
"${SH_DIR}/containers_up.sh"
"${SH_DIR}/run_tests_in_container.sh" "$@"
"${SH_DIR}/containers_down.sh"
"${SH_DIR}/on_ci_publish_tagged_images.sh"
