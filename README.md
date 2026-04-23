# zsh-ai-setup

> 中文主文档（默认）

[English Version](./README.en.md) | [简体中文别名](./README.zh-CN.md)

## 🤖 AI 友好：可直接执行，也可先读规范再执行

本项目用于在 **Ubuntu / Debian / WSL** 复用你的真实 Zsh 配置，并且对 AI 代理友好。

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
chmod +x install.sh uninstall.sh scripts/*.sh
./install.sh --interactive
```

非交互模式：

```bash
./install.sh --lang zh --non-interactive --install-plugins yes --show-startup-tips once --set-default-shell no --backup yes
```

## 🧠 AI 执行方式（两种）

### 方式 A：直接执行（最快）

```bash
bash -lc './install.sh --lang zh --non-interactive --install-plugins yes --show-startup-tips once --set-default-shell no --backup yes && echo "[verify] shell=$SHELL" && zsh --version && test -f ~/.zshrc && test -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && zsh -n ~/.zshrc && zsh -n ~/.zshenv'
```

说明：该命令会直接执行安装与校验，不会自动读取文档。

### 方式 B：先读文档再执行（更稳）

把这句话发给 AI：

```text
请先阅读 ./AI_SETUP.md 与 ./AI_USAGE.md，然后按非交互流程执行安装并输出完整校验结果。
```

## 🛡️ 安全机制

- 已有 `~/.zshrc`：交互模式会询问是否覆盖
- 默认先备份再写入：`.zshrc.backup-YYYYMMDD-xxxx`
- 安全参数：`--backup`、`--dry-run`、`--force`
- 插件目录已存在：默认跳过，`--force` 时尝试更新

## 🔧 常用参数

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

## 🧩 插件说明

必装插件：
- `zsh-autosuggestions`
- `zsh-syntax-highlighting`

可选插件：
- `zsh-completions`
- `fzf-tab`

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
