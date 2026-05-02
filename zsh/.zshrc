# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- Environment Setup ---
export TERM="xterm-256color"
export COLORTERM="truecolor"
export XDG_CONFIG_HOME="$HOME/.config"
export DOTFILES_DIR="$HOME/termux-dotfiles"

# --- User Identity ---
USER_NAME_FILE="$HOME/.user_name"
if [ -f "$USER_NAME_FILE" ]; then
    export MY_USER=$(cat "$USER_NAME_FILE")
else
    export MY_USER="davidf1121"
fi
export FASTFETCH_TITLE_FQDN="$MY_USER@termux"

# Function to change your displayed name
function setname() {
    if [ -n "$1" ]; then
        echo "$1" > "$HOME/.user_name"
        export MY_USER="$1"
        export FASTFETCH_TITLE_FQDN="$1@termux"
        echo "User name updated to: $1"
        source ~/.zshrc
    else
        echo "Usage: setname <new_name>"
    fi
}

# --- Startup ---
export PATH="$HOME/.local/bin:$HOME/termux-dotfiles/bin:$PATH"



# --- Oh My Zsh Configuration ---
export ZSH="$HOME/.oh-my-zsh"
export ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Order matters: fzf-tab should be loaded before other plugins that use completion
plugins=(
  git 
  zsh-autosuggestions 
  zsh-syntax-highlighting 
  fzf-tab
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# --- Minecraft-style Completion (fzf-tab & autosuggestions) ---
# Use Right Arrow or End to accept the ghost-text suggestion
bindkey '^[[C' forward-word
bindkey '^[[F' end-of-line

# fzf-tab configuration
# Disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'

# --- Atuin History ---
if command -v atuin > /dev/null 2>&1; then
    # Disable up-arrow so it uses standard Zsh history
    # This keeps Atuin only for Ctrl-r (Full Search)
    eval "$(atuin init zsh --disable-up-arrow)"
fi

if command -v zoxide > /dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

# --- FZF Setup ---
if command -v fzf > /dev/null 2>&1; then
    # We load fzf but disable its default completion to let fzf-tab take over
    if fzf --zsh > /dev/null 2>&1; then
        source <(fzf --zsh)
    else
        [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
    fi
    # Re-bind Tab to standard completion (which fzf-tab will then intercept)
    bindkey '^I' expand-or-complete
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

# --- Music Player (Python + mpv) ---
# Custom music player at ~/termux-dotfiles/bin/music.py
if [ -f "$HOME/termux-dotfiles/bin/music.py" ]; then
    # Ensure PulseAudio is running for audio
    if command -v pulseaudio > /dev/null 2>&1; then
        pulseaudio -D --exit-idle-time=-1 2>/dev/null
    fi
    
    alias m='python3 $HOME/termux-dotfiles/bin/music.py'
    alias p=m
    alias play='python3 $HOME/termux-dotfiles/bin/music.py play'
    alias pause='python3 $HOME/termux-dotfiles/bin/music.py pause'
    alias mnext='python3 $HOME/termux-dotfiles/bin/music.py next'
    alias mprev='python3 $HOME/termux-dotfiles/bin/music.py prev'
    alias mstop='python3 $HOME/termux-dotfiles/bin/music.py stop'
    alias minfo='python3 $HOME/termux-dotfiles/bin/music.py info'
fi

# Custom clear behavior: clear screen and show welcome + fastfetch
function cls() {
    command clear
    echo -e "\e[1;34m󰀵 \e[0m\e[1;36mWelcome back, $MY_USER \e[0m\e[1;34m󰀵\e[0m"
    echo -e "\e[3;90mEnvironment active and ready...\e[0m\n"
    if command -v fastfetch > /dev/null 2>&1; then
        fastfetch -c ~/.config/fastfetch/config.jsonc --pipe false
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

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Simple interactive branding
[[ $- == *i* ]] && cls
