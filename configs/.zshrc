# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Optional setup-level overrides (managed by zsh-ai-setup installer).
typeset -g ZSH_AI_SETUP_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/zsh-ai-setup"
typeset -g ZSH_AI_SETUP_ENV_FILE="${ZSH_AI_SETUP_HOME}/config.env"
if [[ -f "$ZSH_AI_SETUP_ENV_FILE" ]]; then
  source "$ZSH_AI_SETUP_ENV_FILE"
fi
typeset -g ZSH_AI_CONFIG_DIR="${ZSH_AI_CONFIG_DIR:-$HOME/.zsh-ai-setup/config}"
if [[ -f "$ZSH_AI_CONFIG_DIR/exports.zsh" ]]; then
  source "$ZSH_AI_CONFIG_DIR/exports.zsh"
fi

# Theme: beginner-friendly, no extra fonts required.
ZSH_THEME="robbyrussell"

# Plugins from issue + keyboard efficiency helpers.
if [[ -f "$ZSH_AI_CONFIG_DIR/plugins.zsh" ]]; then
  source "$ZSH_AI_CONFIG_DIR/plugins.zsh"
fi
if (( ${#plugins[@]} == 0 )); then
  plugins=(
    git
    z
    sudo
    history-substring-search
    zsh-autosuggestions
    zsh-syntax-highlighting
  )
fi

# History behavior: bigger, shared across sessions, less duplicates.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY

# Usability options.
setopt AUTO_CD
setopt INTERACTIVE_COMMENTS
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Keep PATH unique and deterministic.
typeset -U path PATH

# Environment migrated from ~/.bashrc
export NVM_DIR="$HOME/.nvm"
# Lazy-load nvm on first use of nvm/node/npm/npx.
_zsh_lazy_load_nvm() {
  emulate -L zsh
  if [[ -n "${ZSHRC_NVM_INIT_DONE:-}" ]]; then
    return 0
  fi
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
  typeset -g ZSHRC_NVM_INIT_DONE=1
}
for _zsh_nvm_cmd in nvm node npm npx; do
  unalias "${_zsh_nvm_cmd}" 2>/dev/null || true
  eval "
  ${_zsh_nvm_cmd}() {
    unset -f nvm node npm npx
    _zsh_lazy_load_nvm
    ${_zsh_nvm_cmd} \"\$@\"
  }"
done
unset _zsh_nvm_cmd

# Ensure nvm-installed codex stays callable even before nvm is lazy-loaded.
if [[ -d "$NVM_DIR/versions/node" ]]; then
  _zsh_nvm_codex_bin=""
  for _zsh_nvm_bin in "$NVM_DIR"/versions/node/*/bin; do
    [[ -d "$_zsh_nvm_bin" ]] || continue
    if [[ -x "$_zsh_nvm_bin/codex" ]]; then
      _zsh_nvm_codex_bin="$_zsh_nvm_bin"
    fi
  done
  if [[ -n "$_zsh_nvm_codex_bin" ]]; then
    path=("$_zsh_nvm_codex_bin" $path)
  fi
  unset _zsh_nvm_bin _zsh_nvm_codex_bin
fi

export BUN_INSTALL="$HOME/.bun"
if [[ -n "${ZSH_AI_JAVA_HOME:-}" ]]; then
  export JAVA_HOME="$ZSH_AI_JAVA_HOME"
elif [[ -d "$HOME/app/jdk-24.0.2" ]]; then
  export JAVA_HOME="$HOME/app/jdk-24.0.2"
fi
if [[ -n "${ZSH_AI_GRADLE_HOME:-}" ]]; then
  export GRADLE_HOME="$ZSH_AI_GRADLE_HOME"
elif [[ -d "$HOME/app/gradle-9.0.0" ]]; then
  export GRADLE_HOME="$HOME/app/gradle-9.0.0"
fi

# Path order: user/tooling bins first.
path=(
  "$HOME/.local/bin"
  "$HOME/.local/go/bin"
  "$HOME/android-sdk/platform-tools"
  "$BUN_INSTALL/bin"
  "${JAVA_HOME:+$JAVA_HOME/bin}"
  "${GRADLE_HOME:+$GRADLE_HOME/bin}"
  "$HOME/bin"
  $path
)
export PATH

# Base aliases from ~/.bashrc
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias d='dirs -v'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
if [[ -f "$ZSH_AI_CONFIG_DIR/aliases.zsh" ]]; then
  source "$ZSH_AI_CONFIG_DIR/aliases.zsh"
fi

# Completion
zmodload zsh/complist
autoload -Uz compinit
# Use compinit cache for faster startup.
if [[ -n "${ZDOTDIR:-}" ]]; then
  _zcomp_dump="${ZDOTDIR}/.zcompdump"
else
  _zcomp_dump="${HOME}/.zcompdump"
fi
if (( ! ${+_comps} )); then
  if [[ -n "$_zcomp_dump" && -s "$_zcomp_dump" && -n "$(find "$_zcomp_dump" -mtime -1 2>/dev/null)" ]]; then
    compinit -C -d "$_zcomp_dump"
  else
    compinit -d "$_zcomp_dump"
  fi
fi
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Keyboard-focused keybindings
bindkey -e
# Cleanup legacy split/multiplexer bindings from older zshrc versions.
for _zsh_map in emacs viins vicmd; do
  bindkey -M "$_zsh_map" -r '^[s' 2>/dev/null || true
  bindkey -M "$_zsh_map" -r '^[S' 2>/dev/null || true
done
bindkey -r '^[s' 2>/dev/null || true
bindkey -r '^[S' 2>/dev/null || true
unalias ts 2>/dev/null || true
unalias ta 2>/dev/null || true
unset -f ts_debug _zsh_mux_attach_main _zsh_zellij_split_dir _zsh_mux_split_now _zsh_mux_split_widget 2>/dev/null || true
unset _zsh_map
# Home / End (common terminal sequences)
bindkey '^[[1~' beginning-of-line
bindkey '^[[H' beginning-of-line
bindkey '^[OH' beginning-of-line
bindkey '^[[4~' end-of-line
bindkey '^[[F' end-of-line
bindkey '^[OF' end-of-line
# Ctrl+Left / Ctrl+Right move by word
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

if [[ -z "${ZSHRC_OMZ_INIT_DONE:-}" ]]; then
  source "$ZSH/oh-my-zsh.sh"
  typeset -g ZSHRC_OMZ_INIT_DONE=1
fi

# Completion behavior override (must be after Oh My Zsh init, otherwise it may
# be overridden by plugin defaults).
# _complete: normal completion first
# _correct/_approximate: spelling correction fallback on Tab
zstyle ':completion:*' completer _complete _correct _approximate
zstyle ':completion:*:approximate:*' max-errors 2 numeric

# Command-not-found helper:
# keep default behavior, but add a fast, explicit fix hint.
command_not_found_handler() {
  emulate -L zsh
  typeset -g _ZSH_LAST_FAILED_CMD="$*"
  print -u2 "zsh: command not found: $1"
  if [[ -o interactive ]] && (( ! ${ZSH_FUCK_USE_ORIGINAL:-0} )) && typeset -f _thefuck_apply_safe >/dev/null 2>&1; then
    if _thefuck_apply_safe --auto-one "$@"; then
      return 0
    fi
  fi
  print -u2 "hint: press Alt+f to run fuck (safe quick-fix)"
  return 127
}

# fzf integration (installed under ~/.local).
if [[ -f "$HOME/.fzf.zsh" && -t 0 && -t 1 ]]; then
  if [[ -z "${ZSHRC_FZF_INIT_DONE:-}" ]]; then
    source "$HOME/.fzf.zsh"
    typeset -g ZSHRC_FZF_INIT_DONE=1
  fi
fi

# direnv integration: auto load/unload env per directory via .envrc.
if command -v direnv >/dev/null 2>&1; then
  if [[ -z "${ZSHRC_DIRENV_INIT_DONE:-}" ]]; then
    eval "$(direnv hook zsh)"
    typeset -g ZSHRC_DIRENV_INIT_DONE=1
  fi
fi

# thefuck integration: typo correction helper via `fuck`.
# Keep stable mode by default. Instant mode is available but can conflict with
# some terminals/hook combinations.
typeset -g ZSH_THEFUCK_INSTANT_MODE=0
typeset -g ZSH_FUCK_USE_ORIGINAL=1
if command -v thefuck >/dev/null 2>&1; then
  if [[ -z "${ZSHRC_THEFUCK_ALIAS_INIT_DONE:-}" ]]; then
    if [[ -t 0 && -t 1 && ZSH_THEFUCK_INSTANT_MODE -eq 1 ]]; then
      eval "$(thefuck --alias --enable-experimental-instant-mode)"
    else
      eval "$(thefuck --alias)"
    fi
    typeset -g ZSHRC_THEFUCK_ALIAS_INIT_DONE=1
  fi

  # Unified typo-fix entrypoint used by both `fuck` and `fk`.
  # Behavior:
  # - one suggestion: auto-apply
  # - multiple suggestions: ask user to choose
  # - dangerous suggestions: require explicit confirmation
  _thefuck_apply_safe() {
    emulate -L zsh
    local mode_auto_one=0
    if [[ "$1" == "--auto-one" ]]; then
      mode_auto_one=1
      shift
    fi

    local tf_cmd=""
    local -a tf_args
    tf_args=("$@")
    # Always correct the most recent executed command when user runs bare `fuck`.
    # This avoids picking unrelated history context and producing wrong fixes.
    if (( ${#tf_args[@]} == 0 )); then
      local last_raw
      if [[ -n "${_ZSH_LAST_FAILED_CMD:-}" ]]; then
        last_raw="$_ZSH_LAST_FAILED_CMD"
      else
        # fc -2 points to the command before current `fuck` invocation.
        last_raw="$(fc -ln -2 -2 2>/dev/null || true)"
      fi
      last_raw="${last_raw#"${last_raw%%[![:space:]]*}"}"
      if [[ -n "$last_raw" ]]; then
        tf_args=(${(z)last_raw})
      fi
    fi
    local tf_pythonioencoding="${PYTHONIOENCODING:-}"
    local tf_history
    tf_history="$(fc -ln -10 2>/dev/null || true)"
    export TF_SHELL=zsh
    export TF_ALIAS=fuck
    export TF_SHELL_ALIASES="$(alias)"
    export TF_HISTORY="$tf_history"
    export PYTHONIOENCODING=utf-8

    local -a tf_candidates
    tf_candidates=("${(@f)$(
      python3 - "${tf_args[@]}" <<'PY'
import sys
from thefuck.argument_parser import Parser
from thefuck.conf import settings
from thefuck import types
from thefuck.corrector import get_corrected_commands
from thefuck.entrypoints.fix_command import _get_raw_command

known = Parser().parse(['thefuck'] + sys.argv[1:])
settings.init(known)
raw = _get_raw_command(known)
if not raw:
    raise SystemExit(1)

command = types.Command.from_raw_script(raw)
for corrected in get_corrected_commands(command):
    print(corrected.script)
PY
    )}")
    # De-duplicate exact duplicate suggestions while preserving order.
    local -A _tf_seen
    local -a _tf_unique
    local _tf_item
    for _tf_item in "${tf_candidates[@]}"; do
      # Drop empty / whitespace-only candidates.
      if [[ -z "${_tf_item//[[:space:]]/}" ]]; then
        continue
      fi
      [[ -n "${_tf_seen[$_tf_item]}" ]] && continue
      _tf_seen[$_tf_item]=1
      _tf_unique+=("$_tf_item")
    done
    tf_candidates=("${_tf_unique[@]}")

    local _tf_input_head="${tf_args[1]:-}"
    local -i _tf_input_head_known=0
    if [[ -n "$_tf_input_head" ]]; then
      if (( $+commands[$_tf_input_head] )); then
        _tf_input_head_known=1
      else
        local _tf_wh
        _tf_wh="$(whence -w -- "$_tf_input_head" 2>/dev/null || true)"
        if [[ "$_tf_wh" == *": alias" || "$_tf_wh" == *": function" || "$_tf_wh" == *": builtin" || "$_tf_wh" == *": reserved" ]]; then
          _tf_input_head_known=1
        fi
      fi
    fi

    # In auto-one mode (used by command_not_found_handler), never auto-execute
    # fixes for unknown command heads. They are too risky to run blindly.
    if (( mode_auto_one == 1 && _tf_input_head_known == 0 )); then
      unset TF_HISTORY
      export PYTHONIOENCODING="$tf_pythonioencoding"
      return 1
    fi

    # If suggestions only differ in the command word and keep the exact same
    # arguments (e.g. "git add", "tic add", "gwt add"), keep only top-ranked.
    # This removes noisy typo permutations while preserving strong first choice.
    # But for unknown command fixes (e.g. "dcoerk ps"), keep all options to
    # avoid collapsing to a wrong high-frequency command head.
    if (( ${#tf_candidates[@]} > 1 && _tf_input_head_known == 1 )); then
      local _tf_tail_ref="${tf_candidates[1]}"
      _tf_tail_ref="${_tf_tail_ref#* }"
      local -i _tf_only_head_diff=1
      local _tf_candidate _tf_tail
      for _tf_candidate in "${tf_candidates[@]}"; do
        _tf_tail="${_tf_candidate#* }"
        if [[ "$_tf_tail" != "$_tf_tail_ref" ]]; then
          _tf_only_head_diff=0
          break
        fi
      done
      if (( _tf_only_head_diff == 1 )); then
        local _tf_best="${tf_candidates[1]}"
        local -i _tf_best_score=-1
        local _tf_head _tf_hist_line _tf_hist_first
        local -i _tf_score
        for _tf_candidate in "${tf_candidates[@]}"; do
          _tf_head="${_tf_candidate%% *}"
          _tf_score=0
          while IFS= read -r _tf_hist_line; do
            [[ -z "$_tf_hist_line" ]] && continue
            _tf_hist_first="${${(z)_tf_hist_line}[1]}"
            [[ "$_tf_hist_first" == "$_tf_head" ]] && (( _tf_score++ ))
          done <<< "$tf_history"
          if (( _tf_score > _tf_best_score )); then
            _tf_best_score=_tf_score
            _tf_best="$_tf_candidate"
          fi
        done
        tf_candidates=("$_tf_best")
      fi
    fi

    local tf_candidates_count=${#tf_candidates[@]}
    if (( tf_candidates_count == 0 )); then
      if (( mode_auto_one == 0 )); then
        print "No fucks given"
      fi
      unset TF_HISTORY
      export PYTHONIOENCODING="$tf_pythonioencoding"
      return 1
    elif (( tf_candidates_count == 1 )); then
      tf_cmd="${tf_candidates[1]}"
    else
      if (( mode_auto_one == 1 )); then
        unset TF_HISTORY
        export PYTHONIOENCODING="$tf_pythonioencoding"
        return 1
      fi
      print "Multiple suggestions:"
      local -i i=1
      while (( i <= tf_candidates_count )); do
        print "  $i) ${tf_candidates[$i]}"
        (( i++ ))
      done
      printf "Choose one to execute [1-%d, Enter=cancel]: " "$tf_candidates_count"
      local choice
      read -r choice
      if [[ -z "$choice" ]]; then
        unset TF_HISTORY
        export PYTHONIOENCODING="$tf_pythonioencoding"
        return 1
      fi
      if [[ ! "$choice" =~ '^[0-9]+$' ]] || (( choice < 1 || choice > tf_candidates_count )); then
        print "Invalid choice: $choice"
        unset TF_HISTORY
        export PYTHONIOENCODING="$tf_pythonioencoding"
        return 1
      fi
      tf_cmd="${tf_candidates[$choice]}"
    fi

    if [[ -z "${tf_cmd//[[:space:]]/}" ]]; then
      if (( mode_auto_one == 0 )); then
        print "No fucks given"
      fi
      unset TF_HISTORY
      export PYTHONIOENCODING="$tf_pythonioencoding"
      return 1
    fi

    local dangerous=0
    if [[ "$tf_cmd" == *"&&"* || "$tf_cmd" == *";"* || "$tf_cmd" == *"||"* ]]; then
      dangerous=1
    elif [[ "$tf_cmd" =~ '(^|[[:space:]])(sudo[[:space:]]+)?rm([[:space:]]+[^;&|]*)*[[:space:]]-rf([[:space:]]|$)' ]]; then
      dangerous=1
    elif [[ "$tf_cmd" =~ '(^|[[:space:]])git[[:space:]]+reset[[:space:]]+--hard([[:space:]]|$)' ]]; then
      dangerous=1
    elif [[ "$tf_cmd" =~ '(^|[[:space:]])git[[:space:]]+push([[:space:]]+[^;&|]*)*[[:space:]]--force(-with-lease)?([[:space:]]|$)' ]]; then
      dangerous=1
    elif [[ "$tf_cmd" =~ '(^|[[:space:]])dd[[:space:]]+if=' ]]; then
      dangerous=1
    fi

    if (( dangerous )); then
      if (( mode_auto_one == 1 )); then
        unset TF_HISTORY
        export PYTHONIOENCODING="$tf_pythonioencoding"
        return 1
      fi
      print -P "%F{yellow}thefuck suggestion (dangerous):%f $tf_cmd"
      printf "Execute this command? [y/N] "
      local reply
      read -r reply
      [[ "$reply" == [Yy] ]] || return 1
    fi

    if (( mode_auto_one == 1 )); then
      local tf_head="${tf_cmd%% *}"
      local auto_allow=0
      case "$tf_head" in
        git|git-lfs|cd|ls|pwd|cat|grep|find|mkdir|rmdir|cp|mv|rm|touch|python|python3|pip|pip3|uv|poetry|pytest|npm|pnpm|yarn|node|npx|pnpx|java|javac|gradle|./gradlew|mvn|mvnw|make|cmake|cargo|go|docker|docker-compose|kubectl|helm|kustomize|k9s|apt|apt-get|apt-cache|apt-mark|yum|dnf|pacman|brew|snap)
          auto_allow=1
          ;;
      esac
      if (( auto_allow == 0 )); then
        unset TF_HISTORY
        export PYTHONIOENCODING="$tf_pythonioencoding"
        return 1
      fi
      print -P "%F{cyan}auto-fix:%f $tf_cmd"
    fi

    eval "$tf_cmd"
    print -s -- "$tf_cmd"
    unset TF_HISTORY
    export PYTHONIOENCODING="$tf_pythonioencoding"
  }

  if (( ZSH_FUCK_USE_ORIGINAL )); then
    # Keep original thefuck behavior (interactive suggestion selection).
    unfunction fk 2>/dev/null || true
    unalias fk 2>/dev/null || true
    function fk { fuck "$@"; }
  else
    # Avoid "defining function based on alias" when re-sourcing .zshrc
    # in a shell where old aliases already exist.
    unalias fk 2>/dev/null || true
    unalias fuck 2>/dev/null || true
    function fuck { _thefuck_apply_safe "$@"; }
    function fk { _thefuck_apply_safe "$@"; }
  fi
fi

# Alt+f quick-fix: explicit user action, no auto-execution on errors.
_zsh_quick_fix_widget() {
  emulate -L zsh
  BUFFER='fuck'
  CURSOR=${#BUFFER}
  zle accept-line
}
zle -N _zsh_quick_fix_widget
bindkey '^[f' _zsh_quick_fix_widget

# Always show absolute current path in prompt.
# Keep host label short in prompt to avoid long WSL machine names.
typeset -g ZSH_AI_HOST_LABEL="${ZSH_AI_HOST_LABEL:-${HOST%%.*}}"
PROMPT="%F{green}%n@${ZSH_AI_HOST_LABEL}%f:%F{yellow}%/%f %# "

# History search optimization:
# type any text, then use Up/Down to search matching history entries.
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[OA' history-substring-search-up
bindkey '^[OB' history-substring-search-down

# Show key aliases/functions each time a new interactive shell starts.
show_shortcuts() {
  print -P "%F{cyan}=== Zsh Shortcuts ===%f"
  print "Aliases:"
  print "  ll='ls -alF'   la='ls -A'   l='ls -CF'"
  print "  d='dirs -v'    ..='cd ..'   ...='cd ../..'   ....='cd ../../..'"
  print "  j='z'          zi='z -i'"
  print "  fuck           -> fix previous command typo (thefuck)"
  print ""
  print "Project helpers:"
  print "  run            ptest         pbuild"
  print ""
  print "Keys:"
  print "  Tab        -> Accept autosuggestion by segment"
  print "  Tab x2     -> Force native completion/menu"
  print "  Right Arrow-> Accept full autosuggestion"
  print "  Up/Down    -> history-substring-search"
  print -P "%F{cyan}=====================%f"
}
show_startup_tip() {
  emulate -L zsh
  typeset -g ZSH_AI_INSTALL_SCRIPT="${ZSH_AI_INSTALL_SCRIPT:-$HOME/.zsh-ai-setup/installer/install.sh}"
  typeset -g ZSH_AI_STARTUP_TIP_FILE="${ZSH_AI_STARTUP_TIP_FILE:-$ZSH_AI_SETUP_HOME/startup-tip.txt}"
  if [[ -f "$ZSH_AI_STARTUP_TIP_FILE" ]]; then
    command cat "$ZSH_AI_STARTUP_TIP_FILE"
  else
    show_shortcuts
  fi
}
typeset -g ZSH_AI_STARTUP_TIP_MODE="${ZSH_AI_STARTUP_TIP_MODE:-always}"
typeset -g ZSH_AI_STARTUP_TIP_STATE_FILE="${ZSH_AI_SETUP_HOME}/startup-tip.state"
mkdir -p "$ZSH_AI_SETUP_HOME" 2>/dev/null || true
case "$ZSH_AI_STARTUP_TIP_MODE" in
  off|OFF|Off|0|false|FALSE|False|no|NO|No)
    ;;
  once|ONCE|Once)
    if [[ ! -f "$ZSH_AI_STARTUP_TIP_STATE_FILE" ]]; then
      show_startup_tip
      : > "$ZSH_AI_STARTUP_TIP_STATE_FILE" 2>/dev/null || true
    fi
    ;;
  *)
    if [[ -z "${ZSHRC_SHORTCUTS_SHOWN:-}" ]]; then
      show_startup_tip
      typeset -g ZSHRC_SHORTCUTS_SHOWN=1
    fi
    ;;
esac

# Tab behavior with autosuggestions:
# 1) If suggestion exists: accept it segment-by-segment.
# 2) If no suggestion: keep native completion behavior.
# 3) If Tab is double-tapped quickly: force native completion/menu.
typeset -gF _TAB_LAST_TS=0
typeset -gF ZSH_TAB_DOUBLE_TAP_THRESHOLD=0.25

_zsh_tab_try_fix_unknown_command_head() {
  emulate -L zsh
  local original_buffer="$BUFFER"
  local original_cursor=$CURSOR
  local -a words
  words=(${(z)BUFFER})
  local head="${words[1]:-}"

  # Only handle "unknown command + has args" cases, e.g. "atp inall".
  [[ -z "$head" ]] && return 1
  [[ "$BUFFER" != *" "* ]] && return 1
  if (( $+commands[$head] )); then
    return 1
  fi
  local wh
  wh="$(whence -w -- "$head" 2>/dev/null || true)"
  if [[ "$wh" == *": alias" || "$wh" == *": function" || "$wh" == *": builtin" || "$wh" == *": reserved" ]]; then
    return 1
  fi

  # Move cursor to command head and ask completion system to correct it.
  CURSOR=${#head}
  zle expand-or-complete
  if [[ "$BUFFER" != "$original_buffer" ]]; then
    (( original_cursor > ${#BUFFER} )) && original_cursor=${#BUFFER}
    CURSOR=$original_cursor
    return 0
  fi
  CURSOR=$original_cursor
  return 1
}

_tab_accept_suggestion_segment_or_complete() {
  emulate -L zsh
  local now="${EPOCHREALTIME:-0}"
  local delta=999

  if [[ "$_TAB_LAST_TS" != "0" ]]; then
    delta=$(( now - _TAB_LAST_TS ))
  fi
  _TAB_LAST_TS="$now"

  # Double-tap Tab to trigger regular completion/menu directly.
  if (( delta >= 0 && delta < ZSH_TAB_DOUBLE_TAP_THRESHOLD )); then
    zle expand-or-complete
    return
  fi

  # No active autosuggestion; use regular completion.
  if [[ -z "$POSTDISPLAY" ]]; then
    if _zsh_tab_try_fix_unknown_command_head; then
      return
    fi
    zle expand-or-complete
    return
  fi

  # Accept autosuggestion in path-like segments.
  local tail="$POSTDISPLAY"
  local add=""

  if [[ "$tail" == /* ]]; then
    local rest="${tail#/}"
    if [[ "$rest" == */* ]]; then
      add="/${rest%%/*}/"
    else
      add="/$rest"
    fi
  else
    if [[ "$tail" == */* ]]; then
      add="${tail%%/*}"
    else
      add="$tail"
    fi
  fi

  BUFFER+="$add"
  CURSOR=${#BUFFER}
  zle autosuggest-fetch
}
zle -N _tab_accept_suggestion_segment_or_complete
bindkey '^I' _tab_accept_suggestion_segment_or_complete

# Right arrow:
# - if autosuggestion exists, accept full suggestion
# - otherwise, move cursor right as normal
_zsh_right_arrow_widget() {
  emulate -L zsh
  if [[ -n "$POSTDISPLAY" ]] && (( $+widgets[autosuggest-accept] )); then
    zle autosuggest-accept
  else
    zle forward-char
  fi
}
zle -N _zsh_right_arrow_widget
bindkey '^[[C' _zsh_right_arrow_widget
bindkey '^[OC' _zsh_right_arrow_widget
bindkey -M emacs '^[[C' _zsh_right_arrow_widget
bindkey -M emacs '^[OC' _zsh_right_arrow_widget
bindkey -M viins '^[[C' _zsh_right_arrow_widget
bindkey -M viins '^[OC' _zsh_right_arrow_widget

# 1) Smart command correction.
setopt CORRECT
SPROMPT='zsh correction: "%R" -> "%r" ? [y=yes, n=no, a=abort, e=edit] '

# 2) + 10) Long command timing + desktop notification.
typeset -gF ZSH_LONG_CMD_SECONDS=8
typeset -gF _ZSH_CMD_START_TS=0
typeset -g _ZSH_LAST_CMD=""
_zsh_cmd_preexec() {
  _ZSH_CMD_START_TS="${EPOCHREALTIME:-0}"
  _ZSH_LAST_CMD="$1"
}
_zsh_cmd_precmd() {
  emulate -L zsh
  if (( _ZSH_CMD_START_TS <= 0 )); then
    return
  fi

  local now="${EPOCHREALTIME:-0}"
  local elapsed=$(( now - _ZSH_CMD_START_TS ))
  _ZSH_CMD_START_TS=0

  if (( elapsed < ZSH_LONG_CMD_SECONDS )); then
    return
  fi

  local elapsed_fmt
  local -i elapsed_int
  elapsed_int=$(( elapsed ))
  if (( elapsed_int < 60 )); then
    elapsed_fmt="${elapsed_int}s"
  else
    local -i h m s
    h=$(( elapsed_int / 3600 ))
    m=$(( (elapsed_int % 3600) / 60 ))
    s=$(( elapsed_int % 60 ))
    local -a parts
    if (( h > 0 )); then
      parts+=("${h}h")
    fi
    if (( m > 0 || h > 0 )); then
      parts+=("${m}m")
    fi
    parts+=("${s}s")
    elapsed_fmt="${(j: :)parts}"
  fi

  local msg="Done in ${elapsed_fmt}: ${_ZSH_LAST_CMD}"
  print -P "%F{yellow}${msg}%f"
  if command -v notify-send >/dev/null 2>&1; then
    notify-send "zsh long command" "$msg" >/dev/null 2>&1 || true
  fi
  print -n "\a"
}

# 3) Jump to frequent directories (z plugin + j alias).
alias j='z'
alias zi='z -i'

# 4) Better history search, fuzzy when fzf is available.
if command -v fzf >/dev/null 2>&1; then
  _zsh_fzf_history_widget() {
    emulate -L zsh
    local selected
    selected="$(
      fc -rl 1 |
      sed 's/^[[:space:]]*[0-9]\+[[:space:]]*//' |
      awk '!seen[$0]++' |
      fzf --height=40% --layout=reverse --prompt='history> '
    )"
    [[ -z "$selected" ]] && return
    BUFFER="$selected"
    CURSOR=${#BUFFER}
  }
  zle -N _zsh_fzf_history_widget
  bindkey '^R' _zsh_fzf_history_widget
else
  bindkey '^R' history-incremental-pattern-search-backward
fi

# 5) Context-aware runtime switching (.nvmrc / .venv).
typeset -g _ZSH_AUTO_NVMRC_PATH=""
typeset -g _ZSH_AUTO_NVMRC_VAL=""
_zsh_auto_context_switch() {
  emulate -L zsh

  # Node.js via .nvmrc
  if command -v nvm >/dev/null 2>&1; then
    local nvmrc_path=""
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
      if [[ -f "$dir/.nvmrc" ]]; then
        nvmrc_path="$dir/.nvmrc"
        break
      fi
      dir="${dir:h}"
    done

    if [[ -n "$nvmrc_path" ]]; then
      local nvmrc_val
      nvmrc_val="$(<"$nvmrc_path")"
      if [[ "$nvmrc_path" != "$_ZSH_AUTO_NVMRC_PATH" || "$nvmrc_val" != "$_ZSH_AUTO_NVMRC_VAL" ]]; then
        nvm use --silent >/dev/null 2>&1 || true
        _ZSH_AUTO_NVMRC_PATH="$nvmrc_path"
        _ZSH_AUTO_NVMRC_VAL="$nvmrc_val"
      fi
    fi
  fi

  # Python via local .venv (walk up directories).
  local venv_dir=""
  local pdir="$PWD"
  while [[ "$pdir" != "/" ]]; do
    if [[ -f "$pdir/.venv/bin/activate" ]]; then
      venv_dir="$pdir/.venv"
      break
    fi
    pdir="${pdir:h}"
  done

  if [[ -n "$venv_dir" ]]; then
    if [[ "$VIRTUAL_ENV" != "$venv_dir" ]]; then
      source "$venv_dir/bin/activate"
    fi
  else
    if [[ -n "$VIRTUAL_ENV" && -n "${_OLD_VIRTUAL_PATH:-}" ]]; then
      deactivate >/dev/null 2>&1 || true
    fi
  fi
}

# 6) Dangerous command double-enter confirmation.
typeset -g _ZSH_DANGER_CONFIRM_BUFFER=""
_zsh_safe_accept_line() {
  emulate -L zsh
  local cmd="$BUFFER"
  local dangerous=0

  if [[ "$cmd" =~ '(^|[[:space:]])(sudo[[:space:]]+)?rm([[:space:]]+[^;&|]*)*[[:space:]]-rf([[:space:]]|$)' ]]; then
    dangerous=1
  elif [[ "$cmd" =~ '(^|[[:space:]])git[[:space:]]+reset[[:space:]]+--hard([[:space:]]|$)' ]]; then
    dangerous=1
  elif [[ "$cmd" =~ '(^|[[:space:]])git[[:space:]]+push([[:space:]]+[^;&|]*)*[[:space:]]--force(-with-lease)?([[:space:]]|$)' ]]; then
    dangerous=1
  elif [[ "$cmd" =~ '(^|[[:space:]])dd[[:space:]]+if=' ]]; then
    dangerous=1
  fi

  if (( dangerous )); then
    if [[ "$_ZSH_DANGER_CONFIRM_BUFFER" != "$cmd" ]]; then
      _ZSH_DANGER_CONFIRM_BUFFER="$cmd"
      zle -M "Dangerous command detected: press Enter again to confirm."
      return
    fi
  fi

  _ZSH_DANGER_CONFIRM_BUFFER=""
  zle .accept-line
}
zle -N accept-line _zsh_safe_accept_line

# 7) Git-aware prompt (branch + dirty markers) with minimal overhead.
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes false
zstyle ':vcs_info:git:*' stagedstr '+'
zstyle ':vcs_info:git:*' unstagedstr '*'
zstyle ':vcs_info:git:*' formats '(%b%u%c)'
typeset -g _ZSH_GIT_TREE_CACHE_PWD=""
typeset -gi _ZSH_GIT_TREE_CACHE_IS_GIT=0
_zsh_pwd_is_git_tree() {
  emulate -L zsh
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -d "$dir/.git" || -f "$dir/.git" ]]; then
      return 0
    fi
    dir="${dir:h}"
  done
  return 1
}
_zsh_update_vcs_prompt() {
  emulate -L zsh
  if [[ "$PWD" != "$_ZSH_GIT_TREE_CACHE_PWD" ]]; then
    if _zsh_pwd_is_git_tree; then
      _ZSH_GIT_TREE_CACHE_IS_GIT=1
    else
      _ZSH_GIT_TREE_CACHE_IS_GIT=0
    fi
    _ZSH_GIT_TREE_CACHE_PWD="$PWD"
  fi
  if (( _ZSH_GIT_TREE_CACHE_IS_GIT )); then
    vcs_info
  else
    vcs_info_msg_0_=""
  fi
}

