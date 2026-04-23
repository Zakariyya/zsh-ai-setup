# AI_USAGE

> 面向 AI 代理的执行速查（顶层入口）

[中文主文档](./README.md) | [English](./README.en.md) | [AI 规范文档](./AI_SETUP.md)

## 1) 两种 AI 使用方式

### A. 直接执行模式（最快）

特点：
- 不要求 AI 先读文档
- 直接执行安装+校验命令

```bash
bash -lc './install.sh --lang zh --non-interactive --install-plugins yes --show-startup-tips once --set-default-shell no --backup yes && echo "[verify] shell=$SHELL" && zsh --version && test -f ~/.zshrc && test -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && zsh -n ~/.zshrc && zsh -n ~/.zshenv'
```

### B. 先读后执行模式（更稳）

特点：
- AI 先读取规则，再按固定流程执行
- 更适合需要可追溯、低歧义的场景

可直接发给 AI 的指令：

```text
请先阅读 ./AI_SETUP.md 与 ./AI_USAGE.md，然后按非交互流程执行安装并输出完整校验结果。
```

## 2) 推荐非交互流程

```bash
./install.sh --lang zh --non-interactive --install-plugins yes --show-startup-tips once --set-default-shell no --backup yes --dry-run
./install.sh --lang zh --non-interactive --install-plugins yes --show-startup-tips once --set-default-shell no --backup yes
```

## 3) 最小校验项

```bash
echo $SHELL
zsh --version
test -f ~/.zshrc
test -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
zsh -n ~/.zshrc
zsh -n ~/.zshenv
```

## 4) 常见误区

- `bash -lc '...'` 命令本身不会自动读取 `AI_SETUP.md`。
- 如果希望 AI 一定先读文档，请使用“先读后执行模式”的文字指令。
