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

cmd_exists() {
  command -v "$@" >/dev/null 2>&1
}

user_can_sudo() {
  cmd_exists sudo || return 1
  case "$PREFIX" in
  *com.termux*) return 1 ;;
  esac
  ! LANG= sudo -n -v 2>&1 | grep -q "may not run sudo"
}

### if user can't sudo, install sudo
if ! user_can_sudo; then
    pacman -Sy sudo
fi


### if root, setup passwd for root and new user "albert"
if [[ $(id -u) -eq 0 ]]; then
    echo "Setup passwd for root"
    passwd 
    echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel
    useradd -m -G wheel -s /bin/bash albert
    echo "Setup passwd for user: albert"
    passwd albert
    echo "Switching user to... albert"
    su albert
    sudo pacman-key --init 
    sudo pacman-key --populate 
    sudo pacman -Sy archlinux-keyring 
    sudo pacman -Su
fi

### install yay first
cd ~ # make sure we're in home dir
if cmd_exists "yay"; then
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

# setup zsh
cd ~/Documents/Github/dotfiles/zsh
cd $DOT_DIR/zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo ""
echo "Done. Fully restart the terminal for final changes to take effect"
echo "You may or may not need to relogin to git or reset git credentials"
echo ""
