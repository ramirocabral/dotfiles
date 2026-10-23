#!/bin/bash

# https://github.com/ramirocabral/dotfiles

# Inspired by Luke Smith LARBS script

### VARIABLES ###

aurhelper="paru"
USERNAME="$1"
[ -z "$USERNAME" ] && echo "Error: Username not provided." && exit 1
[ "$(id -u)" -ne 0 ] && echo "Error: must be run as root." && exit 1
id "$USERNAME" >/dev/null 2>&1 || { echo "Error: user '$USERNAME' does not exist."; exit 1; }

HOMEDIR="$(getent passwd "$USERNAME" | cut -d: -f6)"
DOTFILESDIR="$HOMEDIR/dotfiles"
REPODIR="$HOMEDIR/.local/src"
PROGSFILE="$DOTFILESDIR/progs.csv"
LOG="/var/log/dotfiles-autoinstall.log"

# Store failed installations
failed_items=()

### FUNCTIONS ###

error(){
    clear
    echo -e "ERROR : $1"
    exit 1
}

configuration_wizard() {
    # Select Features (Checklist)
    cmd=(dialog --separate-output --checklist "Select features to configure/install:" 22 76 16)
    options=(
        "SMB"       "Mount NAS Server (Samba)" off
        "CUPS"      "Install & Configure Printer" off
        "TMUX"      "Install Tmux Plugins (TPM)" on
        "ZSH"       "Set ZSH as default shell" on
    )
    features_choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    clear
}

setup_sudo() {
    usermod -aG wheel "$USERNAME"
    # Permanent rule: wheel can use sudo with the user's password.
    echo "%wheel ALL=(ALL:ALL) ALL" >/etc/sudoers.d/00-wheel
    # Passwordless only while this script runs, so makepkg and paru don't prompt.
    # Files in sudoers.d are read in order, so this one wins while it exists.
    trap 'rm -f /etc/sudoers.d/larbs-temp' HUP INT QUIT TERM PWR EXIT
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/larbs-temp
    chmod 440 /etc/sudoers.d/00-wheel /etc/sudoers.d/larbs-temp
    visudo -c >/dev/null || error "sudoers is invalid after writing /etc/sudoers.d"
}

# Machine-specific files are gitignored; seed each one from its tracked .example
# so the configs that include them work on a fresh install. Never overwrite.
seed_local_files() {
    for f in .config/zsh/.local .config/sway/monitor.conf .config/i3/monitor.conf .config/waybar/local.jsonc; do
        if [ ! -e "$DOTFILESDIR/$f" ] && [ -f "$DOTFILESDIR/$f.example" ]; then
            sudo -u "$USERNAME" cp "$DOTFILESDIR/$f.example" "$DOTFILESDIR/$f"
            echo "Seeded $f -- edit it for this machine."
        fi
    done
}

setup_smb() {
    SMB_SERVER=$(dialog --title "Samba Setup" --inputbox "NAS address:" 8 40 "192.168.9.5" --output-fd 1)
    SMB_SHARES=$(dialog --title "Samba Setup" --inputbox "Shares to mount (space separated):" 8 50 "public personal" --output-fd 1)
    SMB_USER=$(dialog --title "Samba Setup" --inputbox "Enter Samba Server User:" 8 40 --output-fd 1)
    SMB_PASS=$(dialog --title "Samba Setup" --passwordbox "Enter Samba Server Password:" 8 40 --output-fd 1)
    clear

    { [ -z "$SMB_SERVER" ] || [ -z "$SMB_USER" ]; } && echo "Skipping SMB setup (empty server or user)." && return

    creds="$HOMEDIR/.credentials"
    printf 'username=%s\npassword=%s\ndomain=WORKGROUP\n' "$SMB_USER" "$SMB_PASS" > "$creds"
    chmod 600 "$creds"
    chown "$USERNAME:" "$creds"

    uid=$(id -u "$USERNAME")
    gid=$(id -g "$USERNAME")
    for share in $SMB_SHARES; do
        mnt="/mnt/nas/$share"
        mkdir -p "$mnt"
        if grep -qs "[[:space:]]$mnt[[:space:]]" /etc/fstab; then
            echo "$mnt is already in /etc/fstab, skipping."
            continue
        fi
        # nofail + automount: boot neither waits for nor hangs on an unreachable
        # NAS (a laptop away from home); the share mounts on first access.
        echo "//$SMB_SERVER/$share $mnt cifs credentials=$creds,uid=$uid,gid=$gid,dir_mode=0770,file_mode=0660,_netdev,nofail,x-systemd.automount,x-systemd.idle-timeout=300 0 0" >> /etc/fstab
    done
    systemctl daemon-reload

    echo "Samba configured."
}

enable_service(){
    # Skip units whose package was not selected.
    systemctl cat "$1" >/dev/null 2>&1 || return 0
    if systemctl enable "$1" >>"$LOG" 2>&1; then
        echo "Enabled $1"
    else
        echo "    [X] FAILED to enable $1"
        failed_items+=("$1 (service)")
    fi
}

