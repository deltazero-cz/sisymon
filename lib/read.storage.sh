#!/usr/bin/env bash

read.storage() {
  json='[]'
  while (("$#")); do
    file=$(df | grep -E "\s${1}$")
    dev=$(awk '{print $1}' <<<"$file")
    usage=$(awk '{print $5}' <<<"$file")
    total=$(awk '{print $2}' <<<"$file")
    free=$(awk '{print $4}' <<<"$file")
    mount=$(awk '{print $6}' <<<"$file")
    [[ -n $dev ]] \
      && json=$(jq ". += [{ \"device\": \"${dev}\", \"mount\": \"${mount}\", \"usage\": \"${usage}\", \"total\": ${total}, \"free\": ${free} }]" <<< "$json") \
      || json=$(jq '. += [null]' <<< "$json")
    shift
  done
  echo "$json"
}
