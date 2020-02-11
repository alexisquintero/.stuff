#!/bin/sh

if [ "$(pidof spotify)" ]
then
  SPOTIFY_METADATA=$(dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata')
  NAME=$(echo "$SPOTIFY_METADATA" | grep -A 1 "xesam:title" | grep "variant.*" | grep -oP '.*"\K[^"]+')
  ARTIST=$(echo "$SPOTIFY_METADATA" | grep -A 2 "xesam:artist" | grep -v "xesam:artist" | grep -oP '.*"\K[^"]+')

  echo "♫ $NAME - $ARTIST | "
else
  echo ""
fi
