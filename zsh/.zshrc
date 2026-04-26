# --- Startup ---
# Display system info
fastfetch -c ~/.config/fastfetch/config.jsonc

# --- Oh My Zsh Configuration ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="" # Let Starship handle the prompt
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

# --- Tool Initializations ---
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
source <(fzf --zsh)

# --- Aliases ---
# Modern replacements
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
    fastfetch -c ~/.config/fastfetch/config.jsonc
}
alias clear='cls'

# Search files and preview with bat
function fdown() {
  fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'
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
