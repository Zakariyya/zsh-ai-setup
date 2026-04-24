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
    uninstall.sh \
    scripts/i18n.sh \
    scripts/lib.sh \
    scripts/detect_os.sh \
    scripts/install_zsh.sh \
    scripts/install_thefuck.sh \
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
source "$ROOT_DIR/scripts/install_thefuck.sh"
# shellcheck disable=SC1091
source "$ROOT_DIR/scripts/install_plugins.sh"

LANG_OPT="auto"
RUN_MODE=""
INSTALL_PLUGINS="yes"
SHOW_STARTUP_TIPS="always"
SET_DEFAULT_SHELL="yes"
BACKUP_MODE="yes"
DRY_RUN="no"
FORCE="no"
OPTIONAL_PLUGINS=""
SEEN_INSTALL_PLUGINS="no"
SEEN_SHOW_STARTUP_TIPS="no"
SEEN_SET_DEFAULT_SHELL="no"
SEEN_BACKUP="no"
SEEN_OPTIONAL_PLUGINS="no"
SEEN_DRY_RUN="no"
SEEN_FORCE="no"

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
  --optional-plugins p1/p2
  --dry-run
  --force
  -h, --help
USAGE
}

PROMPT_FD=""

stage_banner() {
  local title="$1"
  log_info "----------------------------------------"
  log_info "$title"
}

detect_prompt_fd() {
  local fd
  if [[ -n "${PROMPT_FD:-}" ]]; then
    return 0
  fi

  if [[ -t 0 ]]; then
    PROMPT_FD="0"
    return 0
  fi

  if exec {fd}<>/dev/tty 2>/dev/null; then
    PROMPT_FD="$fd"
    return 0
  fi

  PROMPT_FD="0"
  return 1
}

has_prompt_tty() {
  detect_prompt_fd >/dev/null 2>&1 || true
  [[ "${PROMPT_FD:-0}" != "0" || -t 0 ]]
}

print_prompt_line() {
  local text="$1"
  detect_prompt_fd >/dev/null 2>&1 || true
  if [[ "${PROMPT_FD:-0}" != "0" ]]; then
    printf '%s\n' "$text" >&"$PROMPT_FD"
  else
    printf '%s\n' "$text"
  fi
}

read_interactive() {
  local prompt="$1"
  local __resultvar="$2"
  local answer=""
  detect_prompt_fd >/dev/null 2>&1 || true
  if [[ "${PROMPT_FD:-0}" != "0" ]]; then
    read -r -u "$PROMPT_FD" -p "$prompt" answer || answer=""
  else
    read -r -p "$prompt" answer || answer=""
  fi
  printf -v "$__resultvar" '%s' "$answer"
}

normalize_lang_input() {
  case "${1,,}" in
    1|zh|zh-cn|cn|chinese|中文) echo "zh" ;;
    2|en|en-us|english) echo "en" ;;
    *) echo "" ;;
  esac
}

normalize_yes_no_input() {
  case "${1,,}" in
    1|yes|y|是) echo "yes" ;;
    2|no|n|否) echo "no" ;;
    *) echo "" ;;
  esac
}

normalize_startup_tips_input() {
  case "${1,,}" in
    1|always|总是) echo "always" ;;
    2|once|首次|仅首次) echo "once" ;;
    3|off|关闭) echo "off" ;;
    *) echo "" ;;
  esac
}

join_by_comma() {
  local oldifs="$IFS"
  IFS=','
  printf '%s' "$*"
  IFS="$oldifs"
}

optional_plugin_desc() {
  local plugin="$1"
  local key
  key="${plugin//-/_}"
  i18n_msg "plugin_desc_${key}"
}

