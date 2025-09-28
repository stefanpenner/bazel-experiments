#!/usr/bin/env bash

set -euo pipefail

# Try to locate runfiles helpers if Bazel didn't set the environment for us.
if [[ -z "${RUNFILES_DIR:-}" && -z "${RUNFILES_MANIFEST_FILE:-}" ]]; then
  case "${BASH_SOURCE[0]}" in
  */*) script_dir="${BASH_SOURCE[0]%/*}" ;;
  *) script_dir="." ;;
  esac

  if [[ -d "${BASH_SOURCE[0]}.runfiles" ]]; then
    export RUNFILES_DIR="${BASH_SOURCE[0]}.runfiles"
  elif [[ -f "${BASH_SOURCE[0]}.runfiles_manifest" ]]; then
    export RUNFILES_MANIFEST_FILE="${BASH_SOURCE[0]}.runfiles_manifest"
  elif [[ -d "$script_dir/../_main.runfiles" ]]; then
    export RUNFILES_DIR="$script_dir/../_main.runfiles"
  elif [[ -f "$script_dir/../_main.runfiles_manifest" ]]; then
    export RUNFILES_MANIFEST_FILE="$script_dir/../_main.runfiles_manifest"
  fi
fi

if [[ -n "${RUNFILES_DIR:-}" && -f "$RUNFILES_DIR/bazel_tools/tools/bash/runfiles/runfiles.bash" ]]; then
  # shellcheck source=/dev/null
  source "$RUNFILES_DIR/bazel_tools/tools/bash/runfiles/runfiles.bash"
elif [[ -n "${RUNFILES_MANIFEST_FILE:-}" ]]; then
  runfiles_bash="$(grep -m1 '^bazel_tools/tools/bash/runfiles/runfiles.bash ' "$RUNFILES_MANIFEST_FILE" | cut -d ' ' -f 2-)"
  if [[ -z "$runfiles_bash" ]]; then
    echo "Unable to locate runfiles.bash from manifest" >&2
    exit 1
  fi
  # shellcheck source=/dev/null
  source "$runfiles_bash"
else
  echo "RUNFILES_DIR or RUNFILES_MANIFEST_FILE must be set" >&2
  exit 1
fi

if [[ -z "${DEPLOY_OCI_LOAD_BINARY:-}" || -z "${DEPLOY_REPO_TAG:-}" ]]; then
  echo "DEPLOY_OCI_LOAD_BINARY and DEPLOY_REPO_TAG must be set" >&2
  exit 1
fi

"$DEPLOY_OCI_LOAD_BINARY"

docker run --rm -i --network host "$DEPLOY_REPO_TAG"
