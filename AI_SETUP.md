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
- WSL

## 3. 前置检查（必须）

```bash
command -v bash
command -v git
```

说明：
- 如果系统没有 `zsh`，安装过程可能需要 `sudo`。
- 安装插件/Oh My Zsh 需要网络。

## 4. 非交互标准流程（推荐）

先 dry-run，再正式安装，再校验。

```bash
mkdir -p /tmp/zsh-ai-setup && cd /tmp/zsh-ai-setup
wget -qO install.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/install.sh
wget -qO uninstall.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/uninstall.sh
mkdir -p scripts
wget -qO scripts/i18n.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/scripts/i18n.sh
wget -qO scripts/lib.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/scripts/lib.sh
wget -qO scripts/detect_os.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/scripts/detect_os.sh
wget -qO scripts/install_zsh.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/scripts/install_zsh.sh
wget -qO scripts/install_thefuck.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/scripts/install_thefuck.sh
wget -qO scripts/install_plugins.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/scripts/install_plugins.sh
chmod +x install.sh uninstall.sh scripts/*.sh
./install.sh --lang zh --non-interactive --install-plugins yes --show-startup-tips once --set-default-shell yes --backup yes --dry-run
./install.sh --lang zh --non-interactive --install-plugins yes --show-startup-tips once --set-default-shell yes --backup yes
echo "$SHELL"
zsh --version
test -f ~/.zshrc
test -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
zsh -n ~/.zshrc
zsh -n ~/.zshenv
```

## 5. 直接执行命令（不读文档）

```bash
bash -lc 'set -e; mkdir -p /tmp/zsh-ai-setup && cd /tmp/zsh-ai-setup; wget -qO install.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/install.sh; wget -qO uninstall.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/uninstall.sh; mkdir -p scripts; wget -qO scripts/i18n.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/scripts/i18n.sh; wget -qO scripts/lib.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/scripts/lib.sh; wget -qO scripts/detect_os.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/scripts/detect_os.sh; wget -qO scripts/install_zsh.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/scripts/install_zsh.sh; wget -qO scripts/install_thefuck.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/scripts/install_thefuck.sh; wget -qO scripts/install_plugins.sh https://raw.githubusercontent.com/Zakariyya/zsh-ai-setup/main/scripts/install_plugins.sh; chmod +x install.sh uninstall.sh scripts/*.sh; ./install.sh --lang zh --non-interactive --install-plugins yes --show-startup-tips once --set-default-shell yes --backup yes; echo "[verify] shell=$SHELL"; zsh --version; test -f ~/.zshrc; test -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"; zsh -n ~/.zshrc; zsh -n ~/.zshenv'
```

说明：这条命令会通过 `wget` 分段下载后执行；但它本身不会自动读取 `AI_SETUP.md` / `AI_USAGE.md`。
- 如果你希望默认切换到 `zsh`，请使用 `--set-default-shell yes`
- 如果需要切换默认 shell，请安装完成后手动执行 `chsh -s "$(command -v zsh)"`

## 6. 先读后执行指令（推荐给代理型 AI）

```text
请先阅读 ./AI_SETUP.md 与 ./AI_USAGE.md，然后按非交互流程执行安装并输出完整校验结果。
```

## 7. 参数参考

- `--lang zh|en`
- `--interactive`
- `--non-interactive`
- `--install-plugins yes|no`
- `--show-startup-tips always|once|off`
- `--set-default-shell yes|no`
- `--backup yes|no`
- `--optional-plugins p1/p2`
- `--dry-run`
- `--force`

## 8. 默认行为

- 未显式指定模式：
  - TTY => interactive
  - non-TTY => non-interactive
- `--backup` 默认 `yes`
- `--install-plugins` 默认 `yes`
- `--show-startup-tips` 默认 `always`
- 插件目录已存在：默认跳过，`--force` 时尝试更新

## 9. 已有 ~/.zshrc 处理规则

- interactive 模式会询问是否覆盖
- 默认先备份再写入
- 备份名：`.zshrc.backup-YYYYMMDD-xxxx`

## 10. 常见失败原因

- 无 `git`：插件拉取失败
- 无 `sudo` 且未安装 `zsh`：无法自动安装 zsh
- `chsh` 被系统策略限制：默认 shell 切换失败

## 11. 启动提示控制

- `--show-startup-tips off`
- `--show-startup-tips always`
- `--show-startup-tips once`

提示文件路径：
- `${XDG_CONFIG_HOME:-$HOME/.config}/zsh-ai-setup/startup-tip.txt`

## 12. 卸载

```bash
./uninstall.sh --interactive
./uninstall.sh --non-interactive --restore-backup yes --force
```

仅删除本项目管理内容，尽量恢复备份，不删除无关用户文件。

## 13. 语言选择

- 中文：`--lang zh`
- 英文：`--lang en`

安装提示、日志、启动提示模板都跟随该参数。
