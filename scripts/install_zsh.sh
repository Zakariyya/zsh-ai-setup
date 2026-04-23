#!/usr/bin/env bash

ensure_zsh_installed() {
  local dry_run="$1"

  if command -v zsh >/dev/null 2>&1; then
    return 0
  fi

  log_info "$(i18n_msg zsh_missing)"
  if [[ "$dry_run" == "yes" ]]; then
    return 0
  fi

  if ! command -v sudo >/dev/null 2>&1; then
    log_error "$(i18n_msg err_need_sudo)"
    return 1
  fi

  sudo apt-get update
  sudo apt-get install -y zsh
  log_info "$(i18n_msg zsh_install_done)"
}

ensure_oh_my_zsh() {
  local dry_run="$1"
  local state_file="$2"

  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    return 0
  fi

  if ! command -v git >/dev/null 2>&1; then
    log_error "$(i18n_msg err_need_git)"
    return 1
  fi

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

  if chsh -s "$zsh_path" "$USER"; then
    log_info "$(i18n_msg set_default_shell_ok)"
  else
    log_warn "$(i18n_msg err_chsh)"
  fi
}
