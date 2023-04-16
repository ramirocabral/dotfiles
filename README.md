# dotfiles

My Arch Linux dotfiles repo. I use [qtile](https://www.qtile.org/) as my window manager.


## Installation

### Prerequisites

* [git](https://git-scm.com/)
* [zsh](http://www.zsh.org/)

### Packages

The installed packages are listed in the [packages](packages) file.

### Install

```bash
    cd ~
    git clone https://github.com/ramirocabral/dotfiles.git
    cd dotfiles
    ./autoinstall.sh
```

## Keybindings

You can find the keybindings in the [qtile](.config/qtile/settings/keys.py) config file.

| Key                     | Action                           |
| ----------------------- | -------------------------------- |
| **mod + j**             | next window (down)               |
| **mod + k**             | next window (up)                 |
| **mod + q**             | next window                      |
| **mod + e**             | open Thunar                      |
| **mod + m**             | open Rofi                        |
| **mod + b**             | open Firefox                     |
| **mod + return**        | open Terminal                    |
| **mod + shift + h**     | decrease master                  |
| **mod + shift + l**     | increase master                  |
| **mod + shift + j**     | move window down                 |
| **mod + shift + k**     | move window up                   |
| **mod + shift + f**     | toggle floating                  |
| **mod + tab**           | change layout                    |
| **mod + [1-9]**         | Switch to workspace N (1-9)      |
| **mod + shift + [1-9]** | Send Window to workspace N (1-9) |
| **mod + period**        | Focus next monitor               |
| **mod + comma**         | Focus previous monitor           |
| **mod + w**             | kill window                      |
| **mod + ctrl + r**      | restart wm                       |
| **mod + ctrl + q**      | quit                             |

### TODO

* Add makefile
* Screenshots
* Add /etc apps
* new binaries