# --- INSTALLATION FUNCTIONS ---

install_aurhelper(){
    # Checks that it runs, not just that it exists: a helper built against an
    # older libalpm is still on $PATH after a pacman upgrade but fails to start.
    "$aurhelper" --version >/dev/null 2>&1 && return 0
    # Built from source on purpose: paru-bin links a fixed libalpm soname and
    # breaks every time pacman bumps it.
    pkg="$aurhelper"
    dir="$REPODIR/$pkg"
    sudo -u "$USERNAME" mkdir -p "$REPODIR"
    [ -d "$dir" ] || sudo -u "$USERNAME" git clone --depth 1 --no-tags -q "https://aur.archlinux.org/$pkg.git" "$dir" || return 1
    # -f: a build left over from an interrupted run would make makepkg refuse.
    (cd "$dir" && sudo -u "$USERNAME" makepkg --noconfirm -sif) >>"$LOG" 2>&1
    "$aurhelper" --version >/dev/null 2>&1
}

installpkg(){
    pacman --noconfirm --needed -S "$@" >>"$LOG" 2>&1
}

aurinstall(){
    echo "$aurinstalled" | grep -qx -- "$1" && return 0
    sudo -u "$USERNAME" $aurhelper -S --noconfirm --needed --skipreview "$1" >>"$LOG" 2>&1
}

gitinstall(){
    progname="${1##*/}"
    progname="${progname%.git}"
    dir="$REPODIR/$progname"
    sudo -u "$USERNAME" mkdir -p "$REPODIR"
    if [ -d "$dir/.git" ]; then
        sudo -u "$USERNAME" git -C "$dir" pull --ff-only -q >>"$LOG" 2>&1
    else
        sudo -u "$USERNAME" git clone --depth 1 --single-branch --no-tags -q "$1" "$dir" >>"$LOG" 2>&1
    fi
}

pipinstall(){
    command -v pip >/dev/null 2>&1 || installpkg python-pip
    echo "$pipinstalled" | grep -qix -- "$1" && return 0
    pip install --break-system-packages "$1" >>"$LOG" 2>&1
}

pipxinstall(){
    command -v pipx >/dev/null 2>&1 || installpkg python-pipx
    echo "$pipxinstalled" | grep -qx -- "$1" && return 0
    sudo -u "$USERNAME" pipx install "$1" >>"$LOG" 2>&1
}

install_tmux_plugins(){
    echo "Installing Tmux plugins..."
    tpm="$HOMEDIR/.config/tmux/plugins/tpm"
    if [ ! -d "$tpm" ]; then
        sudo -u "$USERNAME" git clone -q https://github.com/tmux-plugins/tpm "$tpm" || {
            echo "Failed to clone tpm"
            return 1
        }
    fi
    # install_plugins reads the plugin list from a running tmux server, so start
    # a throwaway session that loads tmux.conf (whose `run tpm` line sets
    # TMUX_PLUGIN_MANAGER_PATH). Only that session is killed afterwards, never
    # the server: on a re-run the user may have sessions open.
    sudo -H -u "$USERNAME" bash -c '
        tmux new-session -d -s tpm-install || exit 1
        for _ in $(seq 50); do
            tmux show-environment -g TMUX_PLUGIN_MANAGER_PATH >/dev/null 2>&1 && break
            sleep 0.1
        done
        "$1/bin/install_plugins"
        rc=$?
        tmux kill-session -t tpm-install
        exit $rc
    ' _ "$tpm" >>"$LOG" 2>&1
}

