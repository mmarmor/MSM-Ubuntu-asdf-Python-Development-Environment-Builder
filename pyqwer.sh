#!/bin/bash
#
# Copyright (C) 2024 Michael Marmor | https://michaelmarmor.com/
# You should have received a copy of the GNU General Public License
# along with this program. If not, see https://www.gnu.org/licenses/.
#
# pyqwer.sh | MSM 05-Jan-2025

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
# ---------------------------------------------------------------------------------
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
# ---------------------------------------------------------------------------------

# Note: Another recommended approach is installing Rust with rustup, e.g.
#   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# Some find it provides a more standard Rust environment on many systems.

# Function to ensure Python build dependencies
ensure_pipx_build_deps() {
    log_message "Ensuring pipx build dependencies..." "$GREEN"
    
    # Get pipx's Python path and version
    PIPX_PYTHON=$(command -v python3)
    PIPX_PYTHON_VERSION=$($PIPX_PYTHON --version 2>&1 | awk '{print $2}')
    
    log_message "Using pipx Python: $PIPX_PYTHON (version $PIPX_PYTHON_VERSION)" "$BLUE"
    
    # Ensure we're using the correct pip binary
    PIPX_PIP="$PIPX_PYTHON -m pip"
    
    # First ensure pip is up-to-date
    $PIPX_PIP install --upgrade pip
    
    # Install standard build tools
    $PIPX_PIP install --upgrade setuptools wheel
    
    log_message "pipx build dependencies verified." "$GREEN"
}


# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

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

# Optional step: Install GitHub CLI if snap is available
(command -v snap > /dev/null && log_message "Installing GitHub CLI via snap..." "$GREEN" && sudo snap install gh) || echo "Snap or gh snap not available."

log_message "System update process completed!" "$GREEN"

## Installing Dependencies for asdf and Python (including distutils)
log_message "Installing dependencies..." "$GREEN"
sudo apt install -y build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev curl \
libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
libffi-dev liblzma-dev cargo tree
log_message "Dependencies installation completed!" "$GREEN"

