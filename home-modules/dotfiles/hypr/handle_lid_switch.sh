#!/usr/bin/env bash

output=$(hyprctl monitors)

# Use grep to count the occurrences of the word "Monitor," which indicates a new monitor entry
monitor_count=$(echo "$output" | grep -c "^Monitor")
lid_state="$(awk '{print $2}' < /proc/acpi/button/lid/LID/state)"

# Check if there is more than one monitor
if [[ "$monitor_count" -gt 1 ]] || [[ "$lid_state" == "close" ]] ; then
    hyprctl keyword monitor "eDP-1, disable"
else
    hyprlock
fi
