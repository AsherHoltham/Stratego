#!/bin/bash

# Find an available port by asking the OS directly (commonly reliable method)
find_open_port() {
  local used_ports candidate_port
  # Extract used ports from netstat output (macOS friendly)
  used_ports=$(netstat -anv | grep LISTEN | awk '{print $4}' | rev | cut -d. -f1 | rev | sort -u)
  
  # Compare the dynamic port range against used ports and randomly pick one using awk
  candidate_port=$(comm -23 <(seq 49152 65535 | sort) <(echo "$used_ports") | \
    awk 'BEGIN {srand()} {line[NR]=$0} END {if (NR>0) print line[int(rand()*NR)+1]}')
  
  echo "$candidate_port"
}

open_server() {
  dart run server.dart
}

export APP_PORT=$(find_open_port)
echo "✅ Found open port: $APP_PORT"

open_server &

echo "All processes have finished."