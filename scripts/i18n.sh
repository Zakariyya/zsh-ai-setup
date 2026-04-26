#!/usr/bin/env bash

I18N_LANG="en"

set_i18n_lang() {
  case "${1:-en}" in
    zh|zh-CN) I18N_LANG="zh" ;;
    en|en-US) I18N_LANG="en" ;;
    *)
      if [[ "${LANG:-}" == zh* || "${LANG:-}" == ZH* ]]; then
        I18N_LANG="zh"
      else
        I18N_LANG="en"
      fi
      ;;
  esac
}

i18n_msg() {
  local key="$1"
  if [[ "$I18N_LANG" == "zh" ]]; then
    case "$key" in
      welcome) echo "开始安装 zsh-ai-setup" ;;
      uninstall_welcome) echo "开始卸载 zsh-ai-setup" ;;
      os_supported) echo "系统检测通过：支持 Ubuntu / Debian 系（含 Deepin）/ WSL" ;;
      os_unsupported) echo "系统不受支持（仅 Ubuntu / Debian 系（含 Deepin）/ WSL）" ;;
      dry_run) echo "dry-run 模式：仅预览，不写入" ;;
      need_yes_non_interactive) echo "非交互模式请显式传 --force" ;;
      confirm_overwrite) echo "检测到已有配置文件，是否覆盖？" ;;
      backup_done) echo "已创建备份" ;;
      write_done) echo "已写入" ;;
      write_skip) echo "内容未变化，跳过写入" ;;
      stage_questions) echo "交互配置" ;;
      stage_depcheck) echo "依赖检查" ;;
      stage_prepare) echo "准备环境与写入配置" ;;
      stage_plugins) echo "插件安装阶段" ;;
      stage_finalize) echo "收尾与校验" ;;
      install_plugins) echo "开始安装插件" ;;
      plugin_skip) echo "插件已存在，跳过" ;;
      plugin_install_done) echo "插件安装完成" ;;
      install_thefuck) echo "开始安装 thefuck 命令" ;;
      thefuck_exists) echo "thefuck 已存在，跳过安装" ;;
      thefuck_install_done) echo "thefuck 安装完成" ;;
      zsh_missing) echo "未检测到 zsh，准备安装" ;;
      zsh_install_done) echo "zsh 安装完成" ;;
      omz_install_done) echo "Oh My Zsh 安装完成" ;;
      set_default_shell_ok) echo "已尝试设置默认 shell 为 zsh" ;;
      verify_title) echo "安装后校验建议" ;;
      verify_new_terminal) echo "打开新终端确认启动提示语言与模式" ;;
      install_success) echo "安装完成" ;;
      startup_tip_mode_updated) echo "已更新启动提示模式并结束（未执行安装）" ;;
      uninstall_success) echo "卸载完成" ;;
      restore_done) echo "已恢复备份" ;;
      restore_missing) echo "未找到可恢复备份" ;;
      removed_path) echo "已移除" ;;
      prompt_lang) echo "选择语言（1 中文 / 2 English）" ;;
      prompt_install_plugins) echo "是否安装插件？（1 是 / 2 否，回车默认 1）" ;;
      prompt_tab_threshold_enable) echo "是否自定义 Tab 连击判定秒数？（1 是 / 2 否，回车默认 2）" ;;
      prompt_tab_threshold_value) echo "请输入 Tab 连击判定秒数（示例：0.25/0.35/0.45，回车默认 0.25）" ;;
      prompt_startup_tips) echo "启动提示模式（1 总是 / 2 仅首次 / 3 关闭，回车默认 1）" ;;
      prompt_set_shell) echo "是否设置 zsh 为默认 shell？（1 是 / 2 否，回车默认 1）" ;;
      prompt_optional_plugins) echo "选择可选插件（输入编号，斜杠 / 分隔；1=全选；回车默认全选）" ;;
      optional_plugins_title) echo "可选插件列表" ;;
      optional_plugins_all) echo "1) 全选" ;;
      optional_plugins_none) echo "n) 不安装可选插件" ;;
      plugin_desc_zsh_completions) echo "补全增强（命令/参数补全）" ;;
      plugin_desc_fzf_tab) echo "Tab 模糊选择增强" ;;
      plugin_desc_thefuck) echo "命令纠错工具（fuck）" ;;
      git_missing) echo "未检测到 git，准备安装" ;;
      git_install_done) echo "git 安装完成" ;;
      err_arg) echo "参数错误" ;;
      err_need_git) echo "缺少 git，请先安装 git" ;;
      err_need_sudo) echo "需要 sudo 权限安装 zsh" ;;
      err_plugin_install) echo "插件安装失败" ;;
      err_thefuck_install) echo "thefuck 安装失败，请检查 apt/pipx/pip 环境后重试" ;;
      warn_chsh_non_tty) echo "当前不是交互式终端，已跳过默认 shell 切换；请安装完成后手动执行：chsh -s \"\$(command -v zsh)\"" ;;
      err_chsh) echo "设置默认 shell 失败，请手动执行 chsh" ;;
      verify_cmds) echo "执行以下命令验证：echo $SHELL; zsh --version; command -v codex" ;;
      *) echo "$key" ;;
    esac
  else
    case "$key" in
      welcome) echo "Starting zsh-ai-setup installation" ;;
      uninstall_welcome) echo "Starting zsh-ai-setup uninstall" ;;
      os_supported) echo "Platform check passed: Ubuntu / Debian family (including Deepin) / WSL" ;;
      os_unsupported) echo "Unsupported OS (Ubuntu / Debian family including Deepin / WSL only)" ;;
      dry_run) echo "Dry-run mode: preview only, no writes" ;;
      need_yes_non_interactive) echo "In non-interactive mode, pass --force explicitly" ;;
      confirm_overwrite) echo "Existing config detected. Overwrite?" ;;
      backup_done) echo "Backup created" ;;
      write_done) echo "Written" ;;
      write_skip) echo "Unchanged content, skipped" ;;
      stage_questions) echo "Interactive setup" ;;
      stage_depcheck) echo "Dependency check" ;;
      stage_prepare) echo "Prepare environment and write config" ;;
      stage_plugins) echo "Plugin installation stage" ;;
      stage_finalize) echo "Finalize and verify" ;;
      install_plugins) echo "Installing plugins" ;;
      plugin_skip) echo "Plugin exists, skipped" ;;
      plugin_install_done) echo "Plugin installation completed" ;;
      install_thefuck) echo "Installing thefuck command" ;;
      thefuck_exists) echo "thefuck already exists, skipped" ;;
      thefuck_install_done) echo "thefuck installation completed" ;;
      zsh_missing) echo "zsh not found, preparing installation" ;;
      zsh_install_done) echo "zsh installation completed" ;;
      omz_install_done) echo "Oh My Zsh installation completed" ;;
      set_default_shell_ok) echo "Attempted to set zsh as default shell" ;;
      verify_title) echo "Post-install verification" ;;
      verify_new_terminal) echo "Open a new terminal and verify startup tip language/mode" ;;
      install_success) echo "Installation completed" ;;
      startup_tip_mode_updated) echo "Startup tip mode updated (no install actions executed)" ;;
      uninstall_success) echo "Uninstall completed" ;;
      restore_done) echo "Backup restored" ;;
      restore_missing) echo "No backup found to restore" ;;
      removed_path) echo "Removed" ;;
      prompt_lang) echo "Choose language (1 Chinese / 2 English)" ;;
      prompt_install_plugins) echo "Install plugins? (1 yes / 2 no, Enter defaults to 1)" ;;
      prompt_tab_threshold_enable) echo "Customize Tab double-tap threshold seconds? (1 yes / 2 no, Enter defaults to 2)" ;;
      prompt_tab_threshold_value) echo "Enter Tab double-tap threshold seconds (examples: 0.25/0.35/0.45, Enter defaults to 0.25)" ;;
      prompt_startup_tips) echo "Startup tips mode (1 always / 2 once / 3 off, Enter defaults to 1)" ;;
      prompt_set_shell) echo "Set zsh as default shell? (1 yes / 2 no, Enter defaults to 1)" ;;
      prompt_optional_plugins) echo "Choose optional plugins (numbers, slash-separated '/'; 1=all; Enter defaults to all)" ;;
      optional_plugins_title) echo "Optional plugins" ;;
      optional_plugins_all) echo "1) Select all" ;;
      optional_plugins_none) echo "n) Install no optional plugins" ;;
      plugin_desc_zsh_completions) echo "extra command and argument completions" ;;
      plugin_desc_fzf_tab) echo "fuzzy Tab selection enhancements" ;;
      plugin_desc_thefuck) echo "command fixer (fuck)" ;;
      git_missing) echo "git not found, preparing installation" ;;
      git_install_done) echo "git installation completed" ;;
      err_arg) echo "Argument error" ;;
      err_need_git) echo "git is required" ;;
      err_need_sudo) echo "sudo is required to install zsh" ;;
      err_plugin_install) echo "Plugin installation failed" ;;
      err_thefuck_install) echo "thefuck installation failed; check apt/pipx/pip and retry" ;;
      warn_chsh_non_tty) echo "No interactive TTY detected; skipped default shell switch. Run: chsh -s \"\$(command -v zsh)\" after install" ;;
      err_chsh) echo "Failed to set default shell; run chsh manually" ;;
      verify_cmds) echo "Run: echo $SHELL; zsh --version; command -v codex" ;;
      *) echo "$key" ;;
    esac
  fi
}
