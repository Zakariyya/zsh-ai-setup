# AI_USAGE

> 面向 AI 代理的执行速查（顶层入口）

[中文主文档](./README.md) | [English](./README.en.md) | [AI 规范文档](./AI_SETUP.md)

## 1) 两种 AI 使用方式

### A. 直接执行模式（最快）

```bash
bash -lc 'set -e; wget -O install.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/install.sh && chmod +x install.sh && ./install.sh --lang zh --non-interactive --install-plugins yes --show-startup-tips once --set-default-shell yes --backup yes; echo "[verify] shell=$SHELL"; zsh --version; test -f ~/.zshrc; test -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"; zsh -n ~/.zshrc; zsh -n ~/.zshenv'
```

### B. 先读后执行模式（更稳）

可直接发给 AI 的指令：

```text
请先阅读 https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/AI_SETUP.md 与 https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/AI_USAGE.md，然后按非交互流程执行安装并输出完整校验结果。
```

## 2) 推荐非交互流程

```bash
set -e; wget -O install.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/install.sh && chmod +x install.sh && ./install.sh --lang zh --non-interactive --install-plugins yes --show-startup-tips once --set-default-shell yes --backup yes --dry-run
set -e; wget -O install.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/install.sh && chmod +x install.sh && ./install.sh --lang zh --non-interactive --install-plugins yes --show-startup-tips once --set-default-shell yes --backup yes
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

## 4) 启动提示模式单独切换

以下命令只更新模式并退出，不会执行安装流程：

```bash
~/.zsh-ai-setup/installer/install.sh --show-startup-tips off
~/.zsh-ai-setup/installer/install.sh --show-startup-tips once
~/.zsh-ai-setup/installer/install.sh --show-startup-tips always
```

## 5) 常见误区

- 如果希望 AI 一定先读文档，请使用“先读后执行模式”的文字指令。
- `--show-startup-tips` 单独执行不会触发安装。
- 单文件入口可以工作：`install.sh` 会自动自举拉取 `scripts/`、`configs/`、`templates/`。
