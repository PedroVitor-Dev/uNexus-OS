#!/usr/bin/env sh
set -eu

repo_root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
build_dir="${repo_root}/packages/unexus-shell/build"

cmake -S "${repo_root}/packages/unexus-shell" -B "$build_dir" -DCMAKE_BUILD_TYPE=Release
cmake --build "$build_dir"
