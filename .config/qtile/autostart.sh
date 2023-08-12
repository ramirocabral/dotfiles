#!/bin/sh

# systray battery icon
cbatticon -u 5 &
# systray volume
volumeicon &

feh --bg-scale ~/.local/wallpapers/3.png

picom &
