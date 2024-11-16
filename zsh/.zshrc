###------- OH-MY-ZSH -------###
export ZSH="$ZDOTDIR/ohmyzsh"
ZSH_THEME="robbyrussell"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

###------- SOURCE -------###
source $ZSH/oh-my-zsh.sh
source $ZDOTDIR/plugins.sh # installs plugins not already available in omz

###------- ALIAS -------###
alias wget=wget --hsts-file="$XDG_DATA_HOME/wget-hsts"
alias ls="eza --icons -a -F -H --group-directories-first --git"
alias ll="eza --icons -alF"
alias rum="rummage get"

###------- OPTS --------###
setopt interactivecomments

###------- EVALS -------###
# a smarter cd command, see https://github.com/ajeetdsouza/zoxide for more info
eval "$(zoxide init --cmd cd zsh)"

