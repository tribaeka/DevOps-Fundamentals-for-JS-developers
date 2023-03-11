#!/bin/bash

DEFAULT_THRESHOLD=10

if [ $# -eq 0 ]; then
  THRESHOLD=$DEFAULT_THRESHOLD
else
  THRESHOLD=$1
fi

function check_disk_space {
  FREE_PERCENT=$(df -P . | awk 'NR==2 {print $5}' | sed 's/%//')

  if [ $FREE_PERCENT -lt $THRESHOLD ]; then
    # Send warning message to stderr
    echo "WARNING: Free disk space below threshold! ($FREE_PERCENT%)" >&2
  fi
}

while true; do
  check_disk_space
  sleep 5
done
