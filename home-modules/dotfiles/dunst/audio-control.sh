#!/usr/bin/env bash

# NOTE: 4 environment is needed
# MUTE_ICON_PATH, LOW_ICON_PATH, MEDIUM_ICON_PATH, HIGH_ICON_PATH

case $1 in
up)
	# Set the volume on (if it was muted)
	wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
	# Up the volume (+ 5%)
	wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
	;;
down)
	wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
	wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
	;;
mute)
	# Toggle mute
	wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
	;;
esac

VOLUME=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | tr -dc '0-9' | sed 's/^0\{1,2\}//')

send_notification() {
	if [ "$1" = "mute" ]; then
		ICON="$MUTE_ICON_PATH"
	elif [ "$VOLUME" -lt 33 ]; then
		ICON="$LOW_ICON_PATH"
	elif [ "$VOLUME" -lt 66 ]; then
		ICON="$MEDIUM_ICON_PATH"
	else
		ICON="$HIGH_ICON_PATH"
	fi

	if [ "$1" = "mute" ]; then
		TEXT="Currently muted"
	else
		TEXT="Currently at ${VOLUME}%"
	fi

	dunstify -a "Volume" -r 9993 -h int:value:"$VOLUME" -I $ICON "Volume" "$TEXT" -t 2000
}

case $1 in
mute)
	case "$(wpctl get-volume @DEFAULT_AUDIO_SINK@)" in
	*MUTED*) send_notification mute ;;
	*) send_notification "" ;;
	esac
	;;
*)
	send_notification ""
	;;
esac
