#!/usr/bin/env bash

log_info() { printf '[INFO] %s\n' "$*"; }
log_warn() { printf '[WARN] %s\n' "$*"; }
log_error() { printf '[ERROR] %s\n' "$*" >&2; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

confirm_yes() {
  local prompt="$1"
  local default_no="${2:-1}"
  local ans
  if (( default_no == 1 )); then
    read -r -p "$prompt [y/N] " ans
  else
    read -r -p "$prompt [Y/n] " ans
  fi
  case "$ans" in
    y|Y|yes|YES) return 0 ;;
    *)
      if [[ -z "$ans" && "$default_no" == "0" ]]; then
        return 0
      fi
      return 1
      ;;
  esac
}

ensure_dir() {
  mkdir -p "$1"
}

backup_file_if_exists() {
  local src="$1"
  local enable_backup="$2"
  local dry_run="$3"

  [[ -e "$src" ]] || return 0
  [[ "$enable_backup" == "yes" ]] || return 0

  local day suffix backup
  day="$(date +%Y%m%d)"
  suffix="$(printf '%04x' "$((RANDOM % 65536))")"
  backup="${src}.backup-${day}-${suffix}"

  if [[ "$dry_run" == "yes" ]]; then
    printf '%s\n' "$backup"
    return 0
  fi

  cp -a "$src" "$backup"
  printf '%s\n' "$backup"
}

copy_if_changed() {
  local src="$1"
  local dst="$2"
  local dry_run="$3"

  if [[ -f "$dst" ]] && cmp -s "$src" "$dst"; then
    return 10
  fi
  if [[ "$dry_run" == "yes" ]]; then
    return 0
  fi
  cp -a "$src" "$dst"
  return 0
}

write_text_file() {
  local dst="$1"
  local text="$2"
  local dry_run="$3"
  if [[ "$dry_run" == "yes" ]]; then
    return 0
  fi
  printf '%s\n' "$text" > "$dst"
}

append_manifest_line() {
  local manifest="$1"
  local line="$2"
  local dry_run="$3"
  [[ "$dry_run" == "yes" ]] && return 0
  touch "$manifest"
  if ! grep -Fx -- "$line" "$manifest" >/dev/null 2>&1; then
    printf '%s\n' "$line" >> "$manifest"
  fi
}
