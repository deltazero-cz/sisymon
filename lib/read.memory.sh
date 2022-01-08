#!/usr/bin/env bash

read.memory() {
  file=$(</proc/meminfo)
  ram_total=$(echo "$file" | grep MemTotal | awk '{print $2}')
  ram_free=$(echo "$file" | grep MemAvailable | awk '{print $2}')
  swap_total=$(echo "$file" | grep SwapTotal | awk '{print $2}')
  swap_free=$(echo "$file" | grep SwapFree | awk '{print $2}')
  cat <<EOF
{
    "ram": { "usage": "$((100 - 100 * ram_free / ram_total))%", "total": ${ram_total}, "free": ${ram_free}},
    "swap": { "usage": "$((100 - 100 * swap_free / swap_total))%", "total": ${swap_total}, "free": ${swap_free}}
  }
EOF
}
