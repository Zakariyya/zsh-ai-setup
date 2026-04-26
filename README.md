# zsh-ai-setup

> 中文主文档（默认）

[English Version](./README.en.md) | [简体中文别名](./README.zh-CN.md)

## 🤖 AI 友好：可直接执行，也可先读规范再执行

本项目用于在 **Ubuntu / Debian 系（含 Deepin）/ WSL** 复用你的真实 Zsh 配置，并且对 AI 代理友好。

- ✅ 人类用户可交互安装
- ✅ AI 代理可非交互安装（参数固定、可验证）
- ✅ 幂等重跑、安全覆盖（默认先备份）
- ✅ 中英双语输出
- ✅ 启动提示支持 `always / once / off`

AI 文档入口（建议置顶给 AI）：
- [AI_SETUP.md](./AI_SETUP.md)
- [AI_USAGE.md](./AI_USAGE.md)
- [docs/ai-usage.md（兼容跳转）](./docs/ai-usage.md)

## 🚀 安装（人类用户）

交互模式：

```bash
set -e; wget -O install.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/install.sh && chmod +x install.sh && ./install.sh --interactive
```

非交互模式：

```bash
set -e; wget -O install.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/install.sh && chmod +x install.sh && ./install.sh --lang zh --non-interactive --install-plugins yes --show-startup-tips once --set-default-shell yes --backup yes
```

## 🧠 AI 执行方式（两种）

### 方式 A：直接执行（最快）

```bash
bash -lc 'set -e; wget -O install.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/install.sh && chmod +x install.sh && ./install.sh --lang zh --non-interactive --install-plugins yes --show-startup-tips once --set-default-shell yes --backup yes; echo "[verify] shell=$SHELL"; zsh --version; test -f ~/.zshrc; test -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"; zsh -n ~/.zshrc; zsh -n ~/.zshenv'
```

说明：
- 如果你希望默认切换到 `zsh`，请使用 `--set-default-shell yes`
- 如果需要切换默认 shell，请安装完成后手动执行 `chsh -s "$(command -v zsh)"`

### 方式 B：先读文档再执行（更稳）

把这句话发给 AI：

```text
请先阅读 https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/AI_SETUP.md 与 https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/AI_USAGE.md，然后按非交互流程执行安装并输出完整校验结果。
```

## 🛡️ 安全机制

- 已有 `~/.zshrc`：交互模式会询问是否覆盖
- 默认先备份再写入：`.zshrc.backup-YYYYMMDD-xxxx`
- 安全参数：`--backup`、`--dry-run`、`--force`
- 插件目录已存在：默认跳过，`--force` 时尝试更新

## 🔧 常用参数

- `--lang zh|en`：设置安装语言与提示语言。
- `--interactive`：交互式提问安装（适合人工操作）。
- `--non-interactive`：无交互安装（适合脚本/AI 执行）。
- `--install-plugins yes|no`：是否安装插件（必装+可选）。
- `--show-startup-tips always|once|off`：启动提示显示策略（总是/仅一次/关闭）。
- `--set-default-shell yes|no`：是否尝试把默认 shell 切换为 zsh。
- `--backup yes|no`：写入前是否备份已有配置文件。
- `--tab-double-tap-threshold 秒数`：Tab 双击判定阈值（如 `0.25`、`0.35`、`0.45`）。
- `--optional-plugins p1/p2`：指定可选插件，使用 `/` 分隔（如 `zsh-completions/fzf-tab/thefuck`）。
- `--dry-run`：只预览将执行的动作，不落盘写入。
- `--force`：强制执行（如覆盖确认、插件更新场景）。

## 🧩 插件说明

必装插件：
- `zsh-autosuggestions`：按历史输入给出命令建议。
- `zsh-syntax-highlighting`：为命令行语法高亮，减少误输。

可选插件：
- `zsh-completions`：补充更多命令与参数补全定义。
- `fzf-tab`：将 Tab 补全切换为可筛选的模糊选择。
- `thefuck`：纠正常见输错命令（配合 `fuck` 使用）。

默认安装位置：
- `${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins`

## ✅ 安装后快速校验

```bash
echo $SHELL
zsh --version
test -f ~/.zshrc
test -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
zsh -n ~/.zshrc
zsh -n ~/.zshenv
```

再开一个新终端，确认启动提示语言与模式符合预期。

## 🧹 卸载

```bash
./uninstall.sh --interactive
./uninstall.sh --non-interactive --restore-backup yes --force
```

仅移除本项目管理的内容，尽量恢复备份，不删除无关用户文件。