parse_optional_plugins_input() {
  local raw="$1"
  local -n out_arr="$2"
  local -a parsed=()
  local token trimmed idx plugin
  local oldifs="$IFS"

  out_arr=()
  raw="${raw// /}"
  raw="${raw//，/,}"
  raw="${raw//,/\/}"
  [[ -n "$raw" ]] || return 0

  case "${raw,,}" in
    n|no|none|skip|不安装|跳过)
      out_arr=()
      return 0
      ;;
    0|1|all|全部)
      out_arr=("${ZSH_AI_OPTIONAL_EXTERNAL_PLUGINS[@]}")
      return 0
      ;;
  esac

  IFS='/'
  read -r -a tokens <<< "$raw"
  IFS="$oldifs"

  for token in "${tokens[@]}"; do
    trimmed="${token// /}"
    [[ -n "$trimmed" ]] || continue
    if [[ "$trimmed" =~ ^[0-9]+$ ]]; then
      idx=$((trimmed - 2))
      if (( idx < 0 || idx >= ${#ZSH_AI_OPTIONAL_EXTERNAL_PLUGINS[@]} )); then
        return 1
      fi
      parsed+=("${ZSH_AI_OPTIONAL_EXTERNAL_PLUGINS[$idx]}")
    else
      plugin="$trimmed"
      if [[ -z "${ZSH_AI_PLUGIN_REPO[$plugin]:-}" ]]; then
        return 1
      fi
      parsed+=("$plugin")
    fi
  done

  # unique, preserve order
  local seen=","
  for plugin in "${parsed[@]}"; do
    if [[ "$seen" != *",$plugin,"* ]]; then
      seen+="$plugin,"
      out_arr+=("$plugin")
    fi
  done
  return 0
}

status_installed_label() {
  if [[ "$I18N_LANG" == "zh" ]]; then
    printf '已安装'
  else
    printf 'installed'
  fi
}

status_not_installed_label() {
  if [[ "$I18N_LANG" == "zh" ]]; then
    printf '未安装'
  else
    printf 'not installed'
  fi
}

build_plugin_status_text() {
  local -n list_ref="$1"
  local plugin_root p state
  local sep status_text=""
  if [[ "$I18N_LANG" == "zh" ]]; then
    sep='，'
    status_text='（'
  else
    sep=', '
    status_text='('
  fi

  plugin_root="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
  for p in "${list_ref[@]}"; do
    if [[ "$p" == "thefuck" ]]; then
      if command -v thefuck >/dev/null 2>&1; then
        state="$(status_installed_label)"
      else
        state="$(status_not_installed_label)"
      fi
    elif [[ -d "$plugin_root/$p/.git" ]]; then
      state="$(status_installed_label)"
    else
      state="$(status_not_installed_label)"
    fi
    if [[ "$status_text" != "（" && "$status_text" != "(" ]]; then
      status_text+="$sep"
    fi
    status_text+="$p:$state"
  done

  if [[ "$I18N_LANG" == "zh" ]]; then
    status_text+='）'
  else
    status_text+=')'
  fi
  printf '%s' "$status_text"
}

build_thefuck_status_text() {
  if command -v thefuck >/dev/null 2>&1; then
    status_installed_label
  else
    status_not_installed_label
  fi
}

render_startup_tip_file() {
  local template="$1"
  local dst="$2"
  local install_script_abs="$3"
  local required_status optional_status thefuck_status

  required_status="$(build_plugin_status_text ZSH_AI_REQUIRED_EXTERNAL_PLUGINS)"
  optional_status="$(build_plugin_status_text ZSH_AI_OPTIONAL_EXTERNAL_PLUGINS)"
  thefuck_status="$(build_thefuck_status_text)"

  sed \
    -e "s|__INSTALL_SCRIPT__|$install_script_abs|g" \
    -e "s|__REQUIRED_PLUGIN_STATUS__|$required_status|g" \
    -e "s|__OPTIONAL_PLUGIN_STATUS__|$optional_status|g" \
    -e "s|__THEFUCK_STATUS__|$thefuck_status|g" \
    "$template" > "$dst"
}

is_startup_tip_mode_only_update() {
  [[ "$SEEN_SHOW_STARTUP_TIPS" == "yes" ]] || return 1
  [[ "$SEEN_INSTALL_PLUGINS" == "no" ]] || return 1
  [[ "$SEEN_SET_DEFAULT_SHELL" == "no" ]] || return 1
  [[ "$SEEN_BACKUP" == "no" ]] || return 1
  [[ "$SEEN_OPTIONAL_PLUGINS" == "no" ]] || return 1
  [[ "$SEEN_DRY_RUN" == "no" ]] || return 1
  [[ "$SEEN_FORCE" == "no" ]] || return 1
  return 0
}

update_startup_tip_mode_only() {
  local setup_home config_env state_file
  local current_lang current_config_dir current_install_script current_tip_file

  setup_home="${XDG_CONFIG_HOME:-$HOME/.config}/zsh-ai-setup"
  config_env="$setup_home/config.env"
  state_file="$setup_home/startup-tip.state"

  current_lang="$I18N_LANG"
  current_config_dir="$HOME/.zsh-ai-setup/config"
  current_install_script="$HOME/.zsh-ai-setup/installer/install.sh"
  current_tip_file="$setup_home/startup-tip.txt"

  if [[ -f "$config_env" ]]; then
    # shellcheck disable=SC1090
    source "$config_env"
    current_lang="${ZSH_AI_LANG:-$current_lang}"
    current_config_dir="${ZSH_AI_CONFIG_DIR:-$current_config_dir}"
    current_install_script="${ZSH_AI_INSTALL_SCRIPT:-$current_install_script}"
    current_tip_file="${ZSH_AI_STARTUP_TIP_FILE:-$current_tip_file}"
  fi

  ensure_dir "$setup_home"
  cat > "$config_env" <<ENV
export ZSH_AI_LANG="$current_lang"
export ZSH_AI_SETUP_HOME="$setup_home"
export ZSH_AI_CONFIG_DIR="$current_config_dir"
export ZSH_AI_INSTALL_SCRIPT="$current_install_script"
export ZSH_AI_STARTUP_TIP_MODE="$SHOW_STARTUP_TIPS"
export ZSH_AI_STARTUP_TIP_FILE="$current_tip_file"
ENV

  if [[ "$SHOW_STARTUP_TIPS" == "once" ]]; then
    rm -f "$state_file"
  fi

  log_info "$(i18n_msg startup_tip_mode_updated)"
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
      INSTALL_PLUGINS="${2:-}"; SEEN_INSTALL_PLUGINS="yes"; shift 2 ;;
    --show-startup-tips)
      SHOW_STARTUP_TIPS="${2:-}"; SEEN_SHOW_STARTUP_TIPS="yes"; shift 2 ;;
    --set-default-shell)
      SET_DEFAULT_SHELL="${2:-}"; SEEN_SET_DEFAULT_SHELL="yes"; shift 2 ;;
    --backup)
      BACKUP_MODE="${2:-}"; SEEN_BACKUP="yes"; shift 2 ;;
    --optional-plugins)
      OPTIONAL_PLUGINS="${2:-}"; SEEN_OPTIONAL_PLUGINS="yes"; shift 2 ;;
    --dry-run)
      DRY_RUN="yes"; SEEN_DRY_RUN="yes"; shift ;;
    --force)
      FORCE="yes"; SEEN_FORCE="yes"; shift ;;
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
  if [[ -t 0 || has_prompt_tty ]]; then
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

