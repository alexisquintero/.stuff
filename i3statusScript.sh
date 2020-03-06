#!/bin/sh

# Make sure this script is in $PATH, then call this script in i3 config like this `status_command i3statusScript.sh`
# Leave a space between paths, scripts must return a string with the format "content | "
SCRIPTS_PATHS="$HOME/.config/utils/spotifyInfo.sh
               $HOME/.config/utils/netSpeed.sh"
# Path to your i3status config file
I3STATUS_CONF="$HOME/.config/i3/i3status"

stdbuf -o 0 -e 0 i3status --config "$I3STATUS_CONF" | while :
do
  read -r line
  SCRIPTS_OUTPUT=""
  for SCRIPT_PATH in $SCRIPTS_PATHS
  do
    if [ -f "$SCRIPT_PATH" ]
    then
      SCRIPTS_OUTPUT=$(sh "$SCRIPT_PATH")$SCRIPTS_OUTPUT
    fi
  done
  echo "$SCRIPTS_OUTPUT$line" || exit 1
done
