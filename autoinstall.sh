#!/bin/bash

# https://github.com/ramirocabral/dotfiles

# Inspired by Luke Smith LARBS script

### VARIABLES ###

aurhelper="paru"
USERNAME="$1"
[ -z "$USERNAME" ] && echo "Error: Username not provided." && exit 1

HOMEDIR="/home/$USERNAME"
REPODIR="$HOMEDIR/.local/src"
CONFIG_FILE="/tmp/arch_install_config"
PROGSFILE="$HOMEDIR/progs.csv"

# Store failed installations
failed_items=()

### FUNCTIONS ###

error(){
    clear
    echo -e "ERROR : $1"
    exit 1
}

configuration_wizard() {
    dialog --title "Hardware Configuration" \
           --form "Set environment variables for ~/.config/zsh/.local" \
           15 60 4 \
           "LAN Interface:" 1 1 "wlo1" 1 20 20 0 \
           "System Class:"  2 1 "laptop" 2 20 20 0 \
           2> "$CONFIG_FILE.vars"

    # Read form results
    LAN_IF=$(sed -n 1p "$CONFIG_FILE.vars")
    SYS_CLASS=$(sed -n 2p "$CONFIG_FILE.vars")

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

generate_local_env() {
    echo "Generating .local environment file..."
    sudo -u "$USERNAME" mkdir -p "$HOMEDIR/.config/zsh"
    
    cat <<EOF > "$HOMEDIR/.config/zsh/.local"
# File generated automatically by autoinstall.sh
export LAN_INTERFACE="$LAN_IF"
export SYSTEM_CLASS="$SYS_CLASS"
EOF
    
    chown "$USERNAME:$USERNAME" "$HOMEDIR/.config/zsh/.local"
    echo "Saved env vars: LAN=$LAN_IF, CLASS=$SYS_CLASS"
}

setup_smb() {
    SMB_USER=$(dialog --title "Samba Setup" --inputbox "Enter Samba Server User:" 8 40 --output-fd 1)
    SMB_PASS=$(dialog --title "Samba Setup" --passwordbox "Enter Samba Server Password:" 8 40 --output-fd 1)
    
    [ -z "$SMB_USER" ] && echo "Skipping SMB setup (empty user)." && return
    
    echo "username=$SMB_USER" >> "$HOMEDIR/.credentials"
    echo "password=$SMB_PASS" >> "$HOMEDIR/.credentials"
    echo "domain=WORKGROUP" >> "$HOMEDIR/.credentials"
    
    chmod 600 "$HOMEDIR/.credentials"
    chown "$USERNAME:$USERNAME" "$HOMEDIR/.credentials"

    sudo mkdir -p /mnt/nas/ramiro /mnt/nas/public
    
    echo "//nas.lan/public /mnt/nas/public cifs credentials=$HOMEDIR/.credentials,uid=1000,gid=100,dir_mode=0770,file_mode=0660 0 2" >> /etc/fstab
    echo "//nas.lan/ramiro /mnt/nas/ramiro cifs credentials=$HOMEDIR/.credentials,uid=1000,gid=100,dir_mode=0770,file_mode=0660 0 3" >> /etc/fstab
    
    echo "Samba configured."
}

# --- INSTALLATION FUNCTIONS ---

install_aur(){
    sudo -u "$USERNAME" mkdir -p "$REPODIR/$1"
    sudo -u "$USERNAME" git -C "$REPODIR" clone --depth 1 --no-tags -q "https://aur.archlinux.org/$1.git" "$REPODIR/$1"
    cd "$REPODIR/$1" || return 1
    sudo -u "$USERNAME" makepkg --noconfirm -si "$REPODIR/$1" >/dev/null 2>&1
    return $?
}

installpkg(){
    pacman --noconfirm --needed -S "$1" >/dev/null 2>&1
    return $?
}

aurinstall(){
    echo "$aurinstalled" | grep -q "^$1$" && return 0
    sudo -u "$USERNAME" $aurhelper -S --noconfirm "$1" >/dev/null 2>&1
    return $?
}

gitinstall(){
    progname="${1##*/}"
    echo "$gitinstalled" | grep -q "^$progname$" && return 0
    progname="${progname%.git}"
    dir="$REPODIR/$progname"
    sudo -u "$USERNAME" git -C "$REPODIR" clone --depth 1 --single-branch \
        --no-tags -q "$1" "$dir" ||
        {
            cd "$dir" || return 1
            sudo -u "$USERNAME" git pull --force origin master
        }
    cd "$dir" || return 1
}

pipinstall(){
    [ -x "$(command -v "pip")" ] || installpkg python-pip >/dev/null 2>&1
    echo "$pipinstalled" | grep -q "^$1$" && return 0
    pip install --break-system-packages $1 >/dev/null 2>&1
    return $?
}

install_tmux_plugins(){
    echo "Installing Tmux plugins..."
    sudo -u "$USERNAME" git clone https://github.com/tmux-plugins/tpm "$HOMEDIR/.config/tmux/plugins/tpm" || {
        echo "Failed to clone tpm"
        return 1
    }
    [ -d "$HOMEDIR/.config/tmux/plugins/tpm" ] && \
    sudo -u "$USERNAME" "$HOMEDIR/.config/tmux/plugins/tpm/bin/install_plugins"
}

