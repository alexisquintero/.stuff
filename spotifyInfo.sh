#!/bin/sh

if [ "$(pidof spotify)" ]
then
  SPOTIFY_METADATA=$(gdbus call \
    --session \
    --dest org.mpris.MediaPlayer2.spotify \
    --object-path /org/mpris/MediaPlayer2 \
    --method org.freedesktop.DBus.Properties.Get org.mpris.MediaPlayer2.Player "Metadata")

  NAME=$(echo "$SPOTIFY_METADATA" | grep -oP "(?<='xesam:title': <['\"]).*(?=['\"]>,)")
  ARTIST=$(echo "$SPOTIFY_METADATA" | grep -oP "(?<='xesam:artist': <\[['\"]).*(?=['\"]\]>,)" | tr -d "]['\"")

  echo "♫ $NAME - $ARTIST | "
else
  echo ""
fi
