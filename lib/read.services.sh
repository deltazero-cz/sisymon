#!/usr/bin/env bash

read.services() {
  json='[]'
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

    item=$(jq ".name = \"${1}\"
             | .state = \"${state}\"
             | .substate = \"${substate}\"
             | .uptime = ${uptime:-null}
             | .tasks = ${tasks:-null}
             | .memory = ${memory:-null}" -c <<< '{}')
    json=$(jq ". += [${item}]" <<< "$json")
    shift
  done
  echo "$json"
}
