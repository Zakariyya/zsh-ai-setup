#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/i18n.sh"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/lib.sh"

LANG_OPT="auto"
RUN_MODE=""
RESTORE_BACKUP="yes"
DRY_RUN="no"
FORCE="no"

usage() {
  cat <<USAGE
Usage: ./uninstall.sh [options]

Options:
  --lang zh|en
  --interactive
  --non-interactive
  --restore-backup yes|no
  --dry-run
  --force
  -h, --help
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --lang) LANG_OPT="${2:-}"; shift 2 ;;
    --interactive) RUN_MODE="interactive"; shift ;;
    --non-interactive) RUN_MODE="non-interactive"; shift ;;
    --restore-backup) RESTORE_BACKUP="${2:-}"; shift 2 ;;
    --dry-run) DRY_RUN="yes"; shift ;;
    --force) FORCE="yes"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1" >&2; usage >&2; exit 1 ;;
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
log_info "$(i18n_msg uninstall_welcome)"

TARGET_ZDOTDIR="${ZDOTDIR:-$HOME}"
TARGET_ZSHRC="$TARGET_ZDOTDIR/.zshrc"
TARGET_ZSHENV="$TARGET_ZDOTDIR/.zshenv"
SETUP_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/zsh-ai-setup"
CONFIG_DIR="$HOME/.zsh-ai-setup/config"
PLUGIN_MANIFEST="$SETUP_HOME/installed-plugins.txt"

if [[ "$RUN_MODE" == "interactive" && "$FORCE" == "no" ]]; then
  if ! confirm_yes "Continue uninstall?" 1; then
    exit 0
  fi
fi

restore_latest_backup() {
  local target="$1"
  local latest
  latest="$(ls -1t "${target}.backup-"* 2>/dev/null | head -n 1 || true)"
  if [[ -z "$latest" ]]; then
    log_warn "$(i18n_msg restore_missing): $target"
    return 0
  fi
  if [[ "$DRY_RUN" == "yes" ]]; then
    log_info "RESTORE PLAN: $target <= $latest"
    return 0
  fi
  cp -a "$latest" "$target"
  log_info "$(i18n_msg restore_done): $target <= $latest"
}

if [[ "$RESTORE_BACKUP" == "yes" ]]; then
  restore_latest_backup "$TARGET_ZSHRC"
  restore_latest_backup "$TARGET_ZSHENV"
fi

if [[ -f "$PLUGIN_MANIFEST" ]]; then
  while IFS= read -r pdir; do
    [[ -n "$pdir" ]] || continue
    if [[ -f "$pdir/.zsh-ai-setup-managed" ]]; then
      if [[ "$DRY_RUN" == "yes" ]]; then
        log_info "REMOVE PLAN: $pdir"
      else
        rm -rf "$pdir"
        log_info "$(i18n_msg removed_path): $pdir"
      fi
    fi
  done < "$PLUGIN_MANIFEST"
fi

for p in "$CONFIG_DIR" "$SETUP_HOME/config.env" "$SETUP_HOME/startup-tip.txt" "$SETUP_HOME/startup-tip.state" "$SETUP_HOME/install-state.env" "$SETUP_HOME/installed-plugins.txt"; do
  if [[ -e "$p" ]]; then
    if [[ "$DRY_RUN" == "yes" ]]; then
      log_info "REMOVE PLAN: $p"
    else
      rm -rf "$p"
      log_info "$(i18n_msg removed_path): $p"
    fi
  fi
done

log_info "$(i18n_msg uninstall_success)"
