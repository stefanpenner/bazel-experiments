#!/usr/bin/env bash

set -euo pipefail

# Bootstrap runfiles, and ensure they are present
if [[ ! -v RUNFILES_DIR ]]; then
  [[ -d "$0.runfiles" ]] || {
    echo "no runfiles dir; try 'bazel run'"
    exit 1
  }
  export RUNFILES_DIR="$0.runfiles"
fi

# ensure mandetory envvar are set
if [[ -z "${DEPLOY_OCI_LOAD_EXECUTABLE:-}" || -z "${DEPLOY_REPO_TAG:-}" ]]; then
  echo "DEPLOY_OCI_LOAD_EXECUTABLEand DEPLOY_REPO_TAG must be set" >&2
  exit 1
fi

# execute the OCI_LOAD target
"$DEPLOY_OCI_LOAD_EXECUTABLE"

# prepare docker arguments
docker_args=(--rm -i --network host $@)

if [[ -n "${DEPLOY_PORT:-}" ]]; then
  docker_args+=(-e PORT="$DEPLOY_PORT" -p "$DEPLOY_PORT:$DEPLOY_PORT")
fi

if [[ -n "${DEPLOY_ENV_KEYS:-}" ]]; then
  for key in $DEPLOY_ENV_KEYS; do
    value=${!key:-}
    docker_args+=(-e "$key=$value")
  done
fi

docker_args+=("$DEPLOY_REPO_TAG")

# run docker
docker run "${docker_args[@]}"
