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
   - **Prompt you** to choose whether to enable development environment setup
   - Create symlinks for all dotfiles (`.zshrc`, `.gitconfig`, etc.)
   - Install Homebrew
   - Install NVM (Node Version Manager) - **only if dev setup is enabled**
   - Prompt you to install packages from categorized Brewfiles:
     - **Essential** - Core system tools (always available)
     - **Development** - Dev tools and languages (only if dev setup enabled)
     - **Others** - Additional applications (always available)
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
- `~/.gitconfig` → Git configuration
- `~/.mackup.cfg` → Mackup configuration
- `~/Library/Preferences/espanso` → Espanso configuration

**Homebrew Packages:**
- **Taps** (installed automatically) → Homebrew taps/plugins
- **Essential** → Core system tools (prompted)
- **Others** → Additional applications (prompted)

### Development Setup (Optional)

If you enable development setup during installation, the following will also be installed:

**Additional Symlinked Files:**
- `~/.zshrc.dev` → Development-specific shell configuration (auto-loaded by `.zshrc`)
- `~/Library/Application Support/Code/User/settings.json` → VSCode settings
- `~/Library/Application Support/Code/User/snippets` → VSCode snippets (if exists)

**Created Directories:**
- `~/Developer` → Development workspace
- `~/.nvm` → NVM directory

**Additional Tools:**
- NVM (Node Version Manager) installation
- Development Homebrew packages (Node.js, Python, Ruby, IDEs, etc.)

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

### Update Brewfiles
To update your installed packages to the Brewfiles:
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
├── brew/                    # Homebrew package files
│   ├── Brewfile.taps        # Homebrew taps (installed automatically)
│   ├── Brewfile.essential   # Essential packages
│   ├── Brewfile.dev         # Development tools
│   ├── Brewfile.others      # Additional applications
│   └── Brewfile             # Main Brewfile (legacy)
├── dotbot/                  # Dotbot submodule (handles symlinking)
├── espanso/                 # Espanso text expander configuration
├── git/                     # Git configuration files
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

If you initially skipped development setup but want to enable it later:

```zsh
touch ~/.dev_setup_enabled
cd ~/.dotfiles
./install  # Re-run install to set up dev environment
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

1. Install the package normally with Homebrew:
   ```zsh
   brew install <package-name>
   ```

2. Update the appropriate Brewfile:
   ```zsh
   cd ~/.dotfiles
   brew bundle dump --describe --force --file brew/Brewfile.essential
   # Or use Brewfile.dev or Brewfile.others depending on the package
   ```

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
