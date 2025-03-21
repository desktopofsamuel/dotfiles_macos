# dotfiles_macos

## Commands

Switch to `.dotfiles` folder:

- `brew bundle dump --describe --force --file brew/Brewfile ` for updating brew installs to dotfile
- `smartctl -a disk1s1` for checking percentage usage for SSD
- `espano register` to provide accessibility acess, then `espano start` to start using
- `source ~/.zshrc` to reload the zshrc file

## Steps to bootstrap a new Mac

1. Install Apple's Command Line Tools, which are prerequisites for Git and Homebrew.

```zsh
xcode-select --install
```

2. Clone repo into new hidden directory.

```zsh
# Use SSH (if set up)...
git clone git@github.com/desktopofsamuel/dotfiles_macos.git ~/.dotfiles

# ...or use HTTPS and switch remotes later.
git clone https://github.com/desktopofsamuel/dotfiles_macos.git ~/.dotfiles
```

3. Create symlinks in the Home directory to the real files in the repo.

```zsh
# There are better and less manual ways to do this;
# investigate install scripts and bootstrapping tools.

ln -s ~/.dotfiles/.zshrc ~/.zshrc
ln -s ~/.dotfiles/.gitconfig ~/.gitconfig
```

4. Install Homebrew, followed by the software listed in the Brewfile.

```zsh
# These could also be in an install script.

# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# ...or move to the directory first.
cd ~/.dotfiles/brew && brew bundle --file
```

## TODO List

<!-- - Learn how to use [`defaults`](https://macos-defaults.com/#%F0%9F%99%8B-what-s-a-defaults-command) to record and restore System Preferences and other macOS configurations.
- Organize these growing steps into multiple script files.
- Automate symlinking and run script files with a bootstrapping tool like [Dotbot](https://github.com/anishathalye/dotbot).
- Revisit the list in [`.zshrc`](.zshrc) to customize the shell.
- Make a checklist of steps to decommission your computer before wiping your hard drive.
- Create a [bootable USB installer for macOS](https://support.apple.com/en-us/HT201372).
- Integrate other cloud services into your Dotfiles process (Dropbox, Google Drive, etc.).
- Find inspiration and examples in other Doffiles repositories at [dotfiles.github.io](https://dotfiles.github.io/).
- And last, but hopefully not least, [**take my course, _Dotfiles from Start to Finish-ish_**](https://www.udemy.com/course/dotfiles-from-start-to-finish-ish/?referralCode=445BE0B541C48FE85276 "Learn Dotfiles from Start to Finish-ish on Udemy")! -->

## Samuel's Todo List:

- [x] macOS System Preference Automation
- [x] Find package for default macOS app
- [x] Automate duti list of apps
- [x] Backup VSCode
- [x] Automate symlink when reinstall
- [x] Three finger drag
- [ ] Finder's favorite list
- [ ] Keyboard shortcut (Command + Space & Alt + Space)
- [ ] Confirm NVM works (create new .nvm folder and add NVM install script)

---

# Windows

ISO on bootable USB

`Shift + F10` to open CMD, `DISKPART` to create partition tool, `list disk` to list all disks, `clean` to format, `convert gpt` to make it formattable.

## Setup
Install via [Ninite](https://ninite.com/)
