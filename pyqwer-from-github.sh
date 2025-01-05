#!/bin/bash

# Copyright (C) 2024 Michael Marmor | https://michaelmarmor.com/
# You should have received a copy of the GNU General Public License
# along with this program. If not, see https://www.gnu.org/licenses/.
#
# pyqwer-from-github.sh | MSM 24-Jan-2024

# To use this script:
# curl -sL https://raw.githubusercontent.com/mmarmor/pyqwer/main/pyqwer-from-github.sh | bash

# Define the GitHub repository and branch
REPO_URL="https://raw.githubusercontent.com/mmarmor/pyqwer/main"

# Define the filenames
SETUP_SCRIPT="pyqwer.sh"
INSTALLER_SCRIPT="latest-pythons.py"

# Download the scripts with error handling
log_message "Downloading $SETUP_SCRIPT..." "$GREEN"
if ! curl -sLO "$REPO_URL/$SETUP_SCRIPT"; then
    log_message "Failed to download $SETUP_SCRIPT. Please check your internet connection." "$RED"
    exit 1
fi

log_message "Downloading $INSTALLER_SCRIPT..." "$GREEN"
if ! curl -sLO "$REPO_URL/$INSTALLER_SCRIPT"; then
    log_message "Failed to download $INSTALLER_SCRIPT. Please check your internet connection." "$RED"
    exit 1
fi

# Make scripts executable
chmod +x "$SETUP_SCRIPT" "$INSTALLER_SCRIPT"

# Run the setup script
echo "Running pyqwer script..."
source "./$SETUP_SCRIPT"
