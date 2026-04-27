# --- Startup ---
export PATH="$HOME/.local/bin:$PATH"

# Display system info
if command -v fastfetch > /dev/null 2>&1; then
    fastfetch -c ~/.config/fastfetch/config.jsonc
fi

# --- Oh My Zsh Configuration ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="" # Let Starship handle the prompt
plugins=(git zsh-syntax-highlighting zsh-autosuggestions)

# Load Oh My Zsh if it exists
if [ -f "$ZSH/oh-my-zsh.sh" ]; then
    source "$ZSH/oh-my-zsh.sh"
fi

# --- Tool Initializations ---
if command -v starship > /dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

if command -v zoxide > /dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

if command -v fzf > /dev/null 2>&1; then
    # Use modern fzf initialization if available (fzf 0.48+)
    if fzf --zsh > /dev/null 2>&1; then
        source <(fzf --zsh)
    else
        # Fallback to standard locations
        [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
        [ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
        [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
    fi
fi

# --- Aliases ---
# Modern replacements
if command -v eza > /dev/null 2>&1; then
    alias ls='eza'
    alias ll='eza -lah'
    alias la='eza -a'
    alias lt='eza --tree --level=2'
fi

if command -v batcat > /dev/null 2>&1; then
    alias bat='batcat'
    alias cat='batcat'
elif command -v bat > /dev/null 2>&1; then
    alias cat='bat'
fi

if command -v ranger > /dev/null 2>&1; then
    alias fm='ranger'
fi

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

# Search files and preview with bat/cat
function fdown() {
  if command -v fzf > /dev/null 2>&1; then
    local preview_cmd="cat {}"
    if command -v batcat > /dev/null 2>&1; then
      preview_cmd="batcat --style=numbers --color=always --line-range :500 {}"
    elif command -v bat > /dev/null 2>&1; then
      preview_cmd="bat --style=numbers --color=always --line-range :500 {}"
    fi
    fzf --preview "$preview_cmd"
  else
    echo "fzf is not installed."
  fi
}

# --- Yazi with auto-cd on exit ---
if command -v yazi > /dev/null 2>&1; then
    function y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
        yazi "$@" --cwd-file="$tmp"
        if cwd="$(cat "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            cd "$cwd"
        fi
        rm -f "$tmp"
    }
fi
