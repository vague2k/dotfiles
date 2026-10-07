#!/usr/bin/env bash

# an install script for these dotfiles on arch-based systems
# this script automates the manual install instructions from the README

set -euo pipefail

if [ "$(uname -s)" = "Darwin" ]; then
    echo "macOS detected: this installer only supports arch based systems." >&2
    echo "Follow the manual install steps from the README using your package manager:" >&2
    echo "  https://github.com/vague2k/dotfiles#manual-install" >&2
    exit 1
fi

REPO_URL="https://github.com/vague2k/dotfiles.git"

DOTDIR=""

# when the script runs from inside a checkout, use that checkout
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [ -f "$script_dir/mklinks" ] && [ -d "$script_dir/.config" ]; then
        DOTDIR="$script_dir"
    fi
fi

common_pkgs=(git github-cli zsh tmux neovim tree-sitter-cli fzf ripgrep lazygit eza zoxide glow jq opencode nodejs npm python python-pynvim go rust)

# install on wsl only
wsl_pkgs=(wslu)

# install on desktop only (skipped on WSL)
desktop_pkgs=(ttf-iosevka-nerd zathura hyprland quickshell ghostty matugen awww cava grim slurp wl-clipboard blueman pipewire wireplumber pipewire-pulse libnotify glib2 brave-bin nautilus texlive-binextra nvidia-utils)

is_wsl() {
    if [ -n "${WSL_DISTRO_NAME:-}" ]; then
        return 0
    fi
    grep -qiE '(microsoft|wsl)' /proc/version 2>/dev/null
}

if [ "$(id -u)" -eq 0 ]; then
    echo "Run this as a regular user, not root (sudo is used where needed)." >&2
    exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
    echo "pacman not found: these dotfiles target Arch-based systems." >&2
    exit 1
fi

# only reachable when piped (curl ... | bash): ask where the dotfiles live
if [ -z "$DOTDIR" ]; then
    have_tty=false
    if { true < /dev/tty; } 2>/dev/null; then
        have_tty=true
    fi

    while true; do
        answer=""
        if [ "$have_tty" = true ]; then
            printf 'Where should the dotfiles live? [%s] ' "$PWD" >&2
            read -r answer < /dev/tty || true
        fi
        answer="${answer:-$PWD}"

        # expand a leading ~
        case "$answer" in
            "~") answer="$HOME" ;;
            "~/"*) answer="$HOME/${answer#\~/}" ;;
        esac

        if [ -f "$answer/mklinks" ] && [ -d "$answer/.config" ]; then
            echo "  dotfiles already exist at $answer, skipping clone"
        elif [ -e "$answer" ] && [ -n "$(ls -A "$answer" 2>/dev/null)" ]; then
            echo "error: $answer is not empty and does not contain the dotfiles" >&2
            if [ "$have_tty" != true ]; then
                exit 1
            fi
            continue
        else
            echo "  cloning dotfiles into $answer"
            git clone "$REPO_URL" "$answer"
        fi

        DOTDIR="$(cd "$answer" && pwd)"
        break
    done
fi

# ask for sudo once instead of in the middle of the install
sudo -v

echo "==> Updating the system and installing dependencies"
sudo pacman -Syu --needed --noconfirm base-devel git

if command -v yay >/dev/null 2>&1; then
    echo "  ok  yay is already installed"
else
    echo "  building yay from the AUR"
    tmp="$(mktemp -d)"
    git clone --depth=1 https://aur.archlinux.org/yay.git "$tmp/yay"
    (cd "$tmp/yay" && makepkg -si --noconfirm)
    rm -rf "$tmp"
fi

pkgs=("${common_pkgs[@]}")
if is_wsl; then
    echo "  WSL detected, skipping desktop-only packages"
    pkgs+=("${wsl_pkgs[@]}")
else
    if grep -q '^\[multilib\]' /etc/pacman.conf; then
        desktop_pkgs+=(steam)
    else
        echo "  note: [multilib] not enabled in /etc/pacman.conf, skipping steam" >&2
    fi
    pkgs+=("${desktop_pkgs[@]}")
fi

yay -S --needed --noconfirm "${pkgs[@]}"

echo
echo "==> Symlinking dotfiles"
"$DOTDIR/mklinks"

echo
echo "==> Finishing..."
TPM="$HOME/.config/tmux/plugins/tpm"
if [ -d "$TPM" ]; then
    echo "  ok  tpm"
else
    git clone --depth=1 https://github.com/tmux-plugins/tpm "$TPM"
fi
OMZ="$HOME/.config/zsh/ohmyzsh"
if [ -d "$OMZ" ]; then
    echo "  ok  oh-my-zsh"
else
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$OMZ"
fi
sudo cp "$HOME/.config/zsh/.zshenv" /etc/zsh/zshenv

echo
echo "Done."
echo "Next steps:"
echo "  - open a new shell so the zsh config loads (it clones the zsh plugins on first run)"
echo "  - in tmux, prefix + I to install the tmux plugins"
echo "  - in nvim, plugins and the Mason tools install on first launch"
