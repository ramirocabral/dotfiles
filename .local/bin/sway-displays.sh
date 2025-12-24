#!/usr/bin/env bash

outputs=$(swaymsg -t get_outputs -r)

if echo "$outputs" | jq -e '.[] | select(.name=="DP-3")' >/dev/null; then
    swaymsg 'output DP-3 mode 2560x1440@120Hz'
    swaymsg 'output HDMI-A-1 mode 1920x1080@70Hz position 2560 0 transform 90'
elif echo "$outputs" | jq -e '.[] | select(.name=="eDP-1")' >/dev/null; then
    swaymsg 'output eDP-1 position 0 0'
    swaymsg 'output HDMI-A-1 mode 2560x1440@60Hz position 1920 0'
fi
