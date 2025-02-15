## this is scuffed

I know these scripts kinda suck but in all honesty, it's functional and
works perfectly fine for me, i'll most definetly trade more copy/pasting for
something that just works.

## Step 1. install arch-wsl

go to the [ArchWSL](https://github.com/yuk7/ArchWSL) repo and go to [releases](https://github.com/yuk7/ArchWSL/releases)
download `Arch.zip` from the latest release, and extract it to whever it is you
want the "drive" for arch-wsl to live. I personally prefer my desktop cuz im a
weirdo.

## Step 2. setup arch-wsl

I would pull up the [ArchWsl setup docs](https://wsldl-pg.github.io/ArchW-docs/How-to-Setup/#setting-the-root-password)
while I do this just to make sure.

NOTE: obviously in my case the user will be "albert" (since that's me), but if
for some fucking reason someone else is running this, replace "albert" with
whatever your username is, ok? thanks.

1. Exec `Arch.exe`, and after it installs the wsl registery... launch arch-wsl in
   the terminal, it should put you in root at which point you copy/paste and run
   this one liner.

```
echo "Setup passwd for root" && passwd && echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel && useradd -m -G wheel -s /bin/bash albert && echo "Setup passwd for user: albert" && passwd albert
```

it sets up root passwd, add the user "albert" to the sudoers list and sets up
passwd for user "albert".

2. At this point... Exit wsl, spin up a powershell tab in the terminal and run this

```
cd .\Desktop\; if ($?) { ./Arch.exe config --default-user albert }
```

Like i said... i have arch.exe on my desktop... leave me alone :)

3.Launch arch-wsl again and you should be as user... then run

```
sudo pacman-key --init && sudo pacman-key --populate && sudo pacman -Sy archlinux-keyring && sudo pacman -Su
```

Once you're done with all of that you can FINALLY start the actual fun stuff...

## Step 3. the install script

run

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/vague2k/dotfiles/main/install/arch-wsl/install.sh)"
```

#### Step 5. restart terminal

Done. Fully restart the terminal for final changes to take effect (zsh will
install 1 or 2 plugins...). You may or may not need to relogin to git or reset
git credentials.

### You're done!!!

woohoo you're done i can finally go to sleep.