if is_startup_tip_mode_only_update; then
  update_startup_tip_mode_only
  exit 0
fi

if [[ "$DRY_RUN" == "yes" ]]; then
  log_info "$(i18n_msg dry_run)"
fi

if [[ "$RUN_MODE" == "interactive" ]]; then
  stage_banner "$(i18n_msg stage_questions)"
  _lang=""
  _norm_lang=""
  _plugins=""
  _norm_plugins=""
  _optional=""
  _tips=""
  _norm_tips=""
  _shell=""
  _norm_shell=""
  declare -a _selected_optional=()

  read_interactive "$(i18n_msg prompt_lang): " _lang
  _norm_lang="$(normalize_lang_input "${_lang:-}")"
  if [[ -n "$_norm_lang" ]]; then
    set_i18n_lang "$_norm_lang"
  elif [[ -n "${_lang:-}" ]]; then
    set_i18n_lang "$_lang"
  fi

  print_prompt_line ""
  read_interactive "$(i18n_msg prompt_install_plugins) " _plugins
  _norm_plugins="$(normalize_yes_no_input "${_plugins:-}")"
  if [[ -n "$_norm_plugins" ]]; then
    INSTALL_PLUGINS="$_norm_plugins"
  elif [[ -z "${_plugins:-}" ]]; then
    INSTALL_PLUGINS="yes"
  fi

  if [[ "$INSTALL_PLUGINS" == "yes" ]]; then
    print_prompt_line ""
    print_prompt_line "$(i18n_msg optional_plugins_title):"
    print_prompt_line "  $(i18n_msg optional_plugins_all)"
    for i in "${!ZSH_AI_OPTIONAL_EXTERNAL_PLUGINS[@]}"; do
      plugin="${ZSH_AI_OPTIONAL_EXTERNAL_PLUGINS[$i]}"
      desc="$(optional_plugin_desc "$plugin")"
      print_prompt_line "  $((i + 2))) $plugin - $desc"
    done
    print_prompt_line "  $(i18n_msg optional_plugins_none)"

    read_interactive "$(i18n_msg prompt_optional_plugins) " _optional
    if [[ -z "${_optional:-}" ]]; then
      _selected_optional=("${ZSH_AI_OPTIONAL_EXTERNAL_PLUGINS[@]}")
      OPTIONAL_PLUGINS="$(join_by_comma "${_selected_optional[@]}")"
    elif parse_optional_plugins_input "$_optional" _selected_optional; then
      OPTIONAL_PLUGINS="$(join_by_comma "${_selected_optional[@]}")"
    else
      log_error "$(i18n_msg err_arg): --optional-plugins"
      exit 1
    fi
  fi

  print_prompt_line ""
  read_interactive "$(i18n_msg prompt_startup_tips) " _tips
  _norm_tips="$(normalize_startup_tips_input "${_tips:-}")"
  if [[ -n "$_norm_tips" ]]; then
    SHOW_STARTUP_TIPS="$_norm_tips"
  elif [[ -z "${_tips:-}" ]]; then
    SHOW_STARTUP_TIPS="always"
  elif [[ -n "${_tips:-}" ]]; then
    SHOW_STARTUP_TIPS="$_tips"
  fi

  print_prompt_line ""
  read_interactive "$(i18n_msg prompt_set_shell) " _shell
  _norm_shell="$(normalize_yes_no_input "${_shell:-}")"
  if [[ -n "$_norm_shell" ]]; then
    SET_DEFAULT_SHELL="$_norm_shell"
  elif [[ -z "${_shell:-}" ]]; then
    SET_DEFAULT_SHELL="yes"
  elif [[ -n "${_shell:-}" ]]; then
    SET_DEFAULT_SHELL="$_shell"
  fi
