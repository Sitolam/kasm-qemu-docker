#!/bin/bash
/usr/bin/desktop_ready
sleep 3
while [ ! -e /run/pulse/native ]; do
  echo "Waiting auf PulseAudio..."
  sleep 1
done
/usr/bin/tini -s /run/entry.sh