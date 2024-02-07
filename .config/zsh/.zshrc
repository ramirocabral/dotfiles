stty stop undef

# Plugins

# curl -sL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh -o ~/.sudo.plugin.zsh
sudo=~/.sudo.plugin.zsh
# sudo pacman -S zsh-syntax-autosuggestions
autosuggestions=/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# sudo pacman -S zsh-syntax-highlighting
# syntax=/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
# ~/.fzf/install
fzf=~/.fzf.zsh


# Vi mode
bindkey -v
export KEYTIMEOUT=1

# Aliases

[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc"


# Colors

# typeset -A ZSH_HIGHLIGHT_STYLES
# ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=magenta'
# ZSH_HIGHLIGHT_STYLES[precommand]='fg=magenta'
# ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=magenta'
# ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red'
# ZSH_HIGHLIGHT_STYLES[redirection]='fg=cyan'
# ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=cyan'
# ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=blue'
# ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=blue'
# ZSH_HIGHLIGHT_STYLES[path]='fg=blue'

# History

HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.cache/zsh/history

# Autocomplete

setopt autocd
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list '' \
  'm:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:|?=** m:{a-z\-}={A-Z\_}'
zmodload zsh/complist
autoload -Uz compinit
compinit

# Git Status

## Autoload zsh add-zsh-hook and vcs_info functions (-U autoload w/o substition, -z use zsh style)
autoload -Uz add-zsh-hook vcs_info
# Enable substitution in the prompt.
setopt prompt_subst
# Run vcs_info just before a prompt is displayed (precmd)
add-zsh-hook precmd vcs_info
zstyle ':vcs_info:*' formats ' %F{yellow}%s%f(%F{red}%b%f)' # git(main)

#####################


# Source plugins

if [[ -f $sudo ]]; then
    source $sudo
fi

[[ -f $autosuggestions ]] && source $autosuggestions
[[ -f $syntax ]] && source $syntax
[[ -f $fzf ]] && source $fzf
source ~/.local/share/gitstatus/gitstatus.prompt.zsh

# Functions

math() {
  echo $(( $@ ))
}

# Ctrl + L to accept autosuggestions
bindkey '^L' autosuggest-accept

# Prompt
PROMPT='%F{red}[%f%f%F{yellow}%n%f%F{green}@%f%F{cyan}%m%f %F{magenta}%~%f %F{red}]%f $ '
# Using git status:
# PS1='%F{red}[%f%f%F{yellow}%n%f%F{green}@%f%F{cyan}%m%f %F{magenta}%~%f ${GITSTATUS_PROMPT}%F{red}]%f $ '
RPROMPT='[%D{%H:%M:%S}] '$RPROMPT
