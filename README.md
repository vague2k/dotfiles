# dotfiles

These are dotfiles on arch based systems

## Dependencies

I run cachyos on my desktop and arch in WSL when in windows, some packages can
be used in both some can't.

### Both desktop and WSL

- git
- zsh
- tmux
- neovim (0.11+)
- fzf
- ripgrep (replaces grep)
- lazygit
- eza (replaces ls)
- zoxide (replaces cd)
- glow
- a Nerd Font, e.g. Iosevka Nerd Font Mono
- opencode
- zathura
- latexmk
- jq (parses JSON for the theme and gaming-mode scripts)
- runtimes for language tooling and tests, only for the languages you use (Mason installs the servers themselves):
  - nodejs
  - npm
  - python3
  - pynvim
  - go
  - rust

### Desktop only (skip on WSL)

- hyprland (window manager)
- quickshell (desktop shell)
- ghostty (terminal emulator)
- matugen (generates themes from the wallpaper)
- awww (wallpaper daemon)
- cava (audio visualizer)
- grim (screenshots)
- slurp (selects screenshot regions)
- wl-clipboard (replaces xclip)
- blueman (bluetooth applet)
- pipewire (audio routing; provides wpctl and pactl)
- libnotify (desktop notifications)
- glib2 (gsettings dark-mode toggle)
- brave (browser)
- nautilus (file manager)
- steam (gaming-mode)
- nvidia-smi (GPU stats in the bar)

## Install

1. Clone the repo:

   ```sh
   git clone https://github.com/vague2k/dotfiles.git ~/Documents/Github/dotfiles
   ```

2. Symlink the dotfiles into place:

   ```sh
   cd ~/Documents/Github/dotfiles
   ./mklinks
   ```

   This links every entry in `.config/` into `${XDG_CONFIG_HOME:-~/.config}` and every
   script in `.local/bin/scripts/` into `~/.local/bin`. It can be re-run safely: stale
   symlinks are repointed and real files are left untouched.

3. Install the tmux plugin manager (TPM) where the config expects it:

   ```sh
   git clone --depth=1 https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
   ```

4. Install oh-my-zsh into the custom directory this config expects
   (`$ZDOTDIR/ohmyzsh`, **not** the default `~/.oh-my-zsh`):

   ```sh
   git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.config/zsh/ohmyzsh
   ```

5. Bootstrap `ZDOTDIR` system-wide so zsh finds the config before loading anything else:

   ```sh
   sudo cp ~/.config/zsh/.zshenv /etc/zsh/zshenv
   ```

6. Open a new shell.
   - On the first launch, `.config/zsh/plugins.sh` clones `zsh-autosuggestions`
     and `zsh-syntax-highlighting` into `$ZSH/custom/plugins`.
   - On the first nvim launch, lazy.nvim installs the plugins and Mason installs
     the language servers/tools.
   - In tmux, install the plugins (TPM bindings, prefix-highlight, resurrect)
     with `prefix + I`.
