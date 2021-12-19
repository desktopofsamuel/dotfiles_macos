#!/usr/bin/env zsh

echo "\n<<< Setup NVM >>>\n"

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

echo "\n<<< Starting Homebrew Setup >>>\n"

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew bundle --verbose --file brew/Brewfile

echo "\n<<< Default File Extensions Setup >>>\n"
duti ./extensions.duti