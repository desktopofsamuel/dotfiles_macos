#!/usr/bin/env bash

# ~/.macos — https://mths.be/macos

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################
# General UI/UX                                                               #
###############################################################################

# Three finger drag
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool false

###############################################################################
# Dock                                                                        #
###############################################################################

# Dock position set to left (default: buttom)
defaults write com.apple.dock "orientation" -string "left"

# Dock icon size set to 36px (default: 48px)
defaults write com.apple.dock "tilesize" -int "36"

###############################################################################
# Screenshot                                                                  #
###############################################################################

# Create a folder for screenshot
mkdir ../Screenshots

# Set screen capture default location at folder
defaults write com.apple.screencapture "location" -string "~/Screenshots"

# Remove screenshot thumbnail display at bottom right corner, causing delay
defaults write com.apple.screencapture "show-thumbnail" -bool "false"

###############################################################################
# Energy saving                                                               #
###############################################################################

# Enable lid wakeup
# sudo pmset -a lidwake 1

# Restart automatically on power loss
# sudo pmset -a autorestart 1

# Restart automatically if the computer freezes
# sudo systemsetup -setrestartfreeze on

# Sleep the display after 15 minutes
sudo pmset -a displaysleep 10

# Disable machine sleep while charging
# sudo pmset -c sleep 0

# Set machine sleep to 5 minutes on battery
sudo pmset -b sleep 15

# Set standby delay to 24 hours (default is 1 hour)
# sudo pmset -a standbydelay 86400

# Never go into computer sleep mode
# sudo systemsetup -setcomputersleep Off > /dev/null

# Finish macOS Setup
killall Finder
killall Dock
killall SystemUIServer

echo "\n<<< macOS Setup Complete. Restart >>>\n"

