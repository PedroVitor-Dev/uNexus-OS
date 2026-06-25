#!/usr/bin/env bash
#
# uNexus AI local model setup.
#
# This script is never run automatically. It installs a local GGUF model only
# after explicit user action, and curated downloads require pinned SHA-256.

set -euo pipefail

MODEL_DIR="${HOME}/.local/share/unexus/ai/models"
mkdir -p "${MODEL_DIR}"

declare -A MODELS=(
  ["qwen2.5-3b"]="https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/resolve/main/qwen2.5-3b-instruct-q4_k_m.gguf|<SHA256_PLACEHOLDER>|~2.0GB"
  ["phi3.5-mini"]="https://huggingface.co/microsoft/Phi-3.5-mini-instruct-gguf/resolve/main/phi-3.5-mini-instruct-q4_k_m.gguf|<SHA256_PLACEHOLDER>|~2.2GB"
)

usage() {
  echo "Usage: $0 <model-key>"
  echo "       $0 --local /path/to/model.gguf"
  echo
  echo "Available curated models:"
  for key in "${!MODELS[@]}"; do
    IFS='|' read -r _url _sha size <<< "${MODELS[$key]}"
    echo "  - ${key} (${size})"
  done
}

install_local() {
  local src="$1"
  if [[ ! -f "${src}" ]]; then
    echo "Error: file not found: ${src}" >&2
    exit 1
  fi

  if [[ "${src}" != *.gguf ]]; then
    echo "Error: expected a .gguf model file." >&2
    exit 1
  fi

  local dest="${MODEL_DIR}/$(basename "${src}")"
  install -m 0600 "${src}" "${dest}"
  echo "Installed local model at: ${dest}"
}

download_curated() {
  local key="$1"
  if [[ -z "${MODELS[${key}]:-}" ]]; then
    usage
    exit 1
  fi

  IFS='|' read -r url expected_sha size <<< "${MODELS[$key]}"
  if [[ "${expected_sha}" == "<SHA256_PLACEHOLDER>" ]]; then
    echo "Refusing to download '${key}' without a pinned SHA-256." >&2
    echo "Update scripts/setup-ai-model.sh with a verified hash before shipping this model." >&2
    exit 1
  fi

  local filename
  filename="$(basename "${url}")"
  local dest="${MODEL_DIR}/${filename}"

  echo "This will download '${key}' (${size}) from:"
  echo "  ${url}"
  echo
  echo "No prompts, logs or local system data are sent. This performs only a standard HTTP GET."
  read -rp "Proceed? [y/N] " confirm
  [[ "${confirm}" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

  curl -L --fail --progress-bar -o "${dest}.part" "${url}"

  local actual_sha
  actual_sha="$(sha256sum "${dest}.part" | cut -d' ' -f1)"
  if [[ "${actual_sha}" != "${expected_sha}" ]]; then
    echo "Checksum mismatch. Refusing to install this model." >&2
    echo "Expected: ${expected_sha}" >&2
    echo "Got:      ${actual_sha}" >&2
    rm -f "${dest}.part"
    exit 1
  fi

  mv "${dest}.part" "${dest}"
  chmod 0600 "${dest}"
  echo "Model verified and installed at: ${dest}"
}

main() {
  if [[ "${1:-}" == "--local" ]]; then
    install_local "${2:?Provide a local .gguf path}"
    exit 0
  fi

  if [[ -z "${1:-}" ]]; then
    usage
    exit 1
  fi

  download_curated "$1"
}

main "$@"
