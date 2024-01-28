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

# Download the scripts
echo "Downloading $SETUP_SCRIPT..."
curl -sLO "$REPO_URL/$SETUP_SCRIPT"

echo "Downloading $INSTALLER_SCRIPT..."
curl -sLO "$REPO_URL/$INSTALLER_SCRIPT"

# Make scripts executable
chmod +x "$SETUP_SCRIPT" "$INSTALLER_SCRIPT"

# Run the setup script
echo "Running pyqwer script..."
source "./$SETUP_SCRIPT"
