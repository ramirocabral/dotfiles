#!/bin/sh

# https://github.com/ramirocabral/dotfiles

# Inspired by Luke Smith LARBS script : https://github.com/LukeSmithxyz/LARBS

### VARIABLES ###

aurhelper="paru"
USERNAME="${SUDO_USER:-$(logname)}"
USER_HOME="$(eval echo "~$USERNAME")"
REPODIR="$USER_HOME/.local/src"

### FUNCTIONS ###

error(){
    #print error and exit with failure
    echo -e "ERROR : $1"
    exit 1
}

usercheck(){
    [ -f "$REPODIR" ] || mkdir -p "$REPODIR"
    echo -e "Enter Samba Server user:"
    read smb_name
    echo -e "Enter Samba Server password"
    read smb_password

    echo "username=$smb_name" >> "$USER_HOME/.credentials"
    echo "password=$smb_password" >> "$USER_HOME/.credentials"
    echo "domain=WORKGROUP" >> "$USER_HOME/.credentials"
}

install_aur(){
    sudo -u "$name" mkdir -p "$repodir/$1"      #create directory
    sudo -u "$name" git -C "$repodir" clone --depth 1  --no-tags -q "https://aur.archlinux.org/$1.git" "$repodir/$1"
    cd "$repodir/$1" || return 1
    sudo -u "$name"  makepkg --noconfirm -si "$repodir/$1" >/dev/null 2>&1 || return 1
}

installpkg(){
    #install packages wihtout confirming and avoid updating already installed packages
    pacman --noconfirm --needed -S "$1" >/dev/null 2>&1 || echo -e "Error installing $1 (PACMAN)"
}

aurinstall(){
    #install aur packages
    echo "$aurinstalled" | grep -q "^$1$" && return 0
    sudo -u "$name" $aurhelper -S --noconfirm "$1" >/dev/null 2>&1 || echo "Failed installing $1 (AUR)"
}

gitinstall(){
    #just to install p10k, no need to use make 
    progname="${1##*/}"
    echo "$gitinstalled" | grep -q "^$progname$" && return 0
	progname="${progname%.git}"
	dir="$repodir/$progname"
    sudo -u "$name" git -C "$repodir" clone --depth 1 --single-branch \
        --no-tags -q "$1" "$dir" ||
        {
            cd "$dir" || echo "Failed installing $1 (GIT)"
            sudo -u "$name" git pull --force origin master
        }
    cd "$dir" || return 1
}

pipinstall(){
    #checks if pip is already installed
    [ -x "$(command -v "pip")" ] || installpkg python-pip >/dev/null 2>&1
    echo "$pipinstalled" | grep -q "^$1$" && return 1
    pip install --break-system-packages $1 >/dev/null 2>&1 || echo "Failed installing $1 (PIP)"
}

installationloop(){
    progsfile="$homedir/progs.csv"
    #using a temp file to prevent editing the original programs file
    ([ -f "$progsfile" ] &&  sed '/^#/d' "$progsfile" >/tmp/progs.csv) \
        || error "Programs file not found"
    aurinstalled="$(pacman -Qqm)"
    gitinstalled="$(ls "$repodir")"
    pipinstalled="$(pip list | awk '{print $1}' | tail -n +3)"
    tmpfile="/tmp/progs.csv"
    while IFS=, read -r tag program; do
        echo "Installing $program"
        case "$tag" in
            "p") installpkg "$program" ;;
            "g") gitinstall "$program" ;;
            "a") aurinstall "$program" ;;
            "i") pipinstall "$program" ;;
        esac
    done <"$tmpfile"
}

### SCRIPT ###

usercheck


[ -f /etc/sudoers.pacnew ] && cp /etc/sudoers.pacnew /etc/sudoers # Just in case

# Allow user to run sudo without password. Since AUR programs must be installed
# in a fakeroot environment, this is required for all builds with AUR.

trap 'rm -f /etc/sudoers.d/larbs-temp' HUP INT QUIT TERM PWR EXIT  # delete file if user exits
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/larbs-temp   # allow wheel users(everyone) to run sudo without password


# Install aur helper manually
echo "Installing AUR Helper..."
sudo chmod -R 777 "$repodir"
install_aur "${aurhelper}" || error "Failed to install AUR helper"

# Main instalattion loop

installationloop

# Make zsh the default shell for the user.
chsh -s /bin/zsh "$name" >/dev/null 2>&1
# just for zsh-autocompletions
sudo -u "$name" mkdir -p "$HOME/.cache/zsh/"

#enable lightdm service
systemctl enable lightdm

#User folders
sudo -u "$name" mkdir -p "$HOMEDIR/Screenshots"
sudo -u "$name" mkdir -p "$HOMEDIR/Desktop"
sudo -u "$name" mkdir -p "$HOMEDIR/Documents"
sudo -u "$name" mkdir -p "$HOMEDIR/projects"
sudo -u "$name" mkdir -p "$HOMEDIR/facultad"
sudo mkdir -p /mnt/nas
sudo mkdir -p /mnt/nas/ramiro /mnt/nas/public

# mount NAS smb shares
echo "//nas.lan/public /mnt/nas/public cifs    credentials=/home/ramiro/.credentials,uid=1000,gid=100,dir_mode=0770,file_mode=0660 0 2" >> /etc/fstab
echo "//nas.lan/ramiro /mnt/nas/ramiro cifs    credentials=/home/ramiro/.credentials,uid=1000,gid=100,dir_mode=0770,file_mode=0660 0 3" >> /etc/fstab

ln -s ""$HOMEDIR/librewolf.overrides.cfg" $HOMEDIR/.librewolf/librewolf.overrides.cfg" 

# set up cups client
systemctl enable --now cups.service
lpadmin -p my_network_printer -E -v ipp://192.168.9.7:631/printers/EPSONL395 -m everywhere
