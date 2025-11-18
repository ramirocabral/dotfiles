stty stop undef

# curl -sL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh -o ~/.sudo.plugin.zsh
sudo=~/.sudo.plugin.zsh
# sudo pacman -S zsh-syntax-autosuggestions
autosuggestions=/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# sudo pacman -S zsh-syntax-highlighting
syntax=/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
# ~/.fzf/install
fzf=~/.fzf.zsh

# Vi mode
bindkey -v
export KEYTIMEOUT=1

# Aliases
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc"

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

## Autoload zsh add-zsh-hook and vcs_info functions (-U autoload w/o substition, -z use zsh style)
autoload -Uz add-zsh-hook vcs_info
# Enable substitution in the prompt.
setopt prompt_subst
# Run vcs_info just before a prompt is displayed (precmd)
add-zsh-hook precmd vcs_info
zstyle ':vcs_info:*' formats ' %F{yellow}%s%f(%F{red}%b%f)' # git(main)

# Source plugins
if [[ -f $sudo ]]; then
    source $sudo
fi

[[ -f $autosuggestions ]] && source $autosuggestions
[[ -f $syntax ]] && source $syntax
[[ -f $fzf ]] && source $fzf
source ~/.local/src/gitstatus/gitstatus.prompt.zsh

# Functions
math() {
  echo $(( $@ ))
}

# Enable history search with fzf
eval "$(fzf --zsh)"

# Ctrl + F to search history with fzf
bindkey '^F' fzf-history-widget
# Ctrl + L to accept autosuggestions
bindkey '^L' autosuggest-accept

source '/opt/kube-ps1/kube-ps1.sh'

# Prompt
PROMPT='%{%F{40}%}%n%{%F{40}%}@%{%F{40}%}%m%f:%{%F{33}%}%~%f %f$ '
# Using git status:
PROMPT='%{%F{40}%}%n%{%F{40}%}@%{%F{40}%}%m%f:%{%F{33}%}%~%f ${GITSTATUS_PROMPT} %f$ '
# kube-ps1 prompt
PROMPT='$(kube_ps1)'$PROMPT

# show time in right promp
RPROMPT='[%D{%H:%M:%S}]'$RPROMPT
