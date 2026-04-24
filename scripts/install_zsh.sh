#!/usr/bin/env bash

resolve_apt_install_cmd() {
  if ! command -v apt-get >/dev/null 2>&1; then
    return 1
  fi

  if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
    printf '%s' "apt-get"
    return 0
  fi

  if command -v sudo >/dev/null 2>&1; then
    printf '%s' "sudo apt-get"
    return 0
  fi

  return 1
}

ensure_git_installed() {
  local dry_run="$1"
  local apt_cmd=""

  if command -v git >/dev/null 2>&1; then
    return 0
  fi

  log_info "$(i18n_msg git_missing)"
  if [[ "$dry_run" == "yes" ]]; then
    return 0
  fi

  apt_cmd="$(resolve_apt_install_cmd || true)"
  if [[ -z "$apt_cmd" ]]; then
    log_error "$(i18n_msg err_need_git)"
    return 1
  fi

  $apt_cmd update
  $apt_cmd install -y git
  log_info "$(i18n_msg git_install_done)"
}

ensure_zsh_installed() {
  local dry_run="$1"
  local apt_cmd=""

  if command -v zsh >/dev/null 2>&1; then
    return 0
  fi

  log_info "$(i18n_msg zsh_missing)"
  if [[ "$dry_run" == "yes" ]]; then
    return 0
  fi

  apt_cmd="$(resolve_apt_install_cmd || true)"
  if [[ -z "$apt_cmd" ]]; then
    log_error "$(i18n_msg err_need_sudo)"
    return 1
  fi

  $apt_cmd update
  $apt_cmd install -y zsh
  log_info "$(i18n_msg zsh_install_done)"
}

ensure_oh_my_zsh() {
  local dry_run="$1"
  local state_file="$2"

  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    return 0
  fi

  ensure_git_installed "$dry_run"

  if [[ "$dry_run" == "yes" ]]; then
    return 0
  fi

  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
  printf 'OH_MY_ZSH_INSTALLED_BY_SETUP=yes\n' >> "$state_file"
  log_info "$(i18n_msg omz_install_done)"
}

try_set_default_shell() {
  local enabled="$1"
  local dry_run="$2"

  [[ "$enabled" == "yes" ]] || return 0

  local zsh_path
  zsh_path="$(command -v zsh || true)"
  [[ -n "$zsh_path" ]] || return 1

  if [[ "$dry_run" == "yes" ]]; then
    return 0
  fi

  if [[ "${SHELL:-}" == "$zsh_path" ]]; then
    return 0
  fi

  if [[ ! -t 0 || ! -t 1 ]]; then
    log_warn "$(i18n_msg warn_chsh_non_tty)"
    return 0
  fi

  if chsh -s "$zsh_path" "$USER"; then
    log_info "$(i18n_msg set_default_shell_ok)"
  else
    log_warn "$(i18n_msg err_chsh)"
  fi
}
