###------- OH-MY-ZSH -------###
export ZSH="$ZDOTDIR/ohmyzsh"
ZSH_THEME="robbyrussell"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

###------- SOURCE -------###
source $ZDOTDIR/plugins.sh # installs plugins not already available in omz
source $ZSH/oh-my-zsh.sh

###------- ALIAS -------###
alias wget=wget --hsts-file="$XDG_DATA_HOME/wget-hsts"
alias ls="eza --icons -a -F -H --group-directories-first --git"
alias ll="eza --icons -alF"
alias tree="eza --tree"
alias rum="rummage get"
alias pull="git pull --rebase"
alias brewu="brew update && brew upgrade"
alias gitlog="git log --pretty=format:'%C(cyan)%h%Creset %C(yellow)%ad%Creset %Cgreen%s%Creset'"

###------- OPTS --------###
setopt INTERACTIVE_COMMENTS
setopt HIST_SAVE_NO_DUPS

###------- PATH --------###
export PATH=~/.local/bin/:$PATH
export PATH=$PATH:$GOPATH/bin
export PATH=$PATH:$CARGO_HOME/bin
export PATH=/opt/homebrew/bin:$PATH
export ZVM_VI_INSERT_ESCAPE_BINDKEY=jk

###------- MISC --------###
if [[ $TERM == "xterm-ghostty" ]]; then
    export TERM="xterm-256color"
fi

###------- EVALS -------###
# a smarter cd command, see https://github.com/ajeetdsouza/zoxide for more info
eval "$(zoxide init --cmd cd zsh)"
