#!/usr/bin/env bash

source <(grep "=" config.default.ini)
[[ -f config.ini ]] && source <(grep "=" config.ini)

resp.error() {
  cat <<EOF
Status: $1 $2
Content-type: application/json

{ "error": $1, "message": "$2" }
EOF
  exit 0
}

read.uptime() { cat /proc/uptime | awk '{print $1}'; }

read.loadavg() { jq -cR 'split(" ") | .[0:4] | .[0] = (.[0]|tonumber) | .[1] = (.[1]|tonumber) | .[2] = (.[2]|tonumber)' /proc/loadavg; }

read.storage() {
  json='[]'
  while (("$#")); do
    file=$(df | grep -E "\s${1}$")
    dev=$(awk '{print $1}' <<<"$file")
    usage=$(awk '{print $5}' <<<"$file")
    total=$(awk '{print $2}' <<<"$file")
    free=$(awk '{print $4}' <<<"$file")
    mount=$(awk '{print $6}' <<<"$file")
    [[ ! -z $dev ]] &&
      json=$(jq ". += [{ \"device\": \"${dev}\", \"mount\": \"${mount}\", \"usage\": \"${usage}\", \"total\": ${total}, \"free\": ${free} }]" <<<$json) ||
      json=$(jq '. += [null]' <<<$json)
    shift
  done
  echo $json
}

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

read.services() {
  json='{}'
  while (("$#")); do
    status=$(systemctl show "${1}")
    state=$(echo "$status" | grep 'ActiveState' | cut -d "=" -f2)
    substate=$(echo "$status" | grep 'SubState' | cut -d "=" -f2)
    tasks=$(echo "$status" | grep 'TasksCurrent' | cut -d "=" -f2)
    [[ "$tasks" = "[not set]" ]] && tasks=null
    memory=$(echo "$status" | grep 'MemoryCurrent' | cut -d "=" -f2)
    [[ "$memory" = "[not set]" ]] && memory=null
    uptime=$(( $(date +%s) - $(date -d "$(echo "$status" | grep 'ExecMainStartTimestamp=' | cut -d "=" -f2)" +%s) ))
    [[ "$state" != "active" ]] && uptime=null

    item=$(jq ".state = \"${state}\"
             | .substate = \"${substate}\"
             | .uptime = ${uptime:-null}
             | .tasks = ${tasks:-null}
             | .memory = ${memory:-null}" -c <<< '{}')
    json=$(jq ".[\"$1\"] = ${item}" <<<$json)
    shift
  done
  echo $json
}

type -P jq &>/dev/null || resp.error 500 "Command \`jq\` Not Installed"
[[ "$HTTP_AUTHORIZATION" != "Bearer ${auth_bearer}" ]] && resp.error 403 "Unauthorized access"

echo "Content-type: application/json"
echo

jq ".uptime = $(read.uptime)
  | .load = $(read.loadavg)
  | .memory = $(read.memory)
  | .storage = $(read.storage "${storage[@]}")
  | .services = $(read.services "${services[@]}")
" -c <<<'{}'
exit 0
