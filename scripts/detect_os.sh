#!/usr/bin/env bash

OS_ID=""
OS_ID_LIKE=""
OS_NAME=""
OS_PRETTY_NAME=""
IS_WSL="no"
PKG_MGR=""

is_debian_family_os() {
  local id="${OS_ID,,}"
  local like="${OS_ID_LIKE,,}"
  local name="${OS_NAME,,}"
  local pretty="${OS_PRETTY_NAME,,}"

  if [[ "$id" =~ ^(ubuntu|debian|deepin|linuxdeepin|uos)$ ]]; then
    return 0
  fi

  if [[ "$like" =~ (^|[[:space:]])(ubuntu|debian)([[:space:]]|$) ]]; then
    return 0
  fi

  if [[ "$name" == *deepin* || "$pretty" == *deepin* || "$name" == *uos* || "$pretty" == *uos* ]]; then
    return 0
  fi

  if [[ -f /etc/debian_version ]]; then
    return 0
  fi

  return 1
}

detect_os() {
  if [[ -f /etc/os-release ]]; then
    # shellcheck disable=SC1091
    source /etc/os-release
    OS_ID="${ID:-unknown}"
    OS_ID_LIKE="${ID_LIKE:-}"
    OS_NAME="${NAME:-}"
    OS_PRETTY_NAME="${PRETTY_NAME:-}"
  else
    OS_ID="unknown"
    OS_ID_LIKE=""
    OS_NAME=""
    OS_PRETTY_NAME=""
  fi

  if grep -qiE '(microsoft|wsl)' /proc/version 2>/dev/null; then
    IS_WSL="yes"
  fi

  if is_debian_family_os; then
    PKG_MGR="apt"
  else
    PKG_MGR=""
  fi
}

is_supported_platform() {
  if [[ "$IS_WSL" == "yes" ]]; then
    return 0
  fi
  if is_debian_family_os; then
    return 0
  fi
  return 1
}