# 8) One-command project launcher (run/test/build).
_zsh_is_python_project() {
  [[ -f manage.py || -f pyproject.toml || -f requirements.txt || -f main.py || -f app.py || -f run.py || -f server.py || -f src/main.py || -f src/app.py ]]
}

_zsh_python_entry_file() {
  local candidate
  for candidate in main.py app.py run.py server.py src/main.py src/app.py; do
    [[ -f "$candidate" ]] && { print -r -- "$candidate"; return 0; }
  done
  return 1
}

_zsh_is_cpp_project() {
  [[ -f CMakeLists.txt || -f Makefile ]]
}

_zsh_cmake_prepare() {
  cmake -S . -B build
}

run() {
  local -a pass_args
  pass_args=("$@")
  if [[ "${pass_args[1]:-}" == "--" ]]; then
    pass_args=("${pass_args[@]:1}")
  fi

  if [[ -f package.json ]]; then
    npm run dev -- "${pass_args[@]}" 2>/dev/null || npm start -- "${pass_args[@]}"
  elif [[ -x ./gradlew ]]; then
    if (( ${#pass_args[@]} > 0 )); then
      ./gradlew bootRun --args="${(j: :)pass_args}"
    else
      ./gradlew bootRun
    fi
  elif _zsh_is_python_project; then
    if (( ${#pass_args[@]} > 0 )); then
      if command -v uv >/dev/null 2>&1 && [[ -f pyproject.toml ]]; then
        uv run python "${pass_args[@]}"
      else
        python "${pass_args[@]}"
      fi
      return
    fi

    if [[ -f manage.py ]]; then
      python manage.py runserver "${pass_args[@]}"
      return
    fi

    local py_entry
    py_entry="$(_zsh_python_entry_file)"
    if [[ -n "$py_entry" ]]; then
      if command -v uv >/dev/null 2>&1 && [[ -f pyproject.toml ]]; then
        uv run python "$py_entry" "${pass_args[@]}"
      else
        python "$py_entry" "${pass_args[@]}"
      fi
      return
    fi

    if [[ -f pyproject.toml ]]; then
      echo "Python project detected, but no entry file found."
      echo "Add one of: main.py, app.py, run.py, server.py, src/main.py, src/app.py"
      echo "Or run manually: uv run <cmd> / poetry run <cmd> / python -m <module>"
      return 1
    fi
  elif [[ -f Makefile ]]; then
    make run "${pass_args[@]}"
  elif [[ -f CMakeLists.txt ]]; then
    _zsh_cmake_prepare || return 1
    cmake --build build || return 1
    local exe_name exe
    exe_name="${PWD:t}"
    for exe in "build/${exe_name}" "build/bin/${exe_name}" "build/a.out"; do
      if [[ -x "$exe" ]]; then
        "$exe" "${pass_args[@]}"
        return
      fi
    done
    echo "C++ project built, but no default executable found."
    echo "Try: ls build build/bin and run target manually."
    return 1
  else
    echo "No known run target in $(pwd)"
    return 1
  fi
}
ptest() {
  if [[ -f package.json ]]; then
    npm test
  elif [[ -x ./gradlew ]]; then
    ./gradlew test
  elif [[ -f Makefile ]]; then
    make test
  elif [[ -f CMakeLists.txt ]]; then
    _zsh_cmake_prepare || return 1
    cmake --build build || return 1
    ctest --test-dir build --output-on-failure
  else
    echo "No known test target in $(pwd)"
    return 1
  fi
}
pbuild() {
  if [[ -f package.json ]]; then
    npm run build
  elif [[ -x ./gradlew ]]; then
    ./gradlew build
  elif [[ -f Makefile ]]; then
    make build
  elif [[ -f CMakeLists.txt ]]; then
    _zsh_cmake_prepare && cmake --build build
  else
    echo "No known build target in $(pwd)"
    return 1
  fi
}

# 9) Session helpers: restore last directory.
typeset -g ZSH_LAST_DIR_FILE="$HOME/.zsh_last_dir"
typeset -g ZSH_AUTO_RESTORE_LAST_DIR=1
_zsh_save_last_dir() {
  print -r -- "$PWD" >| "$ZSH_LAST_DIR_FILE"
}
if (( ZSH_AUTO_RESTORE_LAST_DIR )) && [[ "$PWD" == "$HOME" && -r "$ZSH_LAST_DIR_FILE" ]]; then
  read -r _zsh_last_dir < "$ZSH_LAST_DIR_FILE"
  [[ -n "$_zsh_last_dir" && -d "$_zsh_last_dir" && -x "$_zsh_last_dir" ]] && cd "$_zsh_last_dir"
fi

# Hook registration (single place for performance and clarity).
autoload -Uz add-zsh-hook
_zsh_hook_ensure() {
  emulate -L zsh
  local hook="$1"
  local fn="$2"
  # Remove once (if present), then register once.
  add-zsh-hook -d "$hook" "$fn" >/dev/null 2>&1 || true
  add-zsh-hook "$hook" "$fn"
}
_zsh_hook_ensure preexec _zsh_cmd_preexec
_zsh_hook_ensure precmd _zsh_cmd_precmd
_zsh_hook_ensure precmd _zsh_update_vcs_prompt
_zsh_hook_ensure precmd _zsh_save_last_dir
_zsh_hook_ensure chpwd _zsh_auto_context_switch
if [[ -z "${ZSHRC_CONTEXT_SWITCH_INIT_DONE:-}" ]]; then
  _zsh_auto_context_switch
  typeset -g ZSHRC_CONTEXT_SWITCH_INIT_DONE=1
fi

# Prompt with vcs segment.
PROMPT="%F{green}%n@${ZSH_AI_HOST_LABEL}%f:%F{yellow}%/%f %F{magenta}\${vcs_info_msg_0_}%f %# "
