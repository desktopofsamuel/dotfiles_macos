#!/usr/bin/env zsh

echo "\n<<< Starting Homebrew Setup >>>\n"

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew bundle --verbose --file brew/Brewfile

echo "\n<<< Default File Extensions Setup >>>\n"
duti duti/duti