# Trim surrounding whitespace and Windows carriage returns. Not xargs: it
# chokes on quotes inside descriptions.
trim(){
    local s="${1//$'\r'/}"
    s="${s#"${s%%[![:space:]]*}"}"
    printf '%s' "${s%"${s##*[![:space:]]}"}"
}

# --- MAIN INSTALL LOOP ---

installationloop(){
    # Check if file exists
    if [ ! -f "$PROGSFILE" ]; then
        echo "Programs file not found at $PROGSFILE"
        return
    fi

    aurinstalled="$(pacman -Qqm 2>/dev/null)"
    pipinstalled="$(pip list --format=freeze 2>/dev/null | cut -d= -f1)"
    pipxinstalled="$(sudo -u "$USERNAME" pipx list --short 2>/dev/null | awk '{print $1}')"

    tags=()
    programs=()
    options=()
    while IFS=, read -r tag program desc || [ -n "$tag" ]; do
        tag=$(trim "$tag")
        program=$(trim "$program")
        desc=$(trim "$desc")

        [[ "$tag" == \#* ]] && continue
        [[ -z "$program" ]] && continue

        tags+=("$tag")
        programs+=("$program")
        options+=("$program" "$desc" "on")
    done < "$PROGSFILE"

    # --separate-output ensures clean newlines instead of quoted strings
    selected_programs=$(dialog --title "Software Selector" \
                               --separate-output \
                               --checklist "Space: Select/Deselect | Enter: Confirm" \
                               25 80 15 \
                               "${options[@]}" \
                               3>&1 1>&2 2>&3)

    if [ $? -ne 0 ]; then
        echo "Program selection cancelled by user."
        return
    fi

    clear
    echo "##### Starting Installation (log: $LOG) #####"

    # All pacman packages go in one transaction. If it fails (a renamed or
    # conflicting package), retry them one by one to find which ones.
    pacpkgs=()
    for i in "${!programs[@]}"; do
        [ "${tags[$i]}" = "p" ] || continue
        grep -Fxq -- "${programs[$i]}" <<<"$selected_programs" && pacpkgs+=("${programs[$i]}")
    done

    if [ ${#pacpkgs[@]} -ne 0 ]; then
        echo "--> Installing ${#pacpkgs[@]} pacman packages"
        if installpkg "${pacpkgs[@]}"; then
            echo "    [OK] Success"
        else
            echo "    Batch failed, retrying one by one"
            for program in "${pacpkgs[@]}"; do
                if installpkg "$program"; then
                    echo "    [OK] $program"
                else
                    echo "    [X] FAILED: $program"
                    failed_items+=("$program")
                fi
            done
        fi
    fi

    for i in "${!programs[@]}"; do
        tag="${tags[$i]}"
        program="${programs[$i]}"
        [ "$tag" = "p" ] && continue
        grep -Fxq -- "$program" <<<"$selected_programs" || continue

        echo "--> Installing: $program"
        # Execute installer closing stdin (< /dev/null)
        case "$tag" in
            "g") gitinstall "$program" ;;
            "a") aurinstall "$program" ;;
            "i") pipinstall "$program" ;;
            "x") pipxinstall "$program" ;;
            *) echo "Unknown tag '$tag' for $program"; false ;;
        esac < /dev/null

        if [ $? -ne 0 ]; then
            echo "    [X] FAILED: $program"
            failed_items+=("$program")
        else
            echo "    [OK] Success"
        fi
    done
}

### SCRIPT EXECUTION ###

configuration_wizard

setup_sudo

seed_local_files

# Install AUR Helper
echo "Installing AUR Helper ($aurhelper)..."
install_aurhelper || error "Failed to install AUR helper, see $LOG"

# Run Installation Loop
installationloop

echo "Enabling services..."
for unit in NetworkManager.service bluetooth.service docker.service libvirtd.service sshd.service fstrim.timer lightdm.service; do
    enable_service "$unit"
done

for group in docker libvirt wireshark; do
    getent group "$group" >/dev/null && usermod -aG "$group" "$USERNAME"
done

# Apply Feature Configs
if echo "$features_choices" | grep -q "ZSH"; then
    echo "Setting ZSH as default shell..."
    chsh -s /bin/zsh "$USERNAME" >/dev/null 2>&1
    sudo -u "$USERNAME" mkdir -p "$HOMEDIR/.cache/zsh/"
fi

if echo "$features_choices" | grep -q "TMUX"; then
    install_tmux_plugins
fi

if echo "$features_choices" | grep -q "CUPS"; then
    enable_service cups.service
fi

if echo "$features_choices" | grep -q "SMB"; then
    setup_smb
fi

echo "Creating user directories..."
sudo -u "$USERNAME" mkdir -p "$HOMEDIR/Screenshots" "$HOMEDIR/Desktop" "$HOMEDIR/Documents" "$HOMEDIR/projects"

# CyberArk PSM .rdp downloads open with psm (.local/share/applications/psm.desktop)
if command -v xdg-mime >/dev/null 2>&1; then
    sudo -u "$USERNAME" xdg-mime default psm.desktop application/x-remmina
fi

# kubie only reads ~/.kube/kubie.yaml; the tracked copy lives in .config/kubie
echo "Configuring kubie..."
if [ -f "$HOMEDIR/.config/kubie/kubie.yaml" ]; then
    sudo -u "$USERNAME" mkdir -p "$HOMEDIR/.kube"
    sudo -u "$USERNAME" ln -sfn "$HOMEDIR/.config/kubie/kubie.yaml" "$HOMEDIR/.kube/kubie.yaml"
fi

# 8. FINAL REPORT
clear
echo "########################################"
echo "        INSTALLATION COMPLETE"
echo "########################################"

if [ ${#failed_items[@]} -ne 0 ]; then
    msg="The following items FAILED:\n\n"
    for item in "${failed_items[@]}"; do
        msg+="- $item\n"
    done
    msg+="\nSee $LOG for details."

    dialog --title "Installation Warnings" --colors --msgbox "\Z1$msg" 20 60

    # Also print to terminal just in case
    echo -e "\nWARNING: The following items failed:"
    printf '%s\n' "${failed_items[@]}"
    echo "Log: $LOG"
else
    dialog --title "Success" --msgbox "All selected programs were installed successfully!" 10 50
    echo "All systems operational."
fi

echo -e "\nDONE! Please reboot your system."
