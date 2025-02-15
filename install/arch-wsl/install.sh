#!/usr/bin/env bash

# sh -c "$(curl -fsSL https://raw.githubusercontent.com/vague2k/dotfiles/install-script/install/arch-wsl/install.sh)"

set -e

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
    # "fakeroot-tcp"
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
    "unzip"
    "vim"
    "rust"
    "zoxide"
    "zsh"
)

cleanup_zsh() {

ZSH_DIR=$DOT_DIR/zsh

cp $ZSH_DIR/.zshenv ~/.zshenv
source ~/.zshenv
source $ZSH_DIR/.zshrc

rm ~/.bash*
rm ~/.shell*
rm ~/.zcompdump*
rm ~/.zshrc

unset ZSH_DIR
}

### install yay first
cd ~ # make sure we're in home dir
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

# set git creds
gh auth login

git config --global user.name "vague2k"
git config --global user.email "ilovedrawing056@gmail.com"

# setup zsh
cd ~/Documents/Github/dotfiles/zsh
cd $DOT_DIR/zsh

ZSH=~/.config/zsh/ohmyzsh 
CHSH="yes" 
RUNZSH="no" 
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

zsh -c "cp $HOME/.oh-my-zsh $HOME/Documents/Github/dotfiles/zsh/ohmyzsh;
rm -rf $HOME/.oh-my-zsh;
cp $HOME/Documents/Github/dotfiles/zsh/.zshenv ~/.zshenv; 
source ~/.zshenv;
source $HOME/Documents/Github/dotfiles/zsh/.zshrc;
rm ~/.bash*;
rm ~/.shell*;
rm ~/.zcompdump*;
rm ~/.zshrc;
"

echo ""
echo "Done. Fully restart the terminal for final changes to take effect"
echo "You may or may not need to relogin to git or reset git credentials"
echo ""

unset DOT_DIR
unset GIT_DIR
unset PACKAGES
unset -f cleanup_zsh
