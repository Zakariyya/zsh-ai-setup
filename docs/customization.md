# Customization

Primary docs:
- `../README.md`
- `../README.en.md`
- `../AI_SETUP.md`

## 1. Keep source-of-truth

Edit repository files first:
- `configs/.zshrc`
- `configs/.zshenv`
- `configs/aliases.zsh`
- `configs/exports.zsh`
- `configs/plugins.zsh`

Then rerun installer.

## 2. Machine-specific settings

Use installer-generated file:
- `${XDG_CONFIG_HOME:-$HOME/.config}/zsh-ai-setup/config.env`

Recommended overrides:
- `ZSH_AI_JAVA_HOME`
- `ZSH_AI_GRADLE_HOME`
- `ZSH_AI_HOST_LABEL`
- `ZSH_AI_STARTUP_TIP_MODE`

## 3. Optional plugins

Current optional plugins:
- `zsh-completions`
- `fzf-tab`
- `thefuck`

Interactive input rules:
- `1` or Enter: select all optional plugins
- `n`: install none
- numeric options with `/` separator (for example: `2/4`)

Non-interactive example:

```bash
set -e; wget -O install.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/install.sh && chmod +x install.sh && ./install.sh --non-interactive --install-plugins yes --optional-plugins zsh-completions/thefuck --force
```

## 4. Startup tip language and mode

Installer copies one of:
- `templates/startup-tip.zh-CN.txt`
- `templates/startup-tip.en.txt`

to:
- `${XDG_CONFIG_HOME:-$HOME/.config}/zsh-ai-setup/startup-tip.txt`

Mode-only update command:

```bash
~/.zsh-ai-setup/installer/install.sh --show-startup-tips once
```
