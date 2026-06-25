#!/usr/bin/env sh
set -eu

repo_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
build_dir="${BUILD_DIR:-${repo_root}/packages/unexus-shell/build}"
output_dir="${1:-${repo_root}/assets}"

cmake -S "${repo_root}/packages/unexus-shell" -B "${build_dir}"
cmake --build "${build_dir}"

"${build_dir}/unexus-shell" --capture-assets "${output_dir}"
