#!/usr/bin/env bash

OS_ID=""
IS_WSL="no"
PKG_MGR=""

detect_os() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    OS_ID="${ID:-unknown}"
  else
    OS_ID="unknown"
  fi

  if grep -qiE '(microsoft|wsl)' /proc/version 2>/dev/null; then
    IS_WSL="yes"
  fi

  case "$OS_ID" in
    ubuntu|debian) PKG_MGR="apt" ;;
    *) PKG_MGR="" ;;
  esac
}

is_supported_platform() {
  if [[ "$IS_WSL" == "yes" ]]; then
    return 0
  fi
  case "$OS_ID" in
    ubuntu|debian) return 0 ;;
    *) return 1 ;;
  esac
}
