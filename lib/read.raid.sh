#!/usr/bin/env bash

read.raid() {
  mdstat=$(awk '/^md/ {printf "%s: ", $1}; /blocks/ {print $NF}' /proc/mdstat)

  json='[]'
  while (("$#")); do
    array=$(grep "$1" /proc/mdstat | cut -f 3- -d " ")
    [[ -n "$array" ]] && array="\"$array\""

    status=$(echo "$mdstat" | grep "$1" | awk '{print $2}')
    [[ -n "$status" ]] && status="\"$status\""

    item=$(jq ".name = \"/dev/${1}\"
             | .array = ${array:-null}
             | .status = ${status:-null}
           " -c <<< '{}')

    json=$(jq ". += [${item}]" <<< "$json")
    shift
  done
  echo "$json"
}
