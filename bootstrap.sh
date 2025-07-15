#!/bin/sh

# https://github.com/ramirocabral/dotfiles

### CONFIG ###

REPO_URL="https://github.com/ramirocabral/dotfiles"
REPO_DIR="dotfiles"

usercheck(){
    #checks username
    echo -e "Enter usename:"
    read name 
    id "$name" >/dev/null 2>/dev/null || error "Invalid username!"
    export HOMEDIR="/home/$name"
    export USERNAME="$name"
}

usercheck

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

USERNAME="${SUDO_USER:-$(logname)}"
HOMEDIR="$(eval echo "~$USERNAME")"

echo "##### Installing dependencies #####"
pacman -Sy --noconfirm git stow sudo python-pip base-devel zsh ca-certificates >/dev/null 2>&1

### CLONE DOTFILES ###

TARGET_DIR="$HOMEDIR/$REPO_DIR"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Cloning dotfiles..."
    sudo -u "$USERNAME" git clone "$REPO_URL" "$TARGET_DIR" >/dev/null 2>&1
else
    echo "$TARGET_DIR already exists. Skipping clone."
fi

chown -R "$USERNAME:$USERNAME" "$TARGET_DIR"

### APPLY DOTFILES ###

echo "Linking dotfiles with stow..."

# symlink all files in the repo to the user's home directory
sudo -u "$USERNAME" stow --ignore=".config" --ignore=".local" --dir="$TARGET_DIR" --target="$HOMEDIR" || echo "Failed to link dotfiles"

mkdir -p "$HOMEDIR/.config"
sudo -u "$USERNAME" stow -t --dir="$TARGET_DIR/.config" --target="$HOMEDIR/.config" || echo "Failed to link .config files"

mkdir -p "$HOMEDIR/.local"
sudo -u "$USERNAME" stow -t --dir="$TARGET_DIR/.local" --target="$HOMEDIR/.local" || echo "Failed to link .local files"

echo "Running autoinstall.sh..."

"$TARGET_DIR/autoinstall.sh $USERNAME" || echo "Failed to run autoinstall.sh"

echo -e "DONE! Now reboot your system."