## Installing asdf
log_message "Fetching latest asdf version..." "$GREEN"
ASDF_VERSION=$(curl -s https://api.github.com/repos/asdf-vm/asdf/releases/latest | grep -oP '"tag_name": "\K[^"]+')

if [ -z "$ASDF_VERSION" ]; then
    log_message "Failed to fetch latest asdf version. Using default v0.15.0" "$YELLOW"
    ASDF_VERSION="v0.15.0"
fi

log_message "Installing asdf $ASDF_VERSION..." "$GREEN"
GIT_CONFIG_NO_DETACHED_ADVICE="git -c advice.detachedHead=false"
if ! $GIT_CONFIG_NO_DETACHED_ADVICE clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch "$ASDF_VERSION"; then
    log_message "Failed to install asdf. Please check your internet connection." "$RED"
    exit 1
fi

. "$HOME/.asdf/asdf.sh"
log_message "asdf installation completed!" "$GREEN"

## Updating bash PATH for asdf
log_message "Updating .bashrc for asdf..." "$GREEN"
echo '. "$HOME/.asdf/asdf.sh"' >> "$BASHRC_PATH"
echo '. "$HOME/.asdf/completions/asdf.bash"' >> "$BASHRC_PATH"
log_message ".bashrc update for asdf completed!" "$GREEN"

if [[ $- == *i* ]]; then
    source "$BASHRC_PATH"
fi

## Installing Python Versions
log_message "Running Python script for installing Python versions..." "$GREEN"
source "$HOME/.asdf/asdf.sh"

# Run the Python script with auto-confirm
if python3 latest-pythons.py <<< "y"; then
    log_message "Python versions installation completed!" "$GREEN"
else
    log_message "Python versions installation failed!" "$RED"
    exit 1
fi

## Installing python-launcher
log_message "Installing python-launcher using cargo..." "$GREEN"
cargo install python-launcher
log_message "Updating .bashrc for python-launcher..." "$GREEN"
echo 'export PATH="$PATH:$HOME/.cargo/bin"' >> "$BASHRC_PATH"
export PATH="$HOME/.cargo/bin:$PATH"
log_message "Listing available Python versions..." "$GREEN"
py --list

if [[ $- == *i* ]]; then
    source "$BASHRC_PATH"
fi

## Ensure Python build dependencies
ensure_python_build_deps() {
    log_message "Ensuring Python build dependencies..." "$GREEN"
    
    # Install system packages (skip python3-distutils if not available)
    if ! sudo apt install -y python3-dev build-essential; then
        log_message "Failed to install system build dependencies" "$RED"
        exit 1
    fi
    
    # Check if python3-distutils is needed (only for older Python versions)
    PYTHON_VERSION=$($PYTHON_BIN_PATH --version 2>&1 | awk '{print $2}')
    PYTHON_MAJOR=$(echo $PYTHON_VERSION | awk -F. '{print $1}' | tr -cd '[:digit:]')
    PYTHON_MINOR=$(echo $PYTHON_VERSION | awk -F. '{print $2}' | tr -cd '[:digit:]')
    
    # Only attempt to install distutils for Python < 3.12
    if [ "$PYTHON_MAJOR" -eq 3 ] && [ "$PYTHON_MINOR" -lt 12 ]; then
        if apt-cache show python3-distutils > /dev/null 2>&1; then
            sudo apt install -y python3-distutils
        else
            log_message "python3-distutils not available but not required for Python $PYTHON_VERSION" "$BLUE"
        fi
    else
        log_message "python3-distutils not required for Python $PYTHON_VERSION" "$BLUE"
    fi
    
    # Determine Python binary path with fallback
    PYTHON_BIN_PATH="python3"
    if command_exists asdf; then
        # Get the actual installed version path
        ASDF_PYTHON_PATH=$(asdf which python 2>/dev/null)
        if [ -n "$ASDF_PYTHON_PATH" ] && [ -f "$ASDF_PYTHON_PATH" ]; then
            PYTHON_BIN_PATH="$ASDF_PYTHON_PATH"
        else
            # Fallback to checking current version
            ASDF_PYTHON_VERSION=$(asdf current python 2>/dev/null | awk '{print $1}')
            if [ -n "$ASDF_PYTHON_VERSION" ]; then
                # Try both python and python3 binaries
                ASDF_PYTHON_PATH="$HOME/.asdf/installs/python/$ASDF_PYTHON_VERSION/bin/python"
                ASDF_PYTHON3_PATH="$HOME/.asdf/installs/python/$ASDF_PYTHON_VERSION/bin/python3"
                
                if [ -f "$ASDF_PYTHON_PATH" ]; then
                    PYTHON_BIN_PATH="$ASDF_PYTHON_PATH"
                elif [ -f "$ASDF_PYTHON3_PATH" ]; then
                    PYTHON_BIN_PATH="$ASDF_PYTHON3_PATH"
                else
                    log_message "Warning: asdf Python version found but binary not found at $ASDF_PYTHON_PATH or $ASDF_PYTHON3_PATH" "$YELLOW"
                fi
            fi
        fi
    fi
    
    # Verify Python binary exists
    if ! command_exists "$PYTHON_BIN_PATH"; then
        log_message "Error: Python binary not found at $PYTHON_BIN_PATH" "$RED"
        exit 1
    fi
    
    # Install pip packages
    if ! $PYTHON_BIN_PATH -m pip install --upgrade pip setuptools wheel; then
        log_message "Failed to install Python build tools" "$RED"
        exit 1
    fi
    
    # Verify installation
    if ! $PYTHON_BIN_PATH -c "import setuptools" &>/dev/null; then
        log_message "Failed to setup Python build environment!" "$RED"
        exit 1
    fi
    
    log_message "Python build dependencies verified." "$GREEN"
}

## Upgrading pip and Installing pipx
log_message "Upgrading pip and installing pipx..." "$GREEN"

# Ensure regular build dependencies
ensure_python_build_deps

# Determine Python binary path with fallback
PYTHON_BIN_PATH="python3"
if command_exists asdf; then
    ASDF_PYTHON_VERSION=$(asdf current python 2>/dev/null | awk '{print $1}')
    if [ -n "$ASDF_PYTHON_VERSION" ]; then
        ASDF_PYTHON_PATH="$HOME/.asdf/installs/python/$ASDF_PYTHON_VERSION/bin/python"
        if [ -f "$ASDF_PYTHON_PATH" ]; then
            PYTHON_BIN_PATH="$ASDF_PYTHON_PATH"
        else
            log_message "Warning: asdf Python version found but binary not found at $ASDF_PYTHON_PATH" "$YELLOW"
        fi
    fi
fi

# Verify Python binary exists
if ! command_exists "$PYTHON_BIN_PATH"; then
    log_message "Error: Python binary not found at $PYTHON_BIN_PATH" "$RED"
    exit 1
fi

# Install/upgrade pip and pipx
if ! $PYTHON_BIN_PATH -m pip install --upgrade pip; then
    log_message "Failed to upgrade pip" "$RED"
    exit 1
fi

if ! $PYTHON_BIN_PATH -m pip install --user pipx; then
    log_message "Failed to install pipx" "$RED"
    exit 1
fi

# Update PATH early to ensure pipx and other tools are available
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$BASHRC_PATH"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$BASHRC_PATH"
fi
export PATH="$HOME/.local/bin:$PATH"

# Also ensure asdf paths are available early
if ! grep -q 'export PATH="$HOME/.asdf/bin:$PATH"' "$BASHRC_PATH"; then
    echo 'export PATH="$HOME/.asdf/bin:$PATH"' >> "$BASHRC_PATH"
fi
export PATH="$HOME/.asdf/bin:$PATH"

# Ensure pipx-specific build dependencies
ensure_pipx_build_deps

log_message "Pip and pipx installation completed!" "$GREEN"

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
