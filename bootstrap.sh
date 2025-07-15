#!/bin/sh

# https://github.com/ramirocabral/dotfiles

### CONFIG ###

REPO_URL="https://github.com/ramirocabral/dotfiles"
REPO_DIR="dotfiles"

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

USERNAME="${SUDO_USER:-$(logname)}"
USER_HOME="$(eval echo "~$USERNAME")"

echo "Detected user: $USERNAME"
echo "Home directory: $USER_HOME"

echo "##### Installing dependencies #####"
pacman -Sy --noconfirm git stow sudo python-pip base-devel zsh ca-certificates >/dev/null 2>&1

### CLONE DOTFILES ###

TARGET_DIR="$USER_HOME/$REPO_DIR"

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
sudo -u "$USERNAME" stow --ignore=".config" --ignore=".local" --dir="$TARGET_DIR" --target="$USER_HOME" .

mkdir -p "$USER_HOME/.config"
sudo -u "$USERNAME" stow -t --dir="$TARGET_DIR/.config" --target="$USER_HOME/.config" .config || echo "Failed to link .config files"

mkdir -p "$USER_HOME/.local"
sudo -u "$USERNAME" stow -t --dir="$TARGET_DIR/.local" --target="$USER_HOME/.local" .local || echo "Failed to link .local files"

echo "Running autoinstall.sh..."
"$TARGET_DIR/autoinstall.sh"

echo -e "DONE! Now reboot your system."