fi

case "$INSTALL_PLUGINS" in yes|no) ;; *) log_error "--install-plugins yes|no"; exit 1 ;; esac
case "$SHOW_STARTUP_TIPS" in always|once|off) ;; *) log_error "--show-startup-tips always|once|off"; exit 1 ;; esac
case "$SET_DEFAULT_SHELL" in yes|no) ;; *) log_error "--set-default-shell yes|no"; exit 1 ;; esac

TARGET_ZDOTDIR="${ZDOTDIR:-$HOME}"
TARGET_ZSHRC="$TARGET_ZDOTDIR/.zshrc"
TARGET_ZSHENV="$TARGET_ZDOTDIR/.zshenv"

SETUP_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/zsh-ai-setup"
CONFIG_DIR="$HOME/.zsh-ai-setup/config"
INSTALLER_DIR="$HOME/.zsh-ai-setup/installer"
INSTALLER_SCRIPT="$INSTALLER_DIR/install.sh"
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
  ensure_dir "$INSTALLER_DIR"
  ensure_dir "$INSTALLER_DIR/scripts"
  ensure_dir "$INSTALLER_DIR/configs"
  ensure_dir "$INSTALLER_DIR/templates"
fi

stage_banner "$(i18n_msg stage_prepare)"
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
copy_with_log "$ROOT_DIR/install.sh" "$INSTALLER_DIR/install.sh"
copy_with_log "$ROOT_DIR/uninstall.sh" "$INSTALLER_DIR/uninstall.sh"
copy_with_log "$ROOT_DIR/scripts/i18n.sh" "$INSTALLER_DIR/scripts/i18n.sh"
copy_with_log "$ROOT_DIR/scripts/lib.sh" "$INSTALLER_DIR/scripts/lib.sh"
copy_with_log "$ROOT_DIR/scripts/detect_os.sh" "$INSTALLER_DIR/scripts/detect_os.sh"
copy_with_log "$ROOT_DIR/scripts/install_zsh.sh" "$INSTALLER_DIR/scripts/install_zsh.sh"
copy_with_log "$ROOT_DIR/scripts/install_thefuck.sh" "$INSTALLER_DIR/scripts/install_thefuck.sh"
copy_with_log "$ROOT_DIR/scripts/install_plugins.sh" "$INSTALLER_DIR/scripts/install_plugins.sh"
copy_with_log "$ROOT_DIR/configs/.zshrc" "$INSTALLER_DIR/configs/.zshrc"
copy_with_log "$ROOT_DIR/configs/.zshenv" "$INSTALLER_DIR/configs/.zshenv"
copy_with_log "$ROOT_DIR/configs/aliases.zsh" "$INSTALLER_DIR/configs/aliases.zsh"
copy_with_log "$ROOT_DIR/configs/exports.zsh" "$INSTALLER_DIR/configs/exports.zsh"
copy_with_log "$ROOT_DIR/configs/plugins.zsh" "$INSTALLER_DIR/configs/plugins.zsh"
copy_with_log "$ROOT_DIR/templates/startup-tip.en.txt" "$INSTALLER_DIR/templates/startup-tip.en.txt"
copy_with_log "$ROOT_DIR/templates/startup-tip.zh-CN.txt" "$INSTALLER_DIR/templates/startup-tip.zh-CN.txt"

