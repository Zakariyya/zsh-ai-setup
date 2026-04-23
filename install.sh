#!/usr/bin/env bash
set -euo pipefail

SELF_BOOTSTRAP_DIR=""

bootstrap_remote_root() {
  local raw_base repo ref temp_root rel_path dst_dir

  raw_base="${ZSH_AI_SETUP_RAW_BASE:-}"
  repo="${ZSH_AI_SETUP_REPO:-Zakariyya/zsh-ai-setup}"
  ref="${ZSH_AI_SETUP_REF:-main}"

  if [[ -z "$raw_base" ]]; then
    raw_base="https://raw.githubusercontent.com/${repo}/${ref}"
  fi

  if command -v mktemp >/dev/null 2>&1; then
    temp_root="$(mktemp -d)"
  else
    temp_root="${TMPDIR:-/tmp}/zsh-ai-setup.$$.$RANDOM"
    mkdir -p "$temp_root"
  fi

  SELF_BOOTSTRAP_DIR="$temp_root"

  fetch_one() {
    local rel="$1"
    local dst="$temp_root/$rel"
    dst_dir="$(dirname "$dst")"
    mkdir -p "$dst_dir"

    if command -v curl >/dev/null 2>&1; then
      curl -fsSL "$raw_base/$rel" -o "$dst"
    elif command -v wget >/dev/null 2>&1; then
      wget -qO "$dst" "$raw_base/$rel"
    else
      printf '[ERROR] curl or wget is required for remote bootstrap\n' >&2
      exit 1
    fi
  }

  for rel_path in \
    install.sh \
    scripts/i18n.sh \
    scripts/lib.sh \
    scripts/detect_os.sh \
    scripts/install_zsh.sh \
    scripts/install_plugins.sh \
    configs/.zshrc \
    configs/.zshenv \
    configs/aliases.zsh \
    configs/exports.zsh \
    configs/plugins.zsh \
    templates/startup-tip.en.txt \
    templates/startup-tip.zh-CN.txt
  do
    fetch_one "$rel_path"
  done

  ROOT_DIR="$temp_root"
}

if [[ -n "${BASH_SOURCE[0]:-}" && -r "${BASH_SOURCE[0]}" ]]; then
  ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
else
  bootstrap_remote_root
fi

cleanup() {
  if [[ -n "${SELF_BOOTSTRAP_DIR:-}" && -d "${SELF_BOOTSTRAP_DIR:-}" ]]; then
    rm -rf "$SELF_BOOTSTRAP_DIR"
  fi
}
trap cleanup EXIT

# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/i18n.sh"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib.sh"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/detect_os.sh"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/install_zsh.sh"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/install_plugins.sh"

LANG_OPT="auto"
RUN_MODE=""
INSTALL_PLUGINS="yes"
SHOW_STARTUP_TIPS="always"
SET_DEFAULT_SHELL="no"
BACKUP_MODE="yes"
DRY_RUN="no"
FORCE="no"
OPTIONAL_PLUGINS=""

usage() {
  cat <<USAGE
Usage: ./install.sh [options]

Options:
  --lang zh|en
  --interactive
  --non-interactive
  --install-plugins yes|no
  --show-startup-tips always|once|off
  --set-default-shell yes|no
  --backup yes|no
  --optional-plugins p1,p2
  --dry-run
  --force
  -h, --help
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --lang)
      LANG_OPT="${2:-}"; shift 2 ;;
    --interactive)
      RUN_MODE="interactive"; shift ;;
    --non-interactive)
      RUN_MODE="non-interactive"; shift ;;
    --install-plugins)
      INSTALL_PLUGINS="${2:-}"; shift 2 ;;
    --show-startup-tips)
      SHOW_STARTUP_TIPS="${2:-}"; shift 2 ;;
    --set-default-shell)
      SET_DEFAULT_SHELL="${2:-}"; shift 2 ;;
    --backup)
      BACKUP_MODE="${2:-}"; shift 2 ;;
    --optional-plugins)
      OPTIONAL_PLUGINS="${2:-}"; shift 2 ;;
    --dry-run)
      DRY_RUN="yes"; shift ;;
    --force)
      FORCE="yes"; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "$(i18n_msg err_arg): $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$RUN_MODE" ]]; then
  if [[ -t 0 ]]; then
    RUN_MODE="interactive"
  else
    RUN_MODE="non-interactive"
  fi
