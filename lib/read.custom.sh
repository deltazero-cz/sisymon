#!/usr/bin/env bash

read.custom() {
  json='[]'
  while (("$#")); do
    result=$("./custom/${1}")

    item=$(jq ".name = \"${1}\"
             | .result = ${result:-null}" -c <<< '{}')
    json=$(jq ". += [${item}]" <<< "$json")
    shift
  done
  echo "$json"
}
