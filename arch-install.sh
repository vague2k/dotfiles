#!/usr/bin/env bash

# Install via curl
#
# sh -c "$(curl -fsSL https://raw.githubusercontent.com/vague2k/dotfiles/main/arch-install.sh)"

ARCH_PKGS=(
"arch-install-scripts"
"base"
"base-devel"
"eza"
"fakeroot-tcp"
"fzf"
"git"
"github-cli"
"glow"
"go"
"lf"
"lazygit"
"less"
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
"yay-bin"
"yay-bin-debug"
"yazi"
"zoxide"
"zsh"
)

#################################
### actual script starts here ###
#################################

echo "attempting to setup new system..."
echo 

sudo pacman -Syu

# bootstrap dir
cd ~ && mkdir -p ~/Documents/Github

# check if yay is installed, if it is not, install yay
if command -v yay >/dev/null 2>&1; then
    echo "yay is already installed."
else
    echo "yay is not installed."
    echo "attempting to install yay from binary..."
    echo 
    sudo pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si
fi

# install packages
yay -S --needed "${ARCH_PKGS[@]}"

# try logging into github using cli, and cloning neccessary initial repos
if command -v gh >/dev/null 2>&1; then
    echo "github-cli is not installed."
    echo "something went wrong, aborting..."
    echo
    exit 1
else
    echo "login to github using github-cli..."
    gh auth login && \ 
    cd ~/Documents/Github/ && \
    gh repo clone vague2k/huez.nvim && \ 
    gh repo clone vague2k/vague.nvim && \ 
    gh repo clone vague2k/rummage && \ 
    gh repo clone vague2k/smv && \ 
    gh repo clone vague2k/dotfiles && \ 
fi

# attempt to install ohmyzsh

# if omz successfully installs, run mklinks script

# all done

