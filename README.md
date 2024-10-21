# pyqwer

*Quickly configure a newly installed Ubuntu environment for Python development using asdf-python and an opinionated set of tools.*

----

This project provides a set of scripts for setting up a comprehensive command-line-driven Python development environment on Ubuntu, including tools I frequently use, like `asdf`, `python-launcher`, `pipx`, `build`, `tox`, `pre-commit`, and `cookiecutter`.

In addition to updating Ubuntu and installing dependencies and tools, it automatically installs the three latest minor versions of Python using [asdf](https://asdf-vm.com/) (via the [asdf-python](https://github.com/asdf-community/asdf-python) plugin, which uses [pyenv](https://github.com/pyenv/pyenv)) for development and testing.

I made this to speed up my tinkering and experiments and to ensure that even for trivial projects, I always start with a base foundation that can easily support and encourage proper multi-version testing and distribution packaging. In the past, I always overlooked distribution packaging when starting a new project. I now realize how important it is, not just for sharing code, but to help enforce cohesion and encapsulation and to create a mindset that creates opportunities for composition.

This is definitely a script I made for myself, but if you find this helpful, that's great, too!

## Features

- **System Update**: Automatically updates and upgrades the system using APT.
- **Dependencies Installation**: Installs necessary dependencies for asdf, Python, and python-launcher.
- **Python Version Management**: Installs multiple Python versions using asdf and sets the global Python version.
- **Python-Launcher**: Installs [python-launcher](https://python-launcher.app/) via `cargo` for easy Python version switching on Linux.
- **Development Tools**: Installs essential Python development tools using pipx.
- **asdf Installation**: Installs asdf (version v0.14.1). Check [asdf-vm.com](https://asdf-vm.com/guide/getting-started.html#_2-download-asdf) for the latest branch version and modify the script as needed to use the latest.

## Scripts

1. `pyqwer.sh`: The main script to set up the development environment.
2. `latest-pythons.py`: A Python script that gets called by `pyqwer.sh` to automate the installation of the latest minor Python versions using asdf.
3. `pyqwer-from-github.sh`: A script to download and execute the setup and installer scripts directly from GitHub. This is the recommended way of running the scripts.

## Getting Started

### Prerequisites

- A running Ubuntu system (native or via WSL2 or another VM)
- Internet access for downloading required packages and tools

### WSL2 Cheat Sheet (Optional)

You don't need WSL2 to use pyqwer, but if you are using WSL2 to host Ubuntu you may find these notes helpful.

I typically use WSL2 on Windows 11 to host my Ubuntu development environment. But this script will work for a native Ubuntu system or one hosted on another VM platform.

Here is my cheat sheet to create and tear down my WSL2 environment:

#### List Existing WSL2 Distributions

You might want to start by identifying any WSL2 distributions already installed:

```cmd
(cmd or PowerShell) PS C:\> wsl --list
```

On my system I see that I already have an Ubuntu distro installed:

```PS C:\Users\marmo> wsl --list
Windows Subsystem for Linux Distributions:
Ubuntu-24.04 (Default)
PS C:\Users\marmo>
```

This Ubuntu-24.04 is old and unused, and since I want to start fresh I'll remove it like this

Remove and **delete** the entire Ubuntu system (you will *lose any work in this instance*):

```cmd
(cmd or PowerShell) PS C:\> wsl --unregister Ubuntu-24.04
```

I will then install a fresh Ubuntu-24.04 system like this

```cmd
(cmd or PowerShell) PS C:\> wsl --install -d Ubuntu-24.04
```

#### Setting Up Ubuntu in WSL2

This will install WSL2 and Ubuntu if you have not set up WSL yet in Windows 11:

```cmd
(Admin cmd or PowerShell) PS C:\> wsl --install
```

To update WSL2 itself:

```cmd
(cmd or PowerShell) PS C:\> wsl --update
```

To see installed distros:

```cmd
(cmd or PowerShell) PS C:\> wsl -l -v
```

Look at online available distros:

```cmd
(cmd or PowerShell) PS C:\> wsl --list --online
```

Install a distro by name:

```cmd
(cmd or PowerShell) PS C:\> wsl --install -d Ubuntu-24.04
```

After this runs, you must manually set up a username and password from the root shell:

Add a new user called marmor:

```bash
adduser marmor
```

Add the user to the sudo group:

```bash
usermod -aG sudo marmor
```

Change the default user to avoid launching into the root shell:

Exit WSL and run this from your Windows command prompt (CMD or PowerShell):

```PS
wsl -d Ubuntu-24.04 -u marmor
```

#### Tearing Down Ubuntu in WSL2

Shut down *ALL* the WSL distros:

```cmd
(cmd or PowerShell) PS C:\> wsl --shutdown
```

Terminate Ubuntu on WSL2 (or any specific named distro):

```cmd
(cmd or PowerShell) PS C:\> wsl -t Ubuntu-24.04
```

Remove and **delete** the entire Ubuntu system (you will *lose any work in this instance*):

```cmd
(cmd or PowerShell) PS C:\> wsl --unregister Ubuntu-24.04
```

### Installation

This script was developed to be run on a fresh install of Ubuntu as a quick start to development.

**Please do not run this on a system that already has things you care about on it!**

#### Method 1 (recommended): Run directly from GitHub

The recommended way to run the script is directly from GitHub using `curl`. Ubuntu includes `curl` and `bash`, which should already be on your newly installed system.

The command below downloads the setup and installer scripts from the GitHub repository and executes them on your Ubuntu system.

To install and set up the Python development environment, run the following command as your local user (not as root):

```bash
curl -sL https://raw.githubusercontent.com/mmarmor/pyqwer/main/pyqwer-from-github.sh | bash
```

After the script finishes run `source` to apply the changes made to your environment variables in the current shell session.

```bash
source ~/.bashrc
```

#### Method 2: Clone this project to your Unbuntu system and run the scripts manually

If you don't want to run the code from GitHub, you can also use `git` to clone this repository to your home directory. You then make the files executable with `chmod` and `source` the shell script to start the program.

Here are the commands:

```bash
cd ~
git clone https://github.com/mmarmor/pyqwer.git
sudo chmod +x pyqwer.sh latest-pythons.py
source pyqwer.sh
```

After the script finishes run `source` to apply the changes made to your environment variables in the current shell session.

```bash
source ~/.bashrc
```

### Verify Installations

Check Python Versions (assuming here that 3.13 is the most recent version):

```bash
python --version
python3.13 --version
python3.12 --version
python3.11 --version
```

Verify pipx Tools:

```bash
pipx list
```

Test python-launcher:

```bash
py --version
py -3.13 --version
```

You can now proceed with using your newly set up Python development environment.

## Customization

This script installs the three most recent minor versions of Python (for example, 3.13.X, 3.12.X, 3.11.X) and sets the most recent (3.13.X in the example) as the global default. You can customize the number of Python versions to install by modifying the `count` parameter in the `install_python_versions` function call inside `latest-pythons.py`.

## License

This project is licensed under the GNU General Public License v3.0 - see the [COPYING](COPYING) file for details.

## Author

- [Michael Marmor](https://michaelmarmor.com/)

If you want to connect with me, the best way is through [my website](https://michaelmarmor.com/).
