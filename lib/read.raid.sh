#!/usr/bin/env bash

read.raid() {
  mdstat=$(awk '/^md/ {printf "%s: ", $1}; /blocks/ {print $NF}' /proc/mdstat)

  json='[]'
  while (("$#")); do
    status=$(echo "$mdstat" | grep "$1" | awk '{print $2}')
    [[ -n "$status" ]] && status="\"$status\""

    item=$(jq ".name = \"/dev/${1}\"
             | .status = ${status:-null}
           " -c <<< '{}')

    json=$(jq ". += [${item}]" <<< "$json")
    shift
  done
  echo "$json"
}
