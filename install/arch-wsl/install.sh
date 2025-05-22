#!/usr/bin/env bash

# This script is meant to be run by running this command in the terminal
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/vague2k/dotfiles/main/install/arch-wsl/install.sh)"

set -e

# the next 4 lines was ripped straight from the omz install script
# $HOME is defined at the time of login, but it could be unset. If it is unset,
# a tilde by itself (~) will not be expanded to the current user's home directory.
# POSIX: https://pubs.opengroup.org/onlinepubs/009696899/basedefs/xbd_chap08.html#tag_08_03
HOME="${HOME:-$(getent passwd $USER 2>/dev/null | cut -d: -f6)}"

GIT_DIR="$HOME/Documents/Github"
DOT_DIR="$GIT_DIR/dotfiles"
PACKAGES=(
    "arch-install-scripts"
    "base"
    "base-devel"
    "eza"
    "fd"
    "git"
    "github-cli"
    "glow"
    "go"
    "lazygit"
    "less"
    "lf"
    "lua"
    "nano"
    "neovim"
    "npm"
    "python"
    "python-pynvim"
    "rust"
    "stylua"
    "sudo"
    "tmux"
    "unzip"
    "vim"
    "ripgrep"
    "rust"
    "wget"
    "zoxide"
    "zsh"
)

### install yay first
cd $HOME # make sure we're in home dir
if command -v yay >/dev/null; then
    echo "yay is installed..."
    echo "i'm going to assume this script has been ran before and exit early..."
    return 0
else
    sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
fi

### compare PACKAGES with what's been installed so far,
### only install what hasn't been installed yet
installed_packages=$(pacman -Qe | awk '{print $1}')
to_install=()
for package in "${PACKAGES[@]}"; do
    if ! echo "$installed_packages" | grep -q "^$package$"; then
        to_install+=("$package")
    else
        echo "Installed... skipping: $package"
    fi
done
yay -S ${to_install[@]}
rm -rf ~/yay

### start cloning some repos
mkdir -p $GIT_DIR
cd $GIT_DIR

# these repos are all public, we set git creds later
git clone https://github.com/vague2k/huez.nvim.git
git clone https://github.com/vague2k/vague.nvim.git
git clone https://github.com/vague2k/rummage.git
git clone https://github.com/vague2k/smv.git
git clone https://github.com/vague2k/dotfiles.git

# make dotfile symlinks
cd $DOT_DIR
chmod +x ./mklinks 
./mklinks

zoxide add $GIT_DIR
zoxide add $GIT_DIR/huez.nvim
zoxide add $GIT_DIR/vague.nvim
zoxide add $GIT_DIR/rummage
zoxide add $GIT_DIR/smv
zoxide add $DOT_DIR
zoxide add ~/.config
zoxide add ~/.local

# set up tmux plugin manager
mkdir -p $DOT_DIR/tmux/plugins
git clone https://github.com/tmux-plugins/tpm $DOT_DIR/tmux/plugins/tpm

# set git creds
gh auth login

git config --global user.name "vague2k"
git config --global user.email "ilovedrawing056@gmail.com" # this email is public knowledge idc that it's in the script, plus it's my spam email lol

# setup zsh
cd $DOT_DIR/zsh

wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
export ZSH=~/.config/zsh/ohmyzsh 
export CHSH="yes" 
export RUNZSH="no" 

sh install.sh

zsh -c "cp $HOME/Documents/Github/dotfiles/zsh/.zshenv ~/.zshenv; 
rm ~/.bash*;
rm ~/.shell*;
rm ~/.zcompdump*;
rm ~/.zshrc;
source ~/.zshenv;
source $HOME/Documents/Github/dotfiles/zsh/.zshrc;
"

rm install.sh

echo ""
echo "Done. Fully restart the terminal for final changes to take effect"
echo ""

cd $HOME

unset DOT_DIR
unset GIT_DIR
unset PACKAGES
unset CHSH
unset RUNZSH
