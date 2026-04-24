#!/usr/bin/env bash

ensure_thefuck_installed() {
  local dry_run="$1"
  local apt_cmd=""

  if command -v thefuck >/dev/null 2>&1; then
    log_info "$(i18n_msg thefuck_exists)"
    return 0
  fi

  log_info "$(i18n_msg install_thefuck)"
  if [[ "$dry_run" == "yes" ]]; then
    log_info "INSTALL PLAN: thefuck"
    return 0
  fi

  if command -v apt-get >/dev/null 2>&1; then
    if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
      apt_cmd="apt-get"
    elif command -v sudo >/dev/null 2>&1; then
      apt_cmd="sudo apt-get"
    fi
  fi

  if [[ -n "$apt_cmd" ]]; then
    $apt_cmd update
    if $apt_cmd install -y thefuck; then
      log_info "$(i18n_msg thefuck_install_done)"
      return 0
    fi
  fi

  if command -v pipx >/dev/null 2>&1; then
    if pipx install --force thefuck; then
      log_info "$(i18n_msg thefuck_install_done)"
      return 0
    fi
  fi

  if command -v python3 >/dev/null 2>&1 && python3 -m pip --version >/dev/null 2>&1; then
    if python3 -m pip install --user --upgrade thefuck; then
      log_info "$(i18n_msg thefuck_install_done)"
      return 0
    fi
  fi

  log_error "$(i18n_msg err_thefuck_install)"
  return 1
}
