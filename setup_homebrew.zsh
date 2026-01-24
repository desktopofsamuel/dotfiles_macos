#!/usr/bin/env zsh

# Check if development setup is enabled
DEV_SETUP_ENABLED=0
if [ -f "$HOME/.dev_setup_enabled" ] || [ "$DEV_SETUP_ENABLED" = "1" ]; then
    DEV_SETUP_ENABLED=1
fi

# Only install NVM if development setup is enabled
if [ "$DEV_SETUP_ENABLED" = "1" ]; then
    echo "\n<<< Setup NVM >>>\n"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
fi

echo "\n<<< Starting Homebrew Setup >>>\n"
# Homebrew installation remains as is
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# --- Start of Simple Homebrew Bundle Category Selection ---

# Ensure the 'brew' directory exists for Brewfiles
local_brew_dir="$(dirname "$0")/brew"
mkdir -p "$local_brew_dir"

echo "\n--- Homebrew Bundle Simple Selection ---\n"

# Install Taps first, they are essential prerequisites
echo "--- Installing Homebrew Taps (prerequisites) ---"
if [[ -f "$local_brew_dir/Brewfile.taps" ]]; then
    brew bundle --verbose --file "$local_brew_dir/Brewfile.taps" || { echo "Error installing taps. Exiting."; exit 1; }
else
    echo "Warning: Brewfile.taps not found at '$local_brew_dir/Brewfile.taps'. Skipping tap installation."
fi

echo "\nNow, for each category, type 'y' to install, or 'N' to skip."

# Define categories and their corresponding Brewfile paths
declare -A categories=(
    ["Essential"]="Brewfile.essential"
    ["Development"]="Brewfile.dev"
    ["Others"]="Brewfile.others"
)

# Build category list based on dev setup
if [ "$DEV_SETUP_ENABLED" = "1" ]; then
    category_list=("Essential" "Development" "Others")
else
    category_list=("Essential" "Others")
    echo "\nNote: Development packages are skipped (dev setup is disabled)"
fi

# Loop through each category and prompt user
for category_name in "${category_list[@]}"; do
    local_file_path="$local_brew_dir/${categories[$category_name]}"

    echo "\nInstall $category_name packages? (y/N)"
    read -r response

    if [[ "$response" =~ ^[yY]$ ]]; then
        if [[ -f "$local_file_path" ]]; then
            echo "--- Installing $category_name packages ---"
            brew bundle --verbose --file "$local_file_path"
        else
            echo "Warning: Brewfile for '$category_name' not found at '$local_file_path'. Skipping this category."
        fi
    else
        echo "Skipping $category_name packages."
    fi
done

# --- End of Simple Homebrew Bundle Category Selection ---

echo "\n<<< Default File Extensions Setup >>>\n"
# This assumes extensions.duti is in the same directory as setup_homebrew.zsh
# You might need to create 'extensions.duti' in your .dotfiles directory
duti "$(dirname "$0")/extensions.duti" || echo "Warning: 'extensions.duti' not found or 'duti' command failed."

echo "\n--- Homebrew Setup Complete ---\n"