if [[ "$DRY_RUN" != "yes" ]]; then
  local_tip_template="$ROOT_DIR/templates/startup-tip.${I18N_LANG}.txt"
  if [[ "$I18N_LANG" == "zh" ]]; then
    local_tip_template="$ROOT_DIR/templates/startup-tip.zh-CN.txt"
  fi
  if [[ ! -f "$local_tip_template" ]]; then
    local_tip_template="$ROOT_DIR/templates/startup-tip.en.txt"
  fi

  cat > "$SETUP_HOME/config.env" <<ENV
export ZSH_AI_LANG="$I18N_LANG"
export ZSH_AI_SETUP_HOME="$SETUP_HOME"
export ZSH_AI_CONFIG_DIR="$CONFIG_DIR"
export ZSH_AI_INSTALL_SCRIPT="$INSTALLER_SCRIPT"
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

stage_banner "$(i18n_msg stage_plugins)"
install_plugins "$INSTALL_PLUGINS" "$OPTIONAL_PLUGINS" "$DRY_RUN" "$FORCE" "$PLUGIN_MANIFEST"
if [[ "$DRY_RUN" != "yes" ]]; then
  render_startup_tip_file "$local_tip_template" "$STARTUP_TIP_FILE" "$INSTALLER_SCRIPT"
fi

stage_banner "$(i18n_msg stage_finalize)"
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
