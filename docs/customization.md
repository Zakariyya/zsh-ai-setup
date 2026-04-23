# Customization

Primary docs:
- `../README.md`
- `../README.en.md`
- `./AI_SETUP.md`

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

## 3. Add optional plugins

1. Add repo mapping in `scripts/install_plugins.sh`.
2. Add plugin name to `configs/plugins.zsh` optional list.
3. Reinstall with:

```bash
./install.sh --non-interactive --install-plugins yes --optional-plugins your-plugin --force
```

## 4. Startup tip language

Installer copies one of:
- `templates/startup-tip.zh-CN.txt`
- `templates/startup-tip.en.txt`

to:
- `${XDG_CONFIG_HOME:-$HOME/.config}/zsh-ai-setup/startup-tip.txt`
