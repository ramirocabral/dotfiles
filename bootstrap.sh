#!/bin/sh

# https://github.com/ramirocabral/dotfiles

### CONFIG ###

REPO_URL="https://github.com/ramirocabral/dotfiles"
REPO_DIR="dotfiles"
LOG="/var/log/dotfiles-bootstrap.log"

error(){
    printf 'ERROR: %s\n' "$1" >&2
    exit 1
}

[ "$(id -u)" -eq 0 ] || error "This script must be run as root."

usercheck(){
    printf 'Enter username: '
    read -r USERNAME
    [ -n "$USERNAME" ] && id "$USERNAME" >/dev/null 2>&1 || error "Invalid username: '$USERNAME'"
    HOMEDIR="$(getent passwd "$USERNAME" | cut -d: -f6)"
}

usercheck

echo "##### Installing dependencies #####"
# -Syu, not -Sy: refreshing the databases without upgrading is a partial upgrade.
pacman -Syu --needed --noconfirm git stow sudo python-pip python-pipx base-devel zsh ca-certificates dialog >>"$LOG" 2>&1 \
    || error "Failed to install dependencies, see $LOG"

### CLONE DOTFILES ###

TARGET_DIR="$HOMEDIR/$REPO_DIR"

if [ ! -d "$TARGET_DIR/.git" ]; then
    echo "Cloning dotfiles..."
    sudo -u "$USERNAME" git clone -q "$REPO_URL" "$TARGET_DIR" || error "Failed to clone $REPO_URL into $TARGET_DIR"
else
    echo "$TARGET_DIR already exists. Skipping clone."
fi

chown -R "$USERNAME:" "$TARGET_DIR"

# Relink after every pull, see .githooks/post-merge.
sudo -u "$USERNAME" git -C "$TARGET_DIR" config core.hooksPath .githooks

### APPLY DOTFILES ###

echo "Linking dotfiles with stow..."

# Stow folds a directory into a single symlink only when it does not exist yet.
# Create the directories that apps also write into, so they stay real in $HOME
# and only the tracked files inside them get linked; folded, every app's state
# would land in the repo. What the repo does not stow is in .stow-local-ignore.
sudo -u "$USERNAME" mkdir -p "$HOMEDIR/.config" "$HOMEDIR/.local/bin" "$HOMEDIR/.local/share/applications"

# A fresh home already has skeleton files (.bashrc...) that make stow abort on
# conflict. --adopt moves them into the repo and links them in their place, and
# the checkout afterwards puts the tracked versions back. That checkout discards
# local changes, so only do it on a clean working tree.
cd "$TARGET_DIR" || error "Cannot enter $TARGET_DIR"
if [ -z "$(sudo -u "$USERNAME" git status --porcelain)" ]; then
    sudo -u "$USERNAME" stow --adopt -t "$HOMEDIR" . \
        && sudo -u "$USERNAME" git checkout -q -- . \
        || error "Failed to link dotfiles"
else
    sudo -u "$USERNAME" stow -t "$HOMEDIR" . \
        || error "Failed to link dotfiles ($TARGET_DIR has local changes, so conflicts were not adopted)"
fi

echo "Running autoinstall.sh..."

bash "$TARGET_DIR/autoinstall.sh" "$USERNAME" || error "autoinstall.sh failed"

echo "DONE! Now reboot your system."
