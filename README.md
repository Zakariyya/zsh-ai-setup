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

## 🚀 安装

统一执行基线（支持仅下载 `install.sh`，脚本会自动拉取其余依赖文件）：

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

### 方式 B：先读文档再执行（更稳）

把这句话发给 AI：

```text
请先阅读 https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/AI_SETUP.md 与 https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/AI_USAGE.md，然后按非交互流程执行安装并输出完整校验结果。
```

## 🧩 可选插件（交互模式）

可选插件列表：
- `1) 全选`
- `2) zsh-completions`
- `3) fzf-tab`
- `4) thefuck`
- `n) 不安装可选插件`

输入规则：
- 使用编号，`/` 分隔（例如 `2/4`）
- `1` 或回车：全选
- `n`：不安装可选插件

## 🛡️ 依赖与安全机制

依赖处理：
- 缺少 `zsh`：会尝试用 `apt-get` 安装
- 缺少 `git`：会尝试用 `apt-get` 安装
- 非 root 用户会优先使用 `sudo apt-get`
- 安装插件/Oh My Zsh 需要可访问 GitHub 网络

安全机制：
- 已有 `~/.zshrc`：交互模式会询问是否覆盖
- 默认先备份再写入：`.zshrc.backup-YYYYMMDD-xxxx`
- 安全参数：`--backup`、`--dry-run`、`--force`
- 插件目录已存在：默认跳过，`--force` 时尝试更新

## 🔧 常用参数（含说明）

- `--lang zh|en`：设置安装语言与启动提示语言。
- `--interactive`：交互式提问安装（人工推荐）。
- `--non-interactive`：无交互安装（脚本/AI 推荐）。
- `--install-plugins yes|no`：是否安装插件（必装 + 可选）。
- `--show-startup-tips always|once|off`：启动提示显示策略（总是/仅一次/关闭）。
- `--set-default-shell yes|no`：是否尝试切换默认 shell 到 zsh。
- `--backup yes|no`：写入前是否备份已有配置文件。
- `--optional-plugins p1/p2`：指定可选插件，使用 `/` 分隔（如 `zsh-completions/fzf-tab/thefuck`）。
- `--dry-run`：只预览将执行的动作，不写入文件。
- `--force`：强制执行覆盖/更新路径。

## 💡 启动提示模式单独切换

仅切换模式，不执行安装流程：

```bash
~/.zsh-ai-setup/installer/install.sh --show-startup-tips off
~/.zsh-ai-setup/installer/install.sh --show-startup-tips once
~/.zsh-ai-setup/installer/install.sh --show-startup-tips always
```

## 🧩 插件说明

必装插件：
- `zsh-autosuggestions`：按历史输入给出命令建议。
- `zsh-syntax-highlighting`：命令行语法高亮，减少误输。

可选插件：
- `zsh-completions`：补充命令与参数补全定义。
- `fzf-tab`：Tab 补全切换为可筛选的模糊选择。
- `thefuck`：纠正常见输错命令（`fuck`）。

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
~/.zsh-ai-setup/installer/uninstall.sh --interactive
~/.zsh-ai-setup/installer/uninstall.sh --non-interactive --restore-backup yes --force
```

仅移除本项目管理的内容，尽量恢复备份，不删除无关用户文件。
