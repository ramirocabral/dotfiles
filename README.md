# dotfiles

These are my Arch Linux dotfiles. I use [qtile](http://www.qtile.org/) as my window manager, [zsh](http://www.zsh.org/) as my shell, and [nvim](https://github.com/neovim/neovim) as my editor.

## Installation

### Prerequisites

* Arch Linux based distro
* [git](https://git-scm.com/)

### Packages

The installed packages are listed in the [progs.csv](progs.csv) file.

The first column determines how the program is installed:
* a : AUR helper
* p : Pacman
* g : Git clone
* i : Python Pip

The second column is the name of the package.

### Install


```bash
git clone https://github.com/ramirocabral/dotfiles /tmp/dotfiles
/cp -rfT /tmp/dotfiles $HOME
sudo su
./autoinstall.sh
```

