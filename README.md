# dotfiles_macos

Personal dotfiles repository for macOS setup and configuration. This repository uses [Dotbot](https://github.com/anishathalye/dotbot) to automate symlinking and setup scripts.

## Quick Start

### Bootstrap a New Mac

1. **Install Apple's Command Line Tools** (prerequisites for Git and Homebrew):
   ```zsh
   xcode-select --install
   ```

2. **Clone this repository**:
   ```zsh
   # Using SSH (recommended)
   git clone git@github.com/desktopofsamuel/dotfiles_macos.git ~/.dotfiles
   
   # Or using HTTPS
   git clone https://github.com/desktopofsamuel/dotfiles_macos.git ~/.dotfiles
   ```

3. **Run the install script**:
   ```zsh
   cd ~/.dotfiles
   ./install
   ```
   
   The script will:
   - Create symlinks for all dotfiles (`.zshrc`, `.gitconfig`, etc.)
   - Install Homebrew **only if it is not already installed** (otherwise skips the official installer)
   - Run **`./setup_homebrew.zsh`**, which asks whether to enable the **development profile** (`~/.dev_setup_enabled`), then Homebrew / bundles / picker (NVM only if you answered **y**)
   - Run **`brew bundle`** for taps, then **CLI formulae** from [`brew/Brewfile.essential`](brew/Brewfile.essential) (always)
   - Optionally run [`brew/Brewfile.others`](brew/Brewfile.others) if it contains bundle entries
   - After Homebrew, **Dotbot** links `~/.zshrc.dev`, VS Code paths, and dev directories **only if** `~/.dev_setup_enabled` exists (created when you answered **y** in `setup_homebrew.zsh`)
   - Open a **nested picker** (same `setup_homebrew.zsh` run): when the dev profile is **on**, the first category is **Development CLI (Brewfile.dev)** — one row for **`brew bundle` on `Brewfile.dev`**. Other categories list **casks** and **`mas:<id>`** from [`brew/casks.zsh`](brew/casks.zsh). **Space** / **Enter** as before; non-TTY may use **`/dev/tty`** or **y/N per row**
   - Configure macOS system preferences
   - Set up default file associations
   
   **Note:** You can set up your Mac without the development environment if you only need basic system configuration. Development setup includes Node.js, Python, Ruby tools, IDEs, and development-specific shell configurations.

4. **Reload your shell configuration**:
   ```zsh
   source ~/.zshrc
   ```

5. **Set up Espanso** (text expander):
   ```zsh
   espanso register  # Provide accessibility access
   espanso start     # Start using Espanso
   ```

## What Gets Installed

### Always Installed (Base Setup)

**Symlinked Files:**
- `~/.zshrc` → Base shell configuration
- `~/.gitconfig` → Git configuration (GitHub HTTPS URLs rewrite to `git@github.com:…`)
- `~/.ssh/config` → SSH client defaults and GitHub host aliases (`github-personal`, `github-work`, `github-ai`) aligned with the keys loaded in `~/.zshrc`
- `~/.mackup.cfg` → Mackup configuration
- `~/Library/Preferences/espanso` → Espanso configuration

**Homebrew (via [`setup_homebrew.zsh`](setup_homebrew.zsh)):**
- **Taps** → [`brew/Brewfile.taps`](brew/Brewfile.taps) (always)
- **CLI formulae** → [`brew/Brewfile.essential`](brew/Brewfile.essential) (always). [`brew/Brewfile.dev`](brew/Brewfile.dev) runs only if you enabled the **development profile** in [`setup_homebrew.zsh`](setup_homebrew.zsh) **and** you **select** the **Brewfile.dev** row in the nested picker
- **Optional** → [`brew/Brewfile.others`](brew/Brewfile.others) only if that file has real `brew` / `vscode` / `tap` / etc. lines
- **Casks & Mac App Store** → chosen in the nested UI; each category array in [`brew/casks.zsh`](brew/casks.zsh) lists **cask tokens** (e.g. `raycast`) and **`mas:<numeric_id>`** on the same lines. Selected casks run `brew install --cask …`; selected MAS rows run `mas install …` (the **`mas`** formula is in `Brewfile.essential`)
- **Legacy** → [`brew/Brewfile`](brew/Brewfile) is not modified by the installer; keep it as reference or for `brew bundle --file` if you want

### Development Setup (Optional)

If you enable the development profile when [`setup_homebrew.zsh`](setup_homebrew.zsh) asks (during `./install` or when you run that script alone), the following can apply. **`brew bundle` on `Brewfile.dev`** is an **explicit row** in the nested picker. GUI apps are other rows in the same picker:

**Additional Symlinked Files:**
- `~/.zshrc.dev` → Development-specific shell configuration (auto-loaded by `.zshrc`)
- `~/Library/Application Support/Code/User/settings.json` → VSCode settings
- `~/Library/Application Support/Code/User/snippets` → VSCode snippets (if exists)

**Created Directories:**
- `~/Developer` → Development workspace
- `~/.nvm` → NVM directory

**Additional Tools:**
- NVM (Node Version Manager) installation
- Development CLI packages and VS Code extensions from `brew/Brewfile.dev` (GUI IDEs such as Cursor/VS Code are normally casks in `brew/casks.zsh` unless you list them only as MAS)

**Development Shell Configuration Includes:**
- NVM (Node Version Manager)
- rbenv (Ruby version manager)
- Python paths
- pnpm, conda, gradle
- Android Studio paths
- Development aliases (Cursor, VSCode)

### macOS System Preferences
The `setup_macos.zsh` script configures (always applied):
- Trackpad settings (tap to click, three-finger drag)
- Dock position and size
- Screenshot location
- Energy saving settings
- Transmission.app preferences

## Useful Commands

### Sync split Brewfiles from this Mac (taps + formulae + VS Code)

To refresh **only** [`brew/Brewfile.taps`](brew/Brewfile.taps), [`brew/Brewfile.essential`](brew/Brewfile.essential), and [`brew/Brewfile.dev`](brew/Brewfile.dev) from what is currently installed—**without** overwriting the main [`brew/Brewfile`](brew/Brewfile) or [`brew/casks.zsh`](brew/casks.zsh):

```zsh
cd ~/.dotfiles
brew update
brew bundle dump --describe --force --formula --no-vscode --file /tmp/hb-formulae.txt
brew bundle dump --describe --force --vscode --file /tmp/hb-vscode.txt
brew bundle dump --describe --force --tap --file /tmp/hb-taps.txt
python3 brew/_sync_brewfiles_from_dump.py
```

See the docstring in [`brew/_sync_brewfiles_from_dump.py`](brew/_sync_brewfiles_from_dump.py) for the same steps.

### Dump everything to the main Brewfile (legacy)

```zsh
cd ~/.dotfiles
brew bundle dump --describe --force --file brew/Brewfile
```

### Check SSD Health
```zsh
smartctl -a disk1s1
```

### Reload Shell Configuration
```zsh
source ~/.zshrc
```

### Espanso Commands
```zsh
espanso register  # Grant accessibility access
espanso start     # Start Espanso service
espanso stop      # Stop Espanso service
```

## Repository Structure

```
.dotfiles/
├── brew/                    # Homebrew files
│   ├── Brewfile.taps        # Taps (always)
│   ├── Brewfile.essential   # CLI formulae (always)
│   ├── Brewfile.dev         # Dev CLI + VS Code extensions (if dev setup enabled)
│   ├── Brewfile.others      # Optional extra bundle lines (if any)
│   ├── casks.zsh            # Nested picker: casks + mas:<id> per category
│   ├── _sync_brewfiles_from_dump.py  # Merge bundle dumps into split Brewfiles
│   └── Brewfile             # Main Brewfile (legacy; not driven by install)
├── dotbot/                  # Dotbot submodule (handles symlinking)
├── espanso/                 # Espanso text expander configuration
├── git/                     # Git configuration files
├── ssh/                     # SSH client config (GitHub aliases + Keychain)
├── VSCode/                  # VSCode settings and extensions (dev only)
├── install                  # Main installation script
├── install.conf.yaml        # Dotbot configuration
├── setup_homebrew.zsh       # Homebrew and package installation script
├── setup_macos.zsh          # macOS system preferences configuration
├── extensions.duti          # Default file associations
├── zshrc                    # Base Zsh shell configuration
└── zshrc.dev                # Development-specific Zsh configuration (optional)
```

## Additional Setup

### Git and SSH

- **`git/gitconfig`** adds GitHub **HTTPS → SSH** URL rewrites so clones and `origin` URLs using `https://github.com/…` are rewritten to `git@github.com:…` (same host your SSH agent uses).
- **`ssh/config`** defines **`github-personal`**, **`github-work`**, and **`github-ai`** (each uses the matching `~/.ssh/id_*` with `IdentitiesOnly`), in line with the three keys loaded in **`zshrc`**. Default `git@github.com:…` still uses whatever key GitHub accepts first from the agent; for a **fixed** account, set the remote to e.g. `git@github-work:ORG/REPO.git`.
- Optional, with your existing **`includeIf`** for **`~/Developer/`** → **`~/.gitconfig-personal`**: add **`[url "git@github-personal:"]`** / **`insteadOf = git@github.com:`** there so repos under **`~/Developer/`** always use **`id_personal`** via the **`github-personal`** host alias.
- If you already have a **`~/.ssh/config`**, back it up before running **`./install`**, or merge its contents into **`ssh/config`** in this repo.

### Enable "Allow Anywhere" for System Security

If you need to install applications from unidentified developers:

1. Open **System Settings** → **Privacy & Security**
2. Open Terminal and run:
   ```zsh
   sudo spctl --master-disable
   ```
3. Enter your password when prompted
4. Return to **Privacy & Security** settings - the "Anywhere" option should now be enabled

**Note:** This reduces system security. Only enable if necessary.

## Enabling/Disabling Development Setup

### Enable Development Setup After Initial Install

Either run Homebrew setup again and answer **y** at the development prompt:

```zsh
cd ~/.dotfiles
./setup_homebrew.zsh
```

Then re-run **`./install`** so Dotbot can create dev symlinks (`~/.zshrc.dev`, VS Code, `~/Developer`, `~/.nvm`), or create the marker and install manually:

```zsh
touch ~/.dev_setup_enabled
cd ~/.dotfiles
./install
```

### Disable Development Setup

To disable development setup (removes dev configs but keeps installed packages):

```zsh
rm ~/.dev_setup_enabled
# Remove dev-specific symlinks manually if needed
rm ~/.zshrc.dev
# Then reload shell
source ~/.zshrc
```

## Maintenance

### Updating Dotfiles

To pull the latest changes:
```zsh
cd ~/.dotfiles
git pull origin main
./install  # Re-run install to apply any new symlinks or configurations
```

### Adding New Packages

1. **CLI formula** (`brew install …`): install it, then either run the **sync split Brewfiles** commands above (recommended) or dump manually into the right file:
   ```zsh
   cd ~/.dotfiles
   brew bundle dump --describe --force --file brew/Brewfile.essential
   # Or target brew/Brewfile.dev for dev-only CLI tools
   ```

2. **GUI app — Homebrew cask** (`brew install --cask …`): add the **cask token** to the appropriate `BREW_CASKS_<category>` array in [`brew/casks.zsh`](brew/casks.zsh). Optionally add a new category slug to `BREW_CASK_CATEGORY_ORDER` and a label in `BREW_CASK_CATEGORY_LABEL`.

3. **Mac App Store app**: add **`mas:<app_id>`** to a `BREW_CASKS_*` array next to related casks, and set **`BREW_MAS_NAME[<id>]="Display Name"`** in the same file. Re-run `./install` or `./setup_homebrew.zsh` to select it in the picker.

## Todo List

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

## Windows Setup Notes

### Creating Bootable USB

When installing Windows from a bootable USB:

1. Boot from the USB drive
2. Press `Shift + F10` to open Command Prompt
3. Run `DISKPART` to access the partition tool:
   ```cmd
   DISKPART
   list disk          # List all available disks
   select disk <n>    # Select the target disk
   clean              # Format the disk
   convert gpt        # Convert to GPT format (required for modern systems)
   ```

### Post-Installation Setup

Install common applications via [Ninite](https://ninite.com/) for quick setup.
