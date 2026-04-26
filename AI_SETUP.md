# AI_SETUP

面向 AI 代理执行。目标是零猜测、可验证、可重跑。

[中文主文档](./README.md) | [English](./README.en.md) | [AI 速查](./AI_USAGE.md)

## 1. 项目目标

把仓库中的真实 Zsh 配置安装到用户环境：
- `configs/.zshrc`
- `configs/.zshenv`

禁止替换为通用模板。

## 2. 支持系统

- Ubuntu
- Debian
- Deepin（含 `linuxdeepin` / `UOS` 识别）
- WSL

## 3. 前置检查（必须）

```bash
command -v bash
command -v wget || command -v curl
```

说明：
- 单文件入口支持：只下载 `install.sh`，脚本会自动拉取其余依赖文件。
- 缺少 `zsh` / `git` 时，脚本会尝试通过 `apt-get` 安装（非 root 优先 `sudo apt-get`）。
- 安装插件/Oh My Zsh 需要网络访问 GitHub。

## 4. 非交互标准流程（推荐）

先 dry-run，再正式安装，再校验。

```bash
set -e; wget -O install.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/install.sh && chmod +x install.sh && ./install.sh --lang zh --non-interactive --install-plugins yes --show-startup-tips once --set-default-shell yes --backup yes --dry-run
set -e; wget -O install.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/install.sh && chmod +x install.sh && ./install.sh --lang zh --non-interactive --install-plugins yes --show-startup-tips once --set-default-shell yes --backup yes
echo "$SHELL"
zsh --version
test -f ~/.zshrc
test -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
zsh -n ~/.zshrc
zsh -n ~/.zshenv
```

## 5. 直接执行命令（不读文档）

```bash
bash -lc 'set -e; wget -O install.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/install.sh && chmod +x install.sh && ./install.sh --lang zh --non-interactive --install-plugins yes --show-startup-tips once --set-default-shell yes --backup yes; echo "[verify] shell=$SHELL"; zsh --version; test -f ~/.zshrc; test -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"; zsh -n ~/.zshrc; zsh -n ~/.zshenv'
```

## 6. 先读后执行指令（推荐给代理型 AI）

```text
请先阅读 https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/AI_SETUP.md 与 https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/AI_USAGE.md，然后按非交互流程执行安装并输出完整校验结果。
```

## 7. 参数参考（含解释）

- `--lang zh|en`：设置安装语言与启动提示语言。
- `--interactive`：交互式提问安装（人工操作）。
- `--non-interactive`：无交互安装（脚本/AI）。
- `--install-plugins yes|no`：是否安装插件（必装 + 可选）。
- `--show-startup-tips always|once|off`：启动提示显示策略。
- `--set-default-shell yes|no`：是否尝试切换默认 shell 到 zsh。
- `--backup yes|no`：写入前是否备份已有配置文件。
- `--optional-plugins p1/p2`：指定可选插件，使用 `/` 分隔（如 `zsh-completions/fzf-tab/thefuck`）。
- `--dry-run`：仅预览动作，不写入。
- `--force`：强制覆盖/更新路径。

## 8. 默认行为

- 未显式指定模式：
  - TTY => interactive
  - non-TTY => non-interactive
- `--backup` 默认 `yes`
- `--install-plugins` 默认 `yes`
- `--show-startup-tips` 默认 `always`
- 可选插件交互输入中：回车默认全选

## 9. 已有 ~/.zshrc 处理规则

- interactive 模式会询问是否覆盖
- 默认先备份再写入
- 备份名：`.zshrc.backup-YYYYMMDD-xxxx`

## 10. 常见失败原因

- 无 `sudo` 且非 root，无法安装缺失依赖：`zsh` / `git`
- GitHub 网络不可达，无法拉取 Oh My Zsh / 插件
- `chsh` 被系统策略限制，默认 shell 切换失败（不影响安装本身）

## 11. 启动提示控制

仅切换模式，不执行安装流程：

```bash
~/.zsh-ai-setup/installer/install.sh --show-startup-tips off
~/.zsh-ai-setup/installer/install.sh --show-startup-tips always
~/.zsh-ai-setup/installer/install.sh --show-startup-tips once
```

提示文件路径：
- `${XDG_CONFIG_HOME:-$HOME/.config}/zsh-ai-setup/startup-tip.txt`

## 12. 卸载

```bash
~/.zsh-ai-setup/installer/uninstall.sh --interactive
~/.zsh-ai-setup/installer/uninstall.sh --non-interactive --restore-backup yes --force
```

仅删除本项目管理内容，尽量恢复备份，不删除无关用户文件。

## 13. 语言选择

- 中文：`--lang zh`
- 英文：`--lang en`

安装提示、日志、启动提示模板都跟随该参数。
