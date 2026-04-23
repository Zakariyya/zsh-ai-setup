# AI_SETUP

## 1. Project Goal

Package the existing Zsh setup into a deterministic toolkit.

Source-of-truth files:
- `configs/.zshrc`
- `configs/.zshenv`

Do not replace them with generic templates.

## 2. Supported Systems

- Ubuntu
- Debian
- WSL

## 3. Prerequisites

Required commands:
- `bash`
- `git`

Runtime notes:
- `sudo` may be required when zsh is not installed.
- network access is required for plugin/Oh My Zsh clone.

## 4. Install Commands

Interactive:
```bash
./install.sh --interactive
```

Non-interactive:
```bash
./install.sh --lang zh --non-interactive --install-plugins yes --show-startup-tips off --set-default-shell yes --backup yes
./install.sh --lang en --non-interactive --install-plugins no --show-startup-tips once --set-default-shell no --backup yes --dry-run
```

## 5. Parameter Reference

- `--lang zh|en`
- `--interactive`
- `--non-interactive`
- `--install-plugins yes|no`
- `--show-startup-tips always|once|off`
- `--set-default-shell yes|no`
- `--backup yes|no`
- `--optional-plugins p1,p2`
- `--dry-run`
- `--force`

## 6. Default Behaviors

- If mode not specified:
  - TTY => interactive
  - non-TTY => non-interactive
- Default backup: `yes`
- Default plugin install: `yes`
- Default startup tips: `always`
- Existing plugin dirs: skip unless `--force`

## 7. Existing .zshrc Safety

When `~/.zshrc` exists:
- interactive mode asks overwrite
- backup by default before overwrite
- backup format:
  - `.zshrc.backup-YYYYMMDD-xxxx`

## 8. Common Failures

- Missing `git` => plugin install fails.
- Missing `sudo` + missing `zsh` => cannot auto-install zsh.
- `chsh` permission/policy => default shell change may fail.

## 9. Verify Success

Run:
```bash
echo $SHELL
zsh --version
test -f ~/.zshrc
test -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
zsh -n ~/.zshrc
zsh -n ~/.zshenv
```

Open a new terminal and check startup tips in selected language.

## 10. Startup Tips Control

- Disable: `--show-startup-tips off`
- Enable always: `--show-startup-tips always`
- Show once: `--show-startup-tips once`

Tips file path:
- `${XDG_CONFIG_HOME:-$HOME/.config}/zsh-ai-setup/startup-tip.txt`

## 11. Uninstall

Interactive:
```bash
./uninstall.sh --interactive
```

Non-interactive:
```bash
./uninstall.sh --non-interactive --restore-backup yes --force
```

Uninstall removes only project-managed files and tries to restore backups.

## 12. Language Selection

Use `--lang zh` or `--lang en`.
All installer prompts/logs and startup tip template follow this setting.