# --- MAIN INSTALL LOOP ---

installationloop(){
    if [ ! -f "$PROGSFILE" ]; then
        echo "Programs file not found at $PROGSFILE"
        return
    fi

    # Get installed lists
    aurinstalled="$(pacman -Qqm)"
    gitinstalled="$(ls "$REPODIR")"
    pipinstalled="$(pip list | awk '{print $1}' | tail -n +3)"

    # Build Dialog Array
    options=()
    while IFS=, read -r tag program desc; do
        [[ "$tag" =~ ^#.*$ ]] && continue
        [[ -z "$program" ]] && continue
        options+=("$program" "$desc" "on")
    done < "$PROGSFILE"

    # Show Checklist
    selected_programs=$(dialog --title "Software Selector" \
                               --checklist "Select programs to install (Space to toggle):" \
                               25 80 15 \
                               "${options[@]}" \
                               3>&1 1>&2 2>&3)

    exit_status=$?
    if [ $exit_status -ne 0 ]; then
        echo "Program selection cancelled."
        return
    fi
    
    clear
    echo "##### Installing Selected Programs #####"

    # Install Loop
    while IFS=, read -r tag program desc; do
        [[ "$tag" =~ ^#.*$ ]] && continue
        
        # Check if program is in the selected string
        if echo "$selected_programs" | grep -w -q "\"$program\""; then
            echo "Installing: $program..."
            success=0
            
            # Execute install and capture exit code
            case "$tag" in
                "p") installpkg "$program" || success=1 ;;
                "g") gitinstall "$program" || success=1 ;;
                "a") aurinstall "$program" || success=1 ;;
                "i") pipinstall "$program" || success=1 ;;
                *) echo "Unknown tag '$tag' for $program"; success=1 ;;
            esac

            # Log failure
            if [ $success -ne 0 ]; then
                echo "FAILED to install: $program"
                failed_items+=("$program")
            fi
        fi
    done < "$PROGSFILE"
}

### SCRIPT EXECUTION ###

configuration_wizard

# Apply Hardware Config (generate .local)
generate_local_env

# Sudo Setup
[ -f /etc/sudoers.pacnew ] && cp /etc/sudoers.pacnew /etc/sudoers
trap 'rm -f /etc/sudoers.d/larbs-temp' HUP INT QUIT TERM PWR EXIT
echo "%wheel ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/larbs-temp

# Install AUR Helper
echo "Installing AUR Helper ($aurhelper)..."
sudo chmod -R 777 "$REPODIR"
install_aur "${aurhelper}" || error "Failed to install AUR helper"

# Run Installation Loop
installationloop

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
    echo "Enabling CUPS service..."
    systemctl enable --now cups.service
fi

if echo "$features_choices" | grep -q "SMB"; then
    setup_smb
fi

echo "Creating user directories..."
sudo -u "$USERNAME" mkdir -p "$HOMEDIR/Screenshots" "$HOMEDIR/Desktop" "$HOMEDIR/Documents" "$HOMEDIR/projects"

if [ -f "$HOMEDIR/librewolf.overrides.cfg" ]; then
    sudo -u "$USERNAME" mkdir -p "$HOMEDIR/.librewolf"
    ln -sf "$HOMEDIR/librewolf.overrides.cfg" "$HOMEDIR/.librewolf/librewolf.overrides.cfg" 
fi

# 8. FINAL REPORT
clear
echo "########################################"
echo "        INSTALLATION COMPLETE"
echo "########################################"

if [ ${#failed_items[@]} -ne 0 ]; then
    msg="The following packages FAILED to install:\n\n"
    for item in "${failed_items[@]}"; do
        msg+="- $item\n"
    done
    msg+="\nPlease check the logs manually."

    dialog --title "Installation Warnings" --colors --msgbox "\Z1$msg" 20 60
    
    # Also print to terminal just in case
    echo -e "\nWARNING: The following packages failed to install:"
    printf '%s\n' "${failed_items[@]}"
else
    dialog --title "Success" --msgbox "All selected programs were installed successfully!" 10 50
    echo "All systems operational."
fi

echo -e "\nDONE! Please reboot your system."
