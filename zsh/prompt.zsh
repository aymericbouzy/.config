# starship (CLI prompt: https://starship.rs)
eval "$(starship init zsh)"
alias prompt="open https://starship.rs/config/#prompt && $EDITOR ~/.config/starship.toml"

# zsh-autosuggestions
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# thefuck https://github.com/nvbn/thefuck
eval $(thefuck --alias please)

# z (go anywhere easily)
source /usr/local/etc/profile.d/z.sh

# syntax highlighting
source /usr/local/opt/zsh-fast-syntax-highlighting/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

alias c=clear
