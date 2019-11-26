#!/bin/sh

i3status --config ~/.config/i3/i3status | while :
do
  NAME=$(dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | grep -A 1 "xesam:title" | grep "variant.*" | grep -oP '.*"\K[^"]+')

  ARTIST=$(dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | grep -A 2 "xesam:artist" | grep -v "xesam:artist" | grep -oP '.*"\K[^"]+')

  read -r line
  if [ "$NAME" ]
  then
    echo " $NAME - $ARTIST | $line" || exit 1
  else
    echo "$line" || exit 1
  fi
done
