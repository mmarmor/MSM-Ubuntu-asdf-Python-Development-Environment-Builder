"""
latest-pythons.py | MSM 24-Jan-2024

Copyright (C) 2024 Michael Marmor | https://michaelmarmor.com/
You should have received a copy of the GNU General Public License
along with this program. If not, see https://www.gnu.org/licenses/.

This program was created to be called by pyqwer.sh

Summary:
This program automates the process of installing the latest Python
versions using asdf. It is designed to identify and install the most
recent minor releases of Python 3, ensuring that the user has access
to the latest features and security updates.

Before installing Python versions, it creates the
'~/.default-python-packages' file and writes a list of essential
packages to it (pip, setuptools, wheel). This ensures these packages
are automatically installed with each new Python version.

The program works by parsing the output of 'asdf list all python',
filtering out versions that do not meet specific criteria (only Python
3 versions in the 'X.Y.Z' format), and then determining the latest
three minor versions. It then installs these versions using asdf and
sets the most recent version as the global Python version.

Users can easily customize the number of versions to install by
modifying the 'count' parameter in the 'install_python_versions'
function call.

Usage:
Run the script directly to install the latest three minor Python
versions. Modify the 'count' parameter in the 'install_python_versions'
function call to change the number of versions to install.
"""

import subprocess
import os
import sys

def create_default_python_packages_file():
    """
    Creates the '~/.default-python-packages' file and writes a list of essential packages.
    If file exists, appends missing packages instead of overwriting.
    """
    default_packages_path = os.path.expanduser("~/.default-python-packages")
    packages = ["pip", "setuptools", "wheel"]

    if os.path.exists(default_packages_path):
        # Read existing packages
        with open(default_packages_path, "r") as file:
            existing_packages = set(line.strip() for line in file.readlines())
        
        # Add only new packages
        with open(default_packages_path, "a") as file:
            for package in packages:
                if package not in existing_packages:
                    file.write(package + "\n")
    else:
        # Create new file with all packages
        with open(default_packages_path, "w") as file:
            for package in packages:
                file.write(package + "\n")

def add_asdf_python_plugin():
    """
    Adds the Python plugin to asdf if it's not already added.
    """
    try:
        existing_plugins = subprocess.check_output(['asdf', 'plugin', 'list']).decode('utf-8')
        if 'python' not in existing_plugins:
            subprocess.run(['asdf', 'plugin', 'add', 'python'])
            print("Python plugin added to asdf.")
    except subprocess.CalledProcessError as e:
        print(f"Error checking or adding asdf Python plugin: {e}")

def parse_asdf_output(output):
    """
    Parses the output of 'asdf list all python' to extract available Python versions.

    Args:
        output (str): The output string from 'asdf list all python'.

    Returns:
        list: A list of available Python version strings.
    """
    lines = output.split('\n')
    version_lines = [line.strip() for line in lines if line.strip() and line.strip()[0].isdigit()]
    return version_lines

def is_valid_version(version):
    """
    Checks if the version string is in the 'X.Y.Z' format and contains only numbers.

    Args:
        version (str): A version string.

    Returns:
        bool: True if the version string is valid, False otherwise.
    """
    parts = version.split('.')
    return len(parts) == 3 and all(part.isdigit() for part in parts)

def get_latest_asdf_versions(output, count=3):
    """
    Retrieves the latest 'count' minor releases of Python 3 available in asdf.

    Args:
        output (str): The output string from 'asdf list all python'.
        count (int): The number of latest minor versions to retrieve.

    Returns:
        list: A list of the latest 'count' minor Python versions available in asdf.
    """
    valid_versions = [v for v in parse_asdf_output(output) if v.startswith('3.') and is_valid_version(v)]
    minor_patch_versions = [(int(v.split('.')[1]), int(v.split('.')[2])) for v in valid_versions]
    minor_patch_versions.sort(reverse=True)

    latest_minors = set()
    for minor, _ in minor_patch_versions:
        latest_minors.add(minor)
        if len(latest_minors) == count:
            break

    selected_versions = []
    for minor in latest_minors:
        highest_patch = max(patch for m, patch in minor_patch_versions if m == minor)
        selected_versions.append(f"3.{minor}.{highest_patch}")

    return sorted(selected_versions, reverse=True)

def install_python_versions(count=3):
    """
    Installs the latest 'count' minor Python versions using asdf and sets them as global versions.
    The most recent version is listed first. Before installing, it creates and sets up the
    '~/.default-python-packages' file and adds the Python plugin to asdf.

    Args:
        count (int): The number of latest minor versions to install.
    """
    create_default_python_packages_file()
    add_asdf_python_plugin()

    try:
        # Verify asdf is installed
        subprocess.run(['asdf', '--version'], check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        
        # Get available versions
        output = subprocess.check_output(['asdf', 'list', 'all', 'python']).decode('utf-8')
        versions = get_latest_asdf_versions(output, count=count)
        
        if not versions:
            print("No valid Python 3.x versions found in asdf.")
            return

        print(f"\nThe following Python versions will be installed: {', '.join(versions)}")
        print(f"Python {versions[0]} will be set as the global default.")
        response = input("Do you want to continue? [Y/n]: ").strip().lower()
        
        if response and response != 'y':
            print("Installation cancelled.")
            return

        for version in versions:
            print(f"\nInstalling Python {version}...")
            try:
                subprocess.run(['asdf', 'install', 'python', version], check=True)
            except subprocess.CalledProcessError as e:
                print(f"Failed to install Python {version}: {e}")
                continue

        # Setting the most recent version as the first global version and including the others
        asdf_global_command = ['asdf', 'global', 'python'] + versions
        print(f"\nSetting Python versions {', '.join(versions)} as global versions...")
        subprocess.run(asdf_global_command, check=True)
        
        # Verify installation
        print("\nVerifying installed versions...")
        installed_versions = subprocess.check_output(['asdf', 'list', 'python']).decode('utf-8')
        print(installed_versions)
        
    except subprocess.CalledProcessError as e:
        print(f"\nError: {e}")
        print("Please ensure asdf is installed and properly configured.")
        sys.exit(1)

if __name__ == "__main__":
    install_python_versions(count=3)  # Change 'count' to install a different number of versions
