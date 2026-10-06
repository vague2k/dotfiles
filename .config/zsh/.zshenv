export EDITOR=nvim

###------- XDG SPEC -------###

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export XDG_DATA_DIRS="/usr/local/share:/usr/share"
export XDG_CONFIG_DIRS="/etc/xdg"

###------- EXPORTS -------###

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export ANDROID_HOME="$XDG_DATA_HOME/android"
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"
export GOPATH="$XDG_DATA_HOME/go"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export HISTFILE="$XDG_STATE_HOME/zsh/history"
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/.npmrc"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export CUDA_CACHE_PATH="$XDG_CACHE_HOME/nv"
export TERMINFO="$XDG_DATA_HOME"/terminfo
export TERMINFO_DIRS="$XDG_DATA_HOME"/terminfo:/usr/share/terminfo
export TLDR_CACHE_DIR="$XDG_CACHE_HOME"/tldr

export FZF_DEFAULT_OPTS="
    --height=99%
    --layout=reverse
    --pointer='█'
    --scrollbar='▌'
    --highlight-line
    --color=hl:#f3be7c
    --color=bg:-1
    --color=gutter:-1
    --color=bg+:#252532
    --color=fg+:#aeaed1
    --color=hl+:#f3be7c
    --color=border:#606079
    --color=prompt:#bb9dbd
    --color=query:#aeaed1:bold
    --color=pointer:#aeaed1
    --color=scrollbar:#aeaed1
    --color=info:#f3be7c
    --color=spinner:#7fa563
    "
