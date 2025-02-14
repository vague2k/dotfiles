#!/usr/bin/env bash

set -e

GIT_DIR=~/Documents/Github
DOT_DIR=$GITDIR/dotfiles
PACKAGES=(
    "arch-install-scripts"
    "base"
    "base-devel"
    "eza"
    "fakeroot-tcp"
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

ZSH=~/.config/zsh/ohmyzsh sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
cleanup_zsh

echo ""
echo "Done. Fully restart the terminal for final changes to take effect"
echo "You may or may not need to relogin to git or reset git credentials"
echo ""

unset DOT_DIR
unset GIT_DIR
unset PACKAGES
