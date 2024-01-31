#!/bin/bash
#
# Copyright (C) 2024 Michael Marmor | https://michaelmarmor.com/
# You should have received a copy of the GNU General Public License
# along with this program. If not, see https://www.gnu.org/licenses/.
#
# pyqwer.sh | MSM 24-Jan-2024

# Summary:
#
# This bash script automates the process of updating the system,
# installing dependencies, and setting up Python development tools using
# asdf, python-launcher, and pipx. It performs several key tasks:
#
# 1. Updates and upgrades the system using APT.
# 2. Installs necessary dependencies for asdf, Python, and python-launcher.
# 3. Installs asdf from the specified git branch.
# 4. Executes a Python script to install the latest Python versions using asdf.
# 5. Installs python-launcher using cargo and updates the PATH.
# 6. Updates pip to the latest version and installs pipx globally.
# 7. Uses pipx to install essential Python development tools.
# 8. Lists available Python versions installed by asdf and python-launcher.
#
# Usage:
#
# Run this script to automatically update the system, install asdf,
# python-launcher, and set up a Python development environment. 
# Ensure 'latest-pythons.py' is available and executable
# in the same directory as this script.
#
#---------------------------------------------------------------------------------
# Other notes:
#
# Full W11/WSL2 Ubuntu buildout using my two scripts:
#
# W11 admin cmd: wsl --install -d Ubuntu-22.04
#
# Use File Explorer to copy these two files into /home/marmor/ via the Ubuntu mount point
#
# pyqwer.sh
# latest-pythons.py
#
# marmor@MANTIS:~$ sudo chmod +x pyqwer.sh latest-pythons.py
#
# You must "source" the script instead of running it:
#
# source pyqwer.sh
# # or
# . pyqwer.sh
#
# marmor@MANTIS:~$ source pyqwer.sh
#
# That should build the entire dev environment
#---------------------------------------------------------------------------------

# Function to log messages with a newline after each message
log_message() {
    local message=$1
    local color=$2
    echo -e "\n${color}${message}\e[0m\n"
}

# Color codes
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'

BASHRC_PATH="$HOME/.bashrc"

## General System Updates
log_message "Starting system update process..." "$GREEN"
sudo apt update
log_message "Upgrading APT packages..." "$GREEN"
sudo apt dist-upgrade -y
log_message "Removing unnecessary packages..." "$GREEN"
sudo apt autoremove -y
log_message "Cleaning up APT cache..." "$GREEN"
sudo apt autoclean
(command -v snap > /dev/null && log_message "Refreshing Snap packages..." "$GREEN" && sudo snap refresh) || echo "Snap not installed."
(command -v flatpak > /dev/null && log_message "Updating Flatpak packages..." "$GREEN" && flatpak update -y) || echo "Flatpak not installed."
log_message "System update process completed!" "$GREEN"

## Installing Dependencies for asdf and Python
log_message "Installing dependencies..." "$GREEN"
sudo apt install -y build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev curl \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
libffi-dev liblzma-dev cargo tree
log_message "Dependencies installation completed!" "$GREEN"

## Installing asdf
ASDF_VERSION="v0.14.0" # Check https://asdf-vm.com/guide/getting-started.html for the latest version
log_message "Installing asdf..." "$GREEN"
# Temporarily set advice.detachedHead to false for this operation
GIT_CONFIG_NO_DETACHED_ADVICE="git -c advice.detachedHead=false"
$GIT_CONFIG_NO_DETACHED_ADVICE clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch "$ASDF_VERSION"
. "$HOME/.asdf/asdf.sh"
log_message "asdf installation completed!" "$GREEN"

## Updating bash PATH for asdf
log_message "Updating .bashrc for asdf..." "$GREEN"
echo '. "$HOME/.asdf/asdf.sh"' >> "$BASHRC_PATH"
echo '. "$HOME/.asdf/completions/asdf.bash"' >> "$BASHRC_PATH"
log_message ".bashrc update for asdf completed!" "$GREEN"

# Source .bashrc if it's an interactive shell
if [[ $- == *i* ]]; then
    source "$BASHRC_PATH"
fi

## Installing Python Versions
log_message "Running Python script for installing Python versions in a subshell..." "$GREEN"
(
    source "$HOME/.asdf/asdf.sh"
    # Use python3 to run the script, as asdf-installed Python versions are not yet available
    python3 latest-pythons.py
)
log_message "Python versions installation completed!" "$GREEN"

## Installing python-launcher
log_message "Installing python-launcher using cargo..." "$GREEN"
cargo install python-launcher
log_message "Updating .bashrc for python-launcher..." "$GREEN"
echo 'export PATH="$PATH:$HOME/.cargo/bin"' >> "$BASHRC_PATH"
export PATH="$HOME/.cargo/bin:$PATH"
log_message "Listing available Python versions..." "$GREEN"
py --list

# Source .bashrc again to include new PATH updates
if [[ $- == *i* ]]; then
    source "$BASHRC_PATH"
fi

## Upgrading pip and Installing pipx
log_message "Upgrading pip and installing pipx..." "$GREEN"
# Determine the Python version installed by asdf, fallback to python3 if not set
PYTHON_BIN_PATH="$HOME/.asdf/installs/python/$(asdf current python | cut -d ' ' -f 1)/bin/python"
if [ ! -f "$PYTHON_BIN_PATH" ]; then
    PYTHON_BIN_PATH="python3"
fi

$PYTHON_BIN_PATH -m pip install --upgrade pip
$PYTHON_BIN_PATH -m pip install --user pipx
echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$BASHRC_PATH"
export PATH="$HOME/.local/bin:$PATH"
log_message "Pip and pipx installation completed!" "$GREEN"

# Source .bashrc once more to update PATH
if [[ $- == *i* ]]; then
    source "$BASHRC_PATH"
fi

## Installing Global Python Tools with pipx
log_message "Installing Python tools with pipx..." "$GREEN"
"$HOME/.local/bin/pipx" install build
"$HOME/.local/bin/pipx" install tox
"$HOME/.local/bin/pipx" install pre-commit
"$HOME/.local/bin/pipx" install cookiecutter
log_message "Python tools installation completed!" "$GREEN"

log_message "pyqwer setup script completed." "$GREEN"
log_message "To apply the changes made by this script to your current shell: source ~/.bashrc" "$BLUE"
#log_message "Or, for a complete refresh of the shell environment: exec \"$SHELL\"" "$BLUE"