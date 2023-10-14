# Antonio Sarosi
# https://youtube.com/c/antoniosarosi
# https://github.com/antoniosarosi/dotfiles

# Qtile keybindings

from libqtile.config import Key
from libqtile.command import lazy


mod = "mod4"

keys = [Key(key[0], key[1], *key[2:]) for key in [
    # ------------ Window Configs ------------

    # Switch between windows in current stack pane
    ([mod], "j", lazy.layout.down()),
    ([mod], "k", lazy.layout.up()),
    ([mod], "h", lazy.layout.left()),
    ([mod], "l", lazy.layout.right()),

    # Change focus to next layout
    ([mod], "q", lazy.layout.next()),

    # Change window sizes (MonadTall)
    ([mod, "shift"], "h", lazy.layout.grow()),
    ([mod, "shift"], "l", lazy.layout.shrink()),

    # Toggle floating
    ([mod, "shift"], "f", lazy.window.toggle_floating()),

    # Move windows up or down in current stack
    ([mod, "shift"], "k", lazy.layout.shuffle_down()),
    ([mod, "shift"], "j", lazy.layout.shuffle_up()),

    # Toggle between different layouts as defined below
    ([mod], "Tab", lazy.next_layout()),
    ([mod, "shift"], "Tab", lazy.prev_layout()),

    # Kill window
    ([mod], "w", lazy.window.kill()),

    
    # Switch focus of monitors
    ([mod], "period", lazy.next_screen()),
    ([mod], "comma", lazy.prev_screen()),

    # Restart Qtile
    ([mod, "control"], "r", lazy.restart()),
    # Restart graphical environment
    ([mod, "control"], "q", lazy.shutdown()),

    # Change keyboard layout
    ([mod], "space", lazy.widget["keyboardlayout"].next_keyboard()),

    # ------------ App Configs ------------

    #Thunar
    ([mod], "e", lazy.spawn("thunar")),

    # Ranger
    ([mod], "r", lazy.spawn("alacritty -e ranger")),

    # Rofi
    ([mod], "m", lazy.spawn("rofi -show drun")),

    # Spotify
    ([mod], "s", lazy.spawn("spotify-launcher")),

    # Browser
    ([mod], "b", lazy.spawn("librewolf")),

    # Terminal
    ([mod], "Return", lazy.spawn("alacritty")),

    # Bluetooth Manager
    ([mod], "c", lazy.spawn("blueman-manager")),

    # Screenshot
    ([mod, "shift"], "s", lazy.spawn("scrot --select --line mode=edge '/home/ramiro/Screenshots/%F_%T_$wx$h.png' -e 'xclip -selection clipboard -target image/png -i $f'")),

    # ------------ Hardware Configs ------------

    ([mod], "minus", lazy.spawn(
        "pactl set-sink-volume @DEFAULT_SINK@ -5%"
    )),
    ([mod], "equal", lazy.spawn(
        "pactl set-sink-volume @DEFAULT_SINK@ +5%"
    )),
    ([mod], "p", lazy.spawn(
        "pactl set-sink-mute @DEFAULT_SINK@ toggle"
    )),

    # Brightness
    ([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl set +10%")),
    ([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl set 10%-")),
]]
