stty stop undef

# History
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.cache/zsh/history

setopt EXTENDED_HISTORY # Save timestamp of each command in history file
setopt HIST_REDUCE_BLANKS # Remove superfluous blanks from each command in history
setopt INC_APPEND_HISTORY # Immediately append commands to the history file
setopt SHARE_HISTORY  # Share history across all sessions

export FZF_CTRL_R_OPTS="--sort --exact --tiebreak=index"

autosuggestions=/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
syntax=/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Vi mode
bindkey -v
export KEYTIMEOUT=1

# Aliases
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc"

# Autocomplete
ZSH_AUTOSUGGEST_STRATEGY=(history)
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

# Function to reload history before each prompt
force_reload_history() {
    fc -R
}
add-zsh-hook precmd force_reload_history

[[ -f $autosuggestions ]] && source $autosuggestions
[[ -f $syntax ]] && source $syntax
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