fi

set_i18n_lang "$LANG_OPT"
log_info "$(i18n_msg welcome)"

detect_os
if is_supported_platform; then
  log_info "$(i18n_msg os_supported)"
else
  log_error "$(i18n_msg os_unsupported)"
  exit 1
fi

case "$INSTALL_PLUGINS" in yes|no) ;; *) log_error "--install-plugins yes|no"; exit 1 ;; esac
case "$SHOW_STARTUP_TIPS" in always|once|off) ;; *) log_error "--show-startup-tips always|once|off"; exit 1 ;; esac
case "$SET_DEFAULT_SHELL" in yes|no) ;; *) log_error "--set-default-shell yes|no"; exit 1 ;; esac
case "$BACKUP_MODE" in yes|no) ;; *) log_error "--backup yes|no"; exit 1 ;; esac

if [[ "$DRY_RUN" == "yes" ]]; then
  log_info "$(i18n_msg dry_run)"
fi

if [[ "$RUN_MODE" == "interactive" ]]; then
  read -r -p "$(i18n_msg prompt_lang): " _lang
  if [[ -n "${_lang:-}" ]]; then
    set_i18n_lang "$_lang"
  fi

  read -r -p "$(i18n_msg prompt_install_plugins) " _plugins
  [[ -n "${_plugins:-}" ]] && INSTALL_PLUGINS="$_plugins"

  read -r -p "$(i18n_msg prompt_optional_plugins) " _optional
  [[ -n "${_optional:-}" ]] && OPTIONAL_PLUGINS="$_optional"

  read -r -p "$(i18n_msg prompt_startup_tips) " _tips
  [[ -n "${_tips:-}" ]] && SHOW_STARTUP_TIPS="$_tips"

  read -r -p "$(i18n_msg prompt_set_shell) " _shell
  [[ -n "${_shell:-}" ]] && SET_DEFAULT_SHELL="$_shell"
fi

case "$INSTALL_PLUGINS" in yes|no) ;; *) log_error "--install-plugins yes|no"; exit 1 ;; esac
case "$SHOW_STARTUP_TIPS" in always|once|off) ;; *) log_error "--show-startup-tips always|once|off"; exit 1 ;; esac
case "$SET_DEFAULT_SHELL" in yes|no) ;; *) log_error "--set-default-shell yes|no"; exit 1 ;; esac

TARGET_ZDOTDIR="${ZDOTDIR:-$HOME}"
TARGET_ZSHRC="$TARGET_ZDOTDIR/.zshrc"
TARGET_ZSHENV="$TARGET_ZDOTDIR/.zshenv"

SETUP_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/zsh-ai-setup"
CONFIG_DIR="$HOME/.zsh-ai-setup/config"
STATE_FILE="$SETUP_HOME/install-state.env"
PLUGIN_MANIFEST="$SETUP_HOME/installed-plugins.txt"
STARTUP_TIP_FILE="$SETUP_HOME/startup-tip.txt"

action_overwrite="yes"
if [[ "$RUN_MODE" == "interactive" && "$FORCE" == "no" ]]; then
  if [[ -f "$TARGET_ZSHRC" ]] && ! cmp -s "$ROOT_DIR/configs/.zshrc" "$TARGET_ZSHRC"; then
    if ! confirm_yes "$(i18n_msg confirm_overwrite)" 1; then
      action_overwrite="no"
    fi
  fi
fi

if [[ "$action_overwrite" != "yes" ]]; then
  log_warn "Skip by user choice"
  exit 0
fi

if [[ "$BACKUP_MODE" == "no" && "$FORCE" == "no" && "$RUN_MODE" == "non-interactive" ]]; then
  if [[ -f "$TARGET_ZSHRC" || -f "$TARGET_ZSHENV" ]]; then
    log_error "In non-interactive mode, use --backup yes or --force"
    exit 1
  fi
