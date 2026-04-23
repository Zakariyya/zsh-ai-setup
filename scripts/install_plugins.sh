#!/usr/bin/env bash

declare -A ZSH_AI_PLUGIN_REPO
ZSH_AI_PLUGIN_REPO=(
  [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions.git"
  [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
  [zsh-completions]="https://github.com/zsh-users/zsh-completions.git"
  [fzf-tab]="https://github.com/Aloxaf/fzf-tab.git"
)

install_one_plugin() {
  local plugin="$1"
  local plugin_root="$2"
  local dry_run="$3"
  local force="$4"
  local manifest="$5"

  local repo target
  repo="${ZSH_AI_PLUGIN_REPO[$plugin]:-}"
  target="$plugin_root/$plugin"

  [[ -n "$repo" ]] || return 1

  if [[ -d "$target/.git" ]]; then
    if [[ "$force" == "yes" ]]; then
      if [[ "$dry_run" == "yes" ]]; then
        log_info "UPDATE PLAN: $plugin"
      else
        git -C "$target" pull --ff-only || true
      fi
    else
      log_info "$(i18n_msg plugin_skip): $plugin"
    fi
    return 0
  fi

  if [[ "$dry_run" == "yes" ]]; then
    log_info "INSTALL PLAN: $plugin"
    return 0
  fi

  git clone --depth=1 "$repo" "$target"
  printf 'managed-by=zsh-ai-setup\n' > "$target/.zsh-ai-setup-managed"
  append_manifest_line "$manifest" "$target" "$dry_run"
  return 0
}

install_plugins() {
  local install_plugins_flag="$1"
  local optional_csv="$2"
  local dry_run="$3"
  local force="$4"
  local manifest="$5"

  [[ "$install_plugins_flag" == "yes" ]] || return 0

  if ! command -v git >/dev/null 2>&1; then
    log_error "$(i18n_msg err_need_git)"
    return 1
  fi

  local plugin_root
  plugin_root="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
  if [[ "$dry_run" != "yes" ]]; then
    mkdir -p "$plugin_root"
  fi

  log_info "$(i18n_msg install_plugins)"

  local required=(zsh-autosuggestions zsh-syntax-highlighting)
  local p
  for p in "${required[@]}"; do
    install_one_plugin "$p" "$plugin_root" "$dry_run" "$force" "$manifest" || {
      log_error "$(i18n_msg err_plugin_install): $p"
      return 1
    }
  done

  if [[ -n "$optional_csv" ]]; then
    local oldifs
    oldifs="$IFS"
    IFS=','
    read -r -a opt_arr <<< "$optional_csv"
    IFS="$oldifs"

    for p in "${opt_arr[@]}"; do
      p="${p// /}"
      [[ -n "$p" ]] || continue
      install_one_plugin "$p" "$plugin_root" "$dry_run" "$force" "$manifest" || {
        log_error "$(i18n_msg err_plugin_install): $p"
        return 1
      }
    done
  fi

  log_info "$(i18n_msg plugin_install_done)"
}
