#!/usr/bin/env bash

OS_ID=""
OS_ID_LIKE=""
IS_WSL="no"
PKG_MGR=""

detect_os() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    OS_ID="${ID:-unknown}"
    OS_ID_LIKE="${ID_LIKE:-}"
  else
    OS_ID="unknown"
    OS_ID_LIKE=""
  fi

  if grep -qiE '(microsoft|wsl)' /proc/version 2>/dev/null; then
    IS_WSL="yes"
  fi

  if [[ "$OS_ID" =~ ^(ubuntu|debian|deepin)$ ]] || [[ "$OS_ID_LIKE" =~ (^|[[:space:]])(ubuntu|debian)([[:space:]]|$) ]]; then
    PKG_MGR="apt"
  else
    PKG_MGR=""
  fi
}

is_supported_platform() {
  if [[ "$IS_WSL" == "yes" ]]; then
    return 0
  fi
  if [[ "$OS_ID" =~ ^(ubuntu|debian|deepin)$ ]] || [[ "$OS_ID_LIKE" =~ (^|[[:space:]])(ubuntu|debian)([[:space:]]|$) ]]; then
    return 0
  fi
  return 1
}