fi

if [[ "$DRY_RUN" != "yes" ]]; then
  ensure_dir "$SETUP_HOME"
  ensure_dir "$CONFIG_DIR"
fi

ensure_zsh_installed "$DRY_RUN"
ensure_oh_my_zsh "$DRY_RUN" "$STATE_FILE"

for target in "$TARGET_ZSHRC" "$TARGET_ZSHENV"; do
  if [[ -f "$target" ]]; then
    bfile="$(backup_file_if_exists "$target" "$BACKUP_MODE" "$DRY_RUN")"
    [[ -n "${bfile:-}" ]] && log_info "$(i18n_msg backup_done): $bfile"
  fi
done

copy_with_log() {
  local src="$1"
  local dst="$2"
  if copy_if_changed "$src" "$dst" "$DRY_RUN"; then
    if [[ "$DRY_RUN" == "yes" ]]; then
      log_info "PLAN: $dst"
    else
      log_info "$(i18n_msg write_done): $dst"
    fi
  else
    if [[ $? -eq 10 ]]; then
      log_info "$(i18n_msg write_skip): $dst"
    else
      return 1
    fi
  fi
}

copy_with_log "$ROOT_DIR/configs/.zshrc" "$TARGET_ZSHRC"
copy_with_log "$ROOT_DIR/configs/.zshenv" "$TARGET_ZSHENV"
copy_with_log "$ROOT_DIR/configs/aliases.zsh" "$CONFIG_DIR/aliases.zsh"
copy_with_log "$ROOT_DIR/configs/exports.zsh" "$CONFIG_DIR/exports.zsh"
copy_with_log "$ROOT_DIR/configs/plugins.zsh" "$CONFIG_DIR/plugins.zsh"

if [[ "$DRY_RUN" != "yes" ]]; then
  local_tip_template="$ROOT_DIR/templates/startup-tip.${I18N_LANG}.txt"
  if [[ "$I18N_LANG" == "zh" ]]; then
    local_tip_template="$ROOT_DIR/templates/startup-tip.zh-CN.txt"
  fi
  if [[ ! -f "$local_tip_template" ]]; then
    local_tip_template="$ROOT_DIR/templates/startup-tip.en.txt"
  fi
  cp -a "$local_tip_template" "$STARTUP_TIP_FILE"

  cat > "$SETUP_HOME/config.env" <<ENV
export ZSH_AI_LANG="$I18N_LANG"
export ZSH_AI_SETUP_HOME="$SETUP_HOME"
export ZSH_AI_CONFIG_DIR="$CONFIG_DIR"
export ZSH_AI_STARTUP_TIP_MODE="$SHOW_STARTUP_TIPS"
export ZSH_AI_STARTUP_TIP_FILE="$STARTUP_TIP_FILE"
ENV

  cat > "$STATE_FILE" <<STATE
ZSH_AI_SETUP_INSTALLED=yes
ZSH_AI_SETUP_SOURCE=$ROOT_DIR
ZSH_AI_SETUP_INSTALLED_AT=$(date -u +%Y-%m-%dT%H:%M:%SZ)
ZSH_AI_STARTUP_TIPS=$SHOW_STARTUP_TIPS
STATE
fi

install_plugins "$INSTALL_PLUGINS" "$OPTIONAL_PLUGINS" "$DRY_RUN" "$FORCE" "$PLUGIN_MANIFEST"
try_set_default_shell "$SET_DEFAULT_SHELL" "$DRY_RUN"

if [[ "$DRY_RUN" != "yes" ]]; then
  zsh -n "$TARGET_ZSHRC"
  zsh -n "$TARGET_ZSHENV"
fi

log_info "$(i18n_msg verify_title)"
log_info "  echo \$SHELL"
log_info "  zsh --version"
log_info "  test -d \"\${ZSH_CUSTOM:-\$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions\""
log_info "  test -f \"$TARGET_ZSHRC\""
log_info "  $(i18n_msg verify_new_terminal)"
log_info "$(i18n_msg install_success)"
