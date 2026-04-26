# --- Startup ---
# Display system info
if command -v fastfetch > /dev/null 2>&1; then
    fastfetch -c ~/.config/fastfetch/config.jsonc
fi

# --- Oh My Zsh Configuration ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="" # Let Starship handle the prompt
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# --- Tool Initializations ---
[[ -x "$(command -v starship)" ]] && eval "$(starship init zsh)"
[[ -x "$(command -v zoxide)" ]] && eval "$(zoxide init zsh)"
if command -v fzf > /dev/null 2>&1; then
    # Use modern fzf initialization if available (fzf 0.48+)
    fzf --zsh > /dev/null 2>&1 && source <(fzf --zsh) || source /usr/share/doc/fzf/examples/key-bindings.zsh 2>/dev/null
fi

# --- Aliases ---
# Modern replacements
if command -v batcat > /dev/null 2>&1; then
    alias bat='batcat'
fi

alias ls='eza'
alias ll='eza -lah'
alias la='eza -a'
alias lt='eza --tree --level=2'
alias cat='bat'
alias top='btop'
alias fm='ranger'
alias ff='fastfetch'
alias mux='tmux'

# Utilities
alias matrix='cmatrix -C blue'
alias weather='curl -s wttr.in | head -n 7'
alias z='zoxide'
alias findf='fzf'
alias zrc='source ~/.zshrc'
alias ezrc='nano ~/.zshrc'

# --- Functions ---
# Custom clear behavior: clear screen and show fastfetch
function cls() {
    command clear
    if command -v fastfetch > /dev/null 2>&1; then
        fastfetch -c ~/.config/fastfetch/config.jsonc
    fi
}
alias clear='cls'

# Search files and preview with bat
function fdown() {
  if command -v fzf > /dev/null 2>&1; then
    if command -v bat > /dev/null 2>&1; then
      fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'
    elif command -v batcat > /dev/null 2>&1; then
      fzf --preview 'batcat --style=numbers --color=always --line-range :500 {}'
    else
      fzf --preview 'cat {}'
    fi
  else
    echo "fzf is not installed."
  fi
}

# Yazi with auto-cd on exit
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd "$cwd"
    fi
    rm -f "$tmp"
}

# --- Keybindings ---
bindkey '^R' fzf-history-widget
