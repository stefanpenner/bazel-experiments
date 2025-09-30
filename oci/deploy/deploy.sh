#!/usr/bin/env bash

set -euo pipefail

# Bootstrap runfiles, and ensure they are present
if [[ -z "${RUNFILES_DIR+x}" ]]; then
  [[ -d "$0.runfiles" ]] || {
    echo "no runfiles dir; try 'bazel run'"
    exit 1
  }
  export RUNFILES_DIR="$0.runfiles"
fi

# check if docker is installed
if ! command -v docker &>/dev/null; then
  echo "Error: Docker is not installed or not in PATH" >&2
  echo "" >&2
  echo "Please install Docker to run this deployment script." >&2
  echo "Visit https://docs.docker.com/get-docker/ for installation instructions." >&2
  echo "" >&2
  echo "Note: This script uses host networking (--network host)." >&2
  echo "" >&2
  echo "Note: On macOS, host networking requires additional setup:" >&2
  echo "  1. Open Docker Desktop settings" >&2
  echo "  2. Go to 'Resources' → 'Network'" >&2
  echo "  3. Enable 'host networking'" >&2
  echo "  4. Restart Docker Desktop" >&2
  exit 1
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
