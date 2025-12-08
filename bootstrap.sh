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

echo "##### Installing dependencies #####"
pacman -Sy --noconfirm git stow sudo python-pip base-devel zsh ca-certificates dialog >/dev/null 2>&1

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
cd $TARGET_DIR
sudo -u "$USERNAME" stow --adopt --ignore=".config" --ignore=".local" . || echo "Failed to link dotfiles"

# this is dumb but i swear there is not a better way to do it
mkdir -p "$HOMEDIR/.config"
cd "$TARGET_DIR/.config"
stow --target="$HOMEDIR/.config" . || echo "Failed to link .config files"

mkdir -p "$HOMEDIR/.local"
cd "$TARGET_DIR/.local"
stow --target="$HOMEDIR/.local" . || echo "Failed to link .local files"

echo "Running autoinstall.sh..."

cd "$HOMEDIR"
chown -R "$USERNAME:$USERNAME" .

bash "$TARGET_DIR/autoinstall.sh" "$USERNAME" || echo "Failed to run autoinstall.sh"

echo -e "DONE! Now reboot your system."
