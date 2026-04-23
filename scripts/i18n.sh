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
      os_supported) echo "系统检测通过：支持 Ubuntu / Debian / WSL" ;;
      os_unsupported) echo "系统不受支持（仅 Ubuntu / Debian / WSL）" ;;
      dry_run) echo "dry-run 模式：仅预览，不写入" ;;
      need_yes_non_interactive) echo "非交互模式请显式传 --force" ;;
      confirm_overwrite) echo "检测到已有配置文件，是否覆盖？" ;;
      backup_done) echo "已创建备份" ;;
      write_done) echo "已写入" ;;
      write_skip) echo "内容未变化，跳过写入" ;;
      install_plugins) echo "开始安装插件" ;;
      plugin_skip) echo "插件已存在，跳过" ;;
      plugin_install_done) echo "插件安装完成" ;;
      zsh_missing) echo "未检测到 zsh，准备安装" ;;
      zsh_install_done) echo "zsh 安装完成" ;;
      omz_install_done) echo "Oh My Zsh 安装完成" ;;
      set_default_shell_ok) echo "已尝试设置默认 shell 为 zsh" ;;
      verify_title) echo "安装后校验建议" ;;
      verify_new_terminal) echo "打开新终端确认启动提示语言与模式" ;;
      install_success) echo "安装完成" ;;
      uninstall_success) echo "卸载完成" ;;
      restore_done) echo "已恢复备份" ;;
      restore_missing) echo "未找到可恢复备份" ;;
      removed_path) echo "已移除" ;;
      prompt_lang) echo "选择语言 (zh/en)" ;;
      prompt_install_plugins) echo "是否安装插件？(yes/no)" ;;
      prompt_startup_tips) echo "启动提示模式 (always/once/off)" ;;
      prompt_set_shell) echo "是否设置 zsh 为默认 shell？(yes/no)" ;;
      prompt_optional_plugins) echo "选择可选插件（逗号分隔，留空为不安装）" ;;
      err_arg) echo "参数错误" ;;
      err_need_git) echo "缺少 git，请先安装 git" ;;
      err_need_sudo) echo "需要 sudo 权限安装 zsh" ;;
      err_plugin_install) echo "插件安装失败" ;;
      err_chsh) echo "设置默认 shell 失败，请手动执行 chsh" ;;
      verify_cmds) echo "执行以下命令验证：echo $SHELL; zsh --version; command -v codex" ;;
      *) echo "$key" ;;
    esac
  else
    case "$key" in
      welcome) echo "Starting zsh-ai-setup installation" ;;
      uninstall_welcome) echo "Starting zsh-ai-setup uninstall" ;;
      os_supported) echo "Platform check passed: Ubuntu / Debian / WSL" ;;
      os_unsupported) echo "Unsupported OS (Ubuntu / Debian / WSL only)" ;;
      dry_run) echo "Dry-run mode: preview only, no writes" ;;
      need_yes_non_interactive) echo "In non-interactive mode, pass --force explicitly" ;;
      confirm_overwrite) echo "Existing config detected. Overwrite?" ;;
      backup_done) echo "Backup created" ;;
      write_done) echo "Written" ;;
      write_skip) echo "Unchanged content, skipped" ;;
      install_plugins) echo "Installing plugins" ;;
      plugin_skip) echo "Plugin exists, skipped" ;;
      plugin_install_done) echo "Plugin installation completed" ;;
      zsh_missing) echo "zsh not found, preparing installation" ;;
      zsh_install_done) echo "zsh installation completed" ;;
      omz_install_done) echo "Oh My Zsh installation completed" ;;
      set_default_shell_ok) echo "Attempted to set zsh as default shell" ;;
      verify_title) echo "Post-install verification" ;;
      verify_new_terminal) echo "Open a new terminal and verify startup tip language/mode" ;;
      install_success) echo "Installation completed" ;;
      uninstall_success) echo "Uninstall completed" ;;
      restore_done) echo "Backup restored" ;;
      restore_missing) echo "No backup found to restore" ;;
      removed_path) echo "Removed" ;;
      prompt_lang) echo "Choose language (zh/en)" ;;
      prompt_install_plugins) echo "Install plugins? (yes/no)" ;;
      prompt_startup_tips) echo "Startup tips mode (always/once/off)" ;;
      prompt_set_shell) echo "Set zsh as default shell? (yes/no)" ;;
      prompt_optional_plugins) echo "Choose optional plugins (comma-separated, empty = none)" ;;
      err_arg) echo "Argument error" ;;
      err_need_git) echo "git is required" ;;
      err_need_sudo) echo "sudo is required to install zsh" ;;
      err_plugin_install) echo "Plugin installation failed" ;;
      err_chsh) echo "Failed to set default shell; run chsh manually" ;;
      verify_cmds) echo "Run: echo $SHELL; zsh --version; command -v codex" ;;
      *) echo "$key" ;;
    esac
  fi
}
