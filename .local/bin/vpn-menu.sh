#!/bin/bash

nmcli -g NAME,TYPE,DEVICE connection show | grep ":vpn" | awk -F: '{print ($3!="" ? "🟢 " : "⚪ ") $1}' | wofi --dmenu -p "VPN State" --width 300 --height 200
