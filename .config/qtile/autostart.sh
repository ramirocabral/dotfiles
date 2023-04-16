#!/bin/sh

# systray battery icon
cbatticon -u 5 &
# systray volume
volumeicon &

feh --bg-scale ~/Downloads/1.png

picom &