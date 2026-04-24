# zsh-ai-setup

> English documentation

[中文主文档 (Default)](./README.md) | [中文别名](./README.zh-CN.md)

## 🤖 AI-friendly: direct run or doc-first run

This project packages your real Zsh setup for **Ubuntu / Debian / WSL**, with deterministic AI execution support.

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

Use single-file bootstrap (`wget`, no git required).

```bash
set -e; wget -O install.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/install.sh
```

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

Note: this command downloads only `install.sh` via `wget -O` and does not automatically read docs.

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

- `--lang zh|en`
- `--interactive`
- `--non-interactive`
- `--install-plugins yes|no`
- `--show-startup-tips always|once|off`
- `--set-default-shell yes|no`
- `--backup yes|no`
- `--optional-plugins p1/p2`
- `--dry-run`
- `--force`

## 🧩 Plugins

Required:
- `zsh-autosuggestions`
- `zsh-syntax-highlighting`

Optional:
- `zsh-completions`
- `fzf-tab`
- `thefuck`

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
