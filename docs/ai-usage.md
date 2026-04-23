# AI Usage Notes

This file is for deterministic AI execution.

## Required command format

Use fixed arguments:
- `--lang zh|en`
- `--interactive` or `--non-interactive`
- `--install-plugins yes|no`
- `--show-startup-tips always|once|off`
- `--set-default-shell yes|no`
- `--backup yes|no`
- `--dry-run`
- `--force`

## Recommended non-interactive flow

1. Dry run.
2. Real install.
3. Verify shell + version + plugin paths.

Example:

```bash
./install.sh --lang zh --non-interactive --install-plugins yes --show-startup-tips once --set-default-shell no --backup yes --dry-run
./install.sh --lang zh --non-interactive --install-plugins yes --show-startup-tips once --set-default-shell no --backup yes
```

## Verification checklist

```bash
echo $SHELL
zsh --version
test -f ~/.zshrc
test -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
zsh -n ~/.zshrc
```
