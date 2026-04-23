# zsh-ai-setup plugin profile
# Required external plugins: install via git clone into Oh My Zsh custom/plugins.
typeset -ga ZSH_AI_REQUIRED_EXTERNAL_PLUGINS
ZSH_AI_REQUIRED_EXTERNAL_PLUGINS=(
  zsh-autosuggestions
  zsh-syntax-highlighting
)

# Optional external plugins: selected during installer interaction.
# Optional plugins are managed by install.sh and can be extended later.
typeset -ga ZSH_AI_OPTIONAL_EXTERNAL_PLUGINS
ZSH_AI_OPTIONAL_EXTERNAL_PLUGINS=(
  zsh-completions
  fzf-tab
)

# Effective plugin list for Oh My Zsh.
plugins=(
  git
  z
  sudo
  history-substring-search
  zsh-autosuggestions
  zsh-syntax-highlighting
)
