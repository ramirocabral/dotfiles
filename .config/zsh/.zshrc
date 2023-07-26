stty stop undef

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Plugins

# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.powerlevel10k 
powerlevel10k=~/.local/src/powerlevel10k/powerlevel10k.zsh-theme
# curl -sL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh -o ~/.sudo.plugin.zsh
sudo=~/.sudo.plugin.zsh
# sudo pacman -S zsh-syntax-autosuggestions
autosuggestions=/usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# sudo pacman -S zsh-syntax-highlighting
syntax=/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
# ~/.fzf/install
fzf=~/.fzf.zsh

# Rest of plugins are sourced at the bottom
[[ -f $powerlevel10k ]] && source $powerlevel10k

# Vi mode
bindkey -v
export KEYTIMEOUT=1


# Aliases

[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc"

# Colors

typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=blue'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=blue'
ZSH_HIGHLIGHT_STYLES[path]='fg=blue'

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


#####################


# Source plugins

if [[ -f $sudo ]]; then
    source $sudo
fi

[[ -f $autosuggestions ]] && source $autosuggestions
[[ -f $syntax ]] && source $syntax

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

[[ -f $fzf ]] && source $fzf

# Functions

math() {
  echo $(( $@ ))
}

neofetch

source ~/.local/src/powerlevel10k/powerlevel10k.zsh-theme
