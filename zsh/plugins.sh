#!/usr/bin/env bash

# bootstrapping oh-my-zsh with custom plugins
# this script should ideally only execute in its entirety once.

ZSH_CUSTOM=${ZSH_CUSTOM:-$ZSH/custom}

github_plugins=(
    zsh-users/zsh-autosuggestions
    zsh-users/zsh-syntax-highlighting
    jeffreytse/zsh-vi-mode
)

for plugin in "${github_plugins[@]}"; do
    repo_name=${plugin##*/}

    if [[ ! -d $ZSH_CUSTOM/plugins/$repo_name ]]; then
        mkdir -p $ZSH_CUSTOM/plugins
        git clone --depth 1 --recursive "https://github.com/$plugin.git" "$ZSH_CUSTOM/plugins/$repo_name"
    fi

    # try loading plugin after cloning
    for initscript in "$repo_name.zsh" "$repo_name.plugin.zsh" "$repo_name.sh"; do
        if [[ -f "$ZSH_CUSTOM/plugins/$repo_name/$initscript" ]]; then
            source "$ZSH_CUSTOM/plugins/$repo_name/$initscript"
            break
        fi
    done
done

# cleanup
unset github_plugins
unset plugin
unset repo_name
unset initscript
