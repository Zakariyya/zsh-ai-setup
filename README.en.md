# zsh-ai-setup

> English documentation

[中文主文档 (Default)](./README.md) | [中文别名](./README.zh-CN.md)

## 🤖 AI-friendly: direct run or doc-first run

This project packages your real Zsh setup for **Ubuntu / Debian family (including Deepin) / WSL**, with deterministic AI execution support.

- ✅ Interactive mode for humans
- ✅ Non-interactive mode for AI agents
- ✅ Idempotent reruns with backup-before-overwrite
- ✅ Bilingual output (Chinese/English)
- ✅ Startup tips with `always / once / off`

AI docs entry points:
- [AI_SETUP.md](./AI_SETUP.md)
- [AI_USAGE.md](./AI_USAGE.md)
- [docs/ai-usage.md (compat redirect)](./docs/ai-usage.md)

## 🚀 Install

Unified baseline command (works even when only `install.sh` is downloaded; script bootstraps remaining files automatically):

Interactive mode:

```bash
set -e; wget -O install.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/install.sh && chmod +x install.sh && ./install.sh --interactive
```

Non-interactive mode:

```bash
set -e; wget -O install.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/install.sh && chmod +x install.sh && ./install.sh --lang en --non-interactive --install-plugins yes --show-startup-tips once --set-default-shell yes --backup yes
```

## 🧠 AI execution (two modes)

### Mode A: direct command (fastest)

```bash
bash -lc 'set -e; wget -O install.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/install.sh && chmod +x install.sh && ./install.sh --lang en --non-interactive --install-plugins yes --show-startup-tips once --set-default-shell yes --backup yes; echo "[verify] shell=$SHELL"; zsh --version; test -f ~/.zshrc; test -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"; zsh -n ~/.zshrc; zsh -n ~/.zshenv'
```

### Mode B: doc-first instruction (safer)

Send this prompt to an AI agent:

```text
Please read https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/AI_SETUP.md and https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/AI_USAGE.md first, then execute non-interactive installation and return full verification output.
```

## 🧩 Optional plugins (interactive mode)

Optional plugin menu:
- `1) Select all`
- `2) zsh-completions`
- `3) fzf-tab`
- `4) thefuck`
- `n) Install no optional plugins`

Input rules:
- Use numeric options with `/` separator (for example `2/4`)
- `1` or Enter: select all optional plugins
- `n`: install none of the optional plugins

## 🛡️ Dependencies and safety

Dependency behavior:
- Missing `zsh`: installer tries `apt-get install zsh`
- Missing `git`: installer tries `apt-get install git`
- Non-root user: prefers `sudo apt-get`
- Plugin/Oh My Zsh install requires GitHub network access

Safety behavior:
- Existing `~/.zshrc`: interactive mode asks before overwrite
- Backup format: `.zshrc.backup-YYYYMMDD-xxxx`
- Safety flags: `--backup`, `--dry-run`, `--force`
- Existing plugin folders are skipped by default (`--force` attempts update)

## 🔧 Key arguments (with explanations)

- `--lang zh|en`: Sets installer language and startup-tip language.
- `--interactive`: Runs question-based interactive installation.
- `--non-interactive`: Runs unattended installation.
- `--install-plugins yes|no`: Enables or skips plugin installation.
- `--show-startup-tips always|once|off`: Controls startup-tip display mode.
- `--set-default-shell yes|no`: Tries to switch the default shell to zsh.
- `--backup yes|no`: Backs up existing config files before writing.
- `--optional-plugins p1/p2`: Selects optional plugins using `/` separator (for example `zsh-completions/fzf-tab/thefuck`).
- `--dry-run`: Previews actions only; does not write files.
- `--force`: Forces overwrite/update-related paths.

## 💡 Update startup tip mode only

These commands update tip mode only and exit without running installation:

```bash
~/.zsh-ai-setup/installer/install.sh --show-startup-tips off
~/.zsh-ai-setup/installer/install.sh --show-startup-tips once
~/.zsh-ai-setup/installer/install.sh --show-startup-tips always
```

## 🧩 Plugins

Required:
- `zsh-autosuggestions`: Suggests commands from history as you type.
- `zsh-syntax-highlighting`: Highlights command syntax to reduce input mistakes.

Optional:
- `zsh-completions`: Adds extra command and argument completion definitions.
- `fzf-tab`: Replaces plain Tab completion with fuzzy selectable completion.
- `thefuck`: Fixes common mistyped commands (via `fuck`).

Default target:
- `${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins`

## ✅ Verification

```bash
echo $SHELL
zsh --version
test -f ~/.zshrc
test -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
zsh -n ~/.zshrc
zsh -n ~/.zshenv
```

Open a new terminal and confirm startup tip language/mode behavior.

## 🧹 Uninstall

```bash
~/.zsh-ai-setup/installer/uninstall.sh --interactive
~/.zsh-ai-setup/installer/uninstall.sh --non-interactive --restore-backup yes --force
```

Uninstall removes project-managed assets and tries to restore backups conservatively.
