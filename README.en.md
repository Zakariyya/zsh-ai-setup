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

## 🚀 Install (human)

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

Notes:
- If you want `zsh` to become the default shell, use `--set-default-shell yes`
- If you want to switch the default shell, run `chsh -s "$(command -v zsh)"` manually after install

### Mode B: doc-first instruction (safer)

Send this prompt to an AI agent:

```text
Please read https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/AI_SETUP.md and https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/AI_USAGE.md first, then execute non-interactive installation and return full verification output.
```

## 🛡️ Safety

- Existing `~/.zshrc`: interactive mode asks before overwrite
- Backup format: `.zshrc.backup-YYYYMMDD-xxxx`
- Safety flags: `--backup`, `--dry-run`, `--force`
- Existing plugin folders are skipped by default (`--force` attempts update)

## 🔧 Key arguments

- `--lang zh|en`: Sets installer language and startup-tip language.
- `--interactive`: Runs question-based interactive installation (for humans).
- `--non-interactive`: Runs unattended installation (for scripts/AI).
- `--install-plugins yes|no`: Enables or skips plugin installation.
- `--show-startup-tips always|once|off`: Controls startup-tip display mode.
- `--set-default-shell yes|no`: Tries to switch the default shell to zsh.
- `--backup yes|no`: Backs up existing config files before writing.
- `--tab-double-tap-threshold seconds`: Tab double-tap detection threshold (for example `0.25`, `0.35`, `0.45`).
- `--optional-plugins p1/p2`: Selects optional plugins with `/` separator (for example `zsh-completions/fzf-tab/thefuck`).
- `--dry-run`: Previews actions only; does not write files.
- `--force`: Forces execution in overwrite/update-related paths.

## 🧩 Plugins

Required:
- `zsh-autosuggestions`: Suggests commands based on history as you type.
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
./uninstall.sh --interactive
./uninstall.sh --non-interactive --restore-backup yes --force
```

Uninstall only removes project-managed assets and tries to restore backups conservatively.
