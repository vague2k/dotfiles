# dotfiles

These are dotfiles on arch based systems

## Dependencies

I run cachyos on my desktop and arch in WSL when in windows, some packages can
be used in both some can't. The [install script](#install) installs these.

### Both desktop and WSL

- git
- github-cli
- zsh
- tmux
- neovim (0.11+)
- tree-sitter-cli
- fzf
- ripgrep (replaces grep)
- lazygit
- eza (replaces ls)
- zoxide (replaces cd)
- glow
- opencode
- jq (parses JSON for the theme and gaming-mode scripts)
- runtimes for language tooling and tests, only for the languages you use (Mason installs the servers themselves):
  - nodejs
  - npm
  - python3
  - pynvim
  - go
  - rust

### WSL only

- wslu (windows integration utilities)

### Desktop only (skip on WSL)

- Iosevka Nerd Font Mono (Nerd Font)
- zathura (pdf viewer)
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
- latexmk (for latex stuff)
- steam (gaming-mode)
- nvidia-smi (GPU stats in the bar)

## Install

Run the installer:

```sh
curl -fsSL https://raw.githubusercontent.com/vague2k/dotfiles/main/install.sh | bash
```

### Manual install

Install the packages listed under Dependencies yourself, then:

1. Clone the repo wherever you want to keep the repo:

   ```sh
   git clone https://github.com/vague2k/dotfiles.git
   cd dotfiles
   ```

2. Symlink the dotfiles into place:

   ```sh
   ./mklinks
   ```

   It can be re-run, stale symlinks are repointed leaving files untouched

3. Install the tmux plugin manager (TPM) where the config expects it:

   ```sh
   git clone --depth=1 https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
   ```

4. Install oh-my-zsh into the custom directory, this config expects
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
