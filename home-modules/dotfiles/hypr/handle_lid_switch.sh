#!/usr/bin/env sh

output=$(hyprctl monitors)

# Use grep to count the occurrences of the word "Monitor," which indicates a new monitor entry
monitor_count=$(echo "$output" | grep -c "^Monitor")

# Check if there is more than one monitor
if [ "$monitor_count" -gt 1 ]; then
    hyprctl keyword monitor "eDP-1, disable"
fi
