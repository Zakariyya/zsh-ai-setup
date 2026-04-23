# zsh-ai-setup

一个把你真实 Zsh 配置打包成可复用工具集的项目，目标系统为 Ubuntu / Debian / WSL。

本项目以以下文件为唯一真源：
- `configs/.zshrc`
- `configs/.zshenv`

不会用通用模板替换你的配置。

## 项目目标

1. 人类用户可快速安装复用。
2. AI 代理可按固定参数无歧义执行。
3. 支持安全重跑、幂等与覆盖前备份。

## 目录结构

```text
zsh-ai-setup/
├─ install.sh
├─ uninstall.sh
├─ README.md
├─ README.zh-CN.md
├─ AI_SETUP.md
├─ configs/
│  ├─ .zshrc
│  ├─ .zshenv
│  ├─ aliases.zsh
│  ├─ exports.zsh
│  └─ plugins.zsh
├─ scripts/
│  ├─ i18n.sh
│  ├─ lib.sh
│  ├─ detect_os.sh
│  ├─ install_zsh.sh
│  └─ install_plugins.sh
├─ templates/
│  ├─ startup-tip.zh.txt
│  └─ startup-tip.en.txt
└─ docs/
   ├─ customization.md
   └─ ai-usage.md
```

## 支持系统

- Ubuntu
- Debian
- WSL

当前不覆盖：
- 原生 Windows
- macOS（仅预留扩展点）

## 交互安装

```bash
chmod +x install.sh uninstall.sh scripts/*.sh
./install.sh --interactive
```

交互项包括：
- 语言
- 可选插件
- 启动提示模式
- 是否设置默认 shell

## 非交互安装

固定参数方向：
- `--lang zh|en`
- `--interactive`
- `--non-interactive`
- `--install-plugins yes|no`
- `--show-startup-tips always|once|off`
- `--set-default-shell yes|no`
- `--backup yes|no`
- `--dry-run`
- `--force`

示例：

```bash
./install.sh --lang zh --non-interactive --install-plugins yes --show-startup-tips off --set-default-shell yes --backup yes
./install.sh --lang en --non-interactive --install-plugins no --show-startup-tips once --set-default-shell no --backup yes --dry-run
```

## 处理已有 ~/.zshrc

- 交互模式会询问是否覆盖。
- 默认先备份再写入。
- 备份名格式：
  - `.zshrc.backup-YYYYMMDD-xxxx`
- 安全控制：
  - `--backup yes|no`
  - `--dry-run`
  - `--force`

## 启动提示

支持三种模式：
- `always`
- `once`
- `off`

提示内容按所选语言，从模板加载。

## 插件安装

必需外部插件：
- `zsh-autosuggestions`
- `zsh-syntax-highlighting`

可选外部插件：
- `zsh-completions`
- `fzf-tab`

安装目录：
- `${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins`

重跑策略：
- 已存在默认跳过
- `--force` 时尝试 `git pull --ff-only` 更新

## 卸载

```bash
./uninstall.sh --interactive
./uninstall.sh --non-interactive --restore-backup yes --force
```

卸载策略偏保守：
- 仅删除本项目管理的内容
- 能恢复备份则恢复
- 不删除无关用户文件

## 校验

```bash
echo $SHELL
zsh --version
test -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
test -f ~/.zshrc
zsh -n ~/.zshrc
zsh -n ~/.zshenv
```

重开终端，确认启动提示语言和模式符合预期。

## 参考

插件安装采用 Oh My Zsh `custom/plugins` 的 git-clone 方式，可参考：
- https://github.com/Zakariyya/blog/issues